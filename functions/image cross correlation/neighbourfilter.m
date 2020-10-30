function [hu,hv]=neighbourfilter(x,y,u,v,method,kernelsize,threshold)
%
%
% This function is a filter that will remove vectors that deviate from
% the median or the mean of their surrounding neighbors by the factor
% THRESHOLD times the standard deviation of the neighbors. 
%
% METHOD (optional) should be either 'median' or 'mean'. Default is
% 'median'.
%
% KERNELSIZE is optional and is specified as number, typically 3 or 5
% which defines the number of vectors contributing to the median or mean
% value of each vector. 
%
% MASK can be applied to save calculation time. LOCALFILT is relatively 
% slow on large matrices and exlcuding "non-interesting" regions with MASK
% can increase speed in some cases.
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
% https://doi.org/10.5194/tc-2020-204
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 0.7, Autumn 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%


IN=zeros(size(u));


    if any(strcmp(method,'median'))
        method='mnanmedian'; stat='median'; ff=1;
    elseif any(strcmp(method,'mean'))
        method='mnanmean'; stat='mean'; ff=2;
    end  
    if ~any(strcmp(method,'mean')) & ~any(strcmp(method,'median'))
        method='mnanmedian'; stat='median';
    end
      



nu=zeros(size(u)+2*floor(kernelsize/2))*nan;
nv=zeros(size(u)+2*floor(kernelsize/2))*nan;
nu(floor(kernelsize/2)+1:end-floor(kernelsize/2),floor(kernelsize/2)+1:end-floor(kernelsize/2))=u;
nv(floor(kernelsize/2)+1:end-floor(kernelsize/2),floor(kernelsize/2)+1:end-floor(kernelsize/2))=v;

INx=zeros(size(nu));
INx(floor(kernelsize/2)+1:end-floor(kernelsize/2),floor(kernelsize/2)+1:end-floor(kernelsize/2))=IN;

prev=isnan(nu); previndx=find(prev==1); 
U2=nu+i*nv; teller=1; [ma,na]=size(U2); histo=zeros(size(nu));
histostd=zeros(size(nu));hista=zeros(size(nu));histastd=zeros(size(nu));

for ii=kernelsize-1:1:na-kernelsize+2  
    for jj=kernelsize-1:1:ma-kernelsize+2
        if INx(jj,ii)~=1
            
            tmp=U2(jj-floor(kernelsize/2):jj+floor(kernelsize/2),ii-floor(kernelsize/2):ii+floor(kernelsize/2)); 
            tmp(ceil(kernelsize/2),ceil(kernelsize/2))=NaN;
            if ff==1
                usum=nanmedian(tmp(:));
            elseif ff==2
                usum=nanmean(tmp(:));
            end
            histostd(jj,ii)=nanstd(tmp(:));
        else
            usum=nan; tmp=NaN; histostd(jj,ii)=nan;
        end

        histo(jj,ii)=usum;
    end
  
end

%%%%ALTERNATIVE METHOD: NLFILTER
% % %Suppress pop-up
% % function wb = waitbar(varargin)
% %   if nargout > 0
% %     wb = matlab.graphics.GraphicsPlaceholder;
% %   end
% % end
% % 
% % if ff==1
% %     fun_med = @(x) median(x(:));
% % else
% %     fun_med = @(x) mean(x(:));
% % end
% % 
% % fun_std = @(x) median(x(:));
% % 
% % histo = nlfilter(U2,[kernelsize kernelsize],fun_med); 
% % 
% % histostd = nlfilter(U2,[kernelsize kernelsize],fun_std); 

%%%%%%%% Locate gridpoints with a higher value than the threshold 

[cy,cx]=find( ( real(U2)>real(histo)+threshold*real(histostd) |...
    imag(U2)>imag(histo)+threshold*imag(histostd) |...
    real(U2)<real(histo)-threshold*real(histostd) |...
    imag(U2)<imag(histo)-threshold*imag(histostd) ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for jj=1:length(cy)
    % Now we asign NotANumber (NaN) to all the points in the matrix that
    % exceeds our threshold.
    nu(cy(jj),cx(jj))=NaN;  nv(cy(jj),cx(jj))=NaN;
end

rest=length(cy);

rest2=sum(isnan(u(:)))-sum(prev(:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hu=nu(ceil(kernelsize/2):end-floor(kernelsize/2),ceil(kernelsize/2):end-floor(kernelsize/2));
hv=nv(ceil(kernelsize/2):end-floor(kernelsize/2),ceil(kernelsize/2):end-floor(kernelsize/2));


end
