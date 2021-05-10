function [xx,yy,datax,datay]=GIVtrackmultifirst(A,B,winsize,overlap,initialdx,initialdy)

% function [x,y,datax,datay]=firstpass(A,B,M,ol,idx,idy)
%

%This function is based upon a multipass solver written by Kristian Sveen
%as part of the matPIV toolbox. It has been adapted for use as part of GIV.
%It is distributed under the terms of the Gnu General Public License
%manager.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please give us credit if you do, and share your code 
%with the same conditions as this.

% Read the associated paper here: 
% doi.org/10.5194/tc-15-2115-2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 1.0, Spring-Summer 2021%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%

if length(winsize)==1
    M=winsize;
elseif length(winsize)==2
    M=winsize(1); winsize=winsize(2); 
end
overlap=overlap; [sy,sx]=size(A);
if nargin < 6 || isempty(initialdx) || isempty(initialdy)
    initialdx=zeros(floor(sy/(winsize*(1-overlap))),floor(sx/(M*(1-overlap))));
    initialdy=zeros(floor(sy/(winsize*(1-overlap))),floor(sx/(M*(1-overlap))));
end
xx=zeros(ceil((size(A,1)-winsize)/((1-overlap)*winsize))+1, ...
    ceil((size(A,2)-M)/((1-overlap)*M)) +1);
yy=xx; datax=xx; datay=xx; 

IN=zeros(size(A)); 
cj=1;
for jj=1:((1-overlap)*winsize):sy-winsize+1
    ci=1;
    for ii=1:((1-overlap)*M):sx-M+1 
        
        if IN(jj+winsize/2,ii+M/2)~=1 
            
            if isnan(initialdx(cj,ci))
                initialdx(cj,ci)=0;
            end
            if isnan(initialdy(cj,ci))
                initialdy(cj,ci)=0;
            end
            if jj+initialdy(cj,ci)<1
                initialdy(cj,ci)=1-jj;
            elseif jj+initialdy(cj,ci)>sy-winsize+1
                initialdy(cj,ci)=sy-winsize+1-jj;
            end       
            if ii+initialdx(cj,ci)<1
                initialdx(cj,ci)=1-ii;    
            elseif ii+initialdx(cj,ci)>sx-M+1
                initialdx(cj,ci)=sx-M+1-ii;
            end
            
            C=A(jj:jj+winsize-1,ii:ii+M-1);   
            D=B(jj+initialdy(cj,ci):jj+winsize-1+initialdy(cj,ci),ii+initialdx(cj,ci):ii+M-1+initialdx(cj,ci));

            C=C-mean(C(:)); D=D-mean(D(:)); %C(C<0)=0; D(D<0)=0;
            stad1=std(C(:)); stad2=std(D(:)); 

            if stad1==0, stad1=nan;end
            if stad2==0, stad2=nan; end

            %%%%%%%%%%%%%%%%%%%%%%%Calculate the normalized correlation:   
            R=xcorrelate(C,D)/(winsize*M*stad1*stad2);
            
            %%%%%%%%%%%%%%%%%%%%%% Find the position of the maximal value of R
            if size(R,1)==(winsize-1)
              [max_y1,max_x1]=find(R==max(R(:)));
            else
              [max_y1,max_x1]=find(R==max(max(R(0.5*winsize+2:1.5*winsize-3,0.5*M+2:1.5*M-3))));
            end
            
            if length(max_x1)>1
              max_x1=round(sum(max_x1.*(1:length(max_x1))')./sum(max_x1));
              max_y1=round(sum(max_y1.*(1:length(max_y1))')./sum(max_y1));
            elseif isempty(max_x1)
              initialdx(cj,ci)=nan; initialdy(cj,ci)=nan; max_x1=nan; max_y1=nan;
            end
            %%%%%%%%%%%%%%%%%%%%%% Store the displacements in variable datax/datay
            datax(cj,ci)=-(max_x1-(M))+initialdx(cj,ci);
            datay(cj,ci)=-(max_y1-(winsize))+initialdy(cj,ci);
            xx(cj,ci)=ii+M/2; yy(cj,ci)=jj+winsize/2;
            ci=ci+1;
        else
            xx(cj,ci)=ii+M/2; yy(cj,ci)=jj+winsize/2;
            datax(cj,ci)=NaN; datay(cj,ci)=NaN; ci=ci+1;
        end  
    end
    cj=cj+1;
end



% now we inline the function xcorrelate to shave off some time.

function c = xcorrelate(a,b)
%  c = xcorrf2(a,b)
%
%
%   Two-dimensional cross-correlation using Fourier transforms.

%This function is based upon an adaptation of the xcorrf tool written by 
%R. Johnson. It has been adapted for use as part of GIV.


  if nargin<3
    pad='yes';
  end
  
  
  [ma,na] = size(a);
  if nargin == 1
    %       for autocorrelation
    b = a;
  end
  [mb,nb] = size(b);
  %       make reverse conjugate of one array
  b = conj(b(mb:-1:1,nb:-1:1));
  
  if strcmp(pad,'yes');
    %       use power of 2 transform lengths
    mf = 2^nextpow2(ma+mb);
    nf = 2^nextpow2(na+nb);
    at = fft2(b,mf,nf);
    bt = fft2(a,mf,nf);
  elseif strcmp(pad,'no');
    at = fft2(b);
    bt = fft2(a);
  else
    disp('Wrong input to xcorrelate'); return
  end
  
  %       multiply transforms then inverse transform
  c = ifft2(at.*bt);
  %       make real output for real input
  if ~any(any(imag(a))) & ~any(any(imag(b)))
    c = real(c);
  end
  %  trim to standard size
  if strcmp(pad,'yes');
    c(ma+mb:mf,:) = [];
    c(:,na+nb:nf) = [];
  elseif strcmp(pad,'no');
    c=fftshift(c(1:end-1,1:end-1));

  end
end
end