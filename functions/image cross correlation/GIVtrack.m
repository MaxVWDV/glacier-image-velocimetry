function [du, dv,snr,pkr]=GIVtrack(A,B,inputs,max_d)
%% Feature tracking by template matching
%
%Takes an image pair and uses standard image velocimetry techniques in
%order to derive a velocity map. See user manual for details of this
%process. The fast fourrier transforms of this function are the most
%computationally demanding portion of this toolbox.
%
% OUTPUTS:
%   du,dv: displacement of each point in pu,pv. [A(pu,pv) has moved to B(pu+du,pv+dv)]
%   peakCorr: correlation coefficient of the matched template.
%   meanAbsCorr: The mean absolute correlation coefficitent over the search
%                region is an estimate of the noise level.
%   pu,pv: actual pixel centers of templates in A may differ from inputs because of rounding.
%
% Note: In my experience, the multipass solver generally produces better
% results than this single pass solver

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


%Based on function 'templatematch' by Alsak Grinstead, part of
%the ImGRAFT toolbox. See his website below for details.

% ImGRAFT - An image georectification and feature tracking toolbox for MATLAB
% Copvright (C) 2014 Aslak Grinsted (www.glaciology.net)

% Permission is hereby granted, free of charge, to any person obtaining a copv
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copv, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copvright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.


scale_length = size(A);

%Calculate resolution of image
if strcmpi(inputs.isgeotiff,'No')
    NS1 = [inputs.minlat,inputs.minlon];
    NS2 = [inputs.maxlat,inputs.minlon];
    EW1 = [inputs.minlat,inputs.minlon];
    EW2 = [inputs.minlat,inputs.maxlon];
else
    NS1 = [inputs.geotifflocationdata.CornerCoords.Lat(1,4),inputs.geotifflocationdata.CornerCoords.Lon(1,4)];
    NS2 = [inputs.geotifflocationdata.CornerCoords.Lat(1,1),inputs.geotifflocationdata.CornerCoords.Lon(1,1)];
    EW1 = [inputs.geotifflocationdata.CornerCoords.Lat(1,4),inputs.geotifflocationdata.CornerCoords.Lon(1,4)];
    EW2 = [inputs.geotifflocationdata.CornerCoords.Lat(1,3),inputs.geotifflocationdata.CornerCoords.Lon(1,3)];
end

dy=coordtom(EW1,EW2);
dx=coordtom(NS1,NS2);
stepx=dx/scale_length(1); %m/pixel
stepy=dy/scale_length(2); %m/pixel
resolution = 0.5*(stepx+stepy);
dpu = inputs.idealresolution / resolution;
dpv = inputs.idealresolution  / resolution;
pu=inputs.searchwindowsize(1)/2 : dpu : size(A,2)-inputs.searchwindowsize(1)/2;
pv=inputs.searchwindowsize(1)/2: dpv : size(A,1)-inputs.searchwindowsize(1)/2;
[pu,pv]=meshgrid(pu,pv);

if any(inputs.searchwindowsize(:)>=max_d(:))||any(inputs.searchwindowsize(:)>=max_d(:))
    error('imgraft:inputerror','Search window size must be greater than template size.')
end

Np=numel(pu);
du=nan(size(pu));
dv=nan(size(pu));
pkr=nan(size(pu));
peakCorr=nan(size(pu));
meanAbsCorr=nan(size(pu));

if all(isnan(pu+pv))
    error('imgraft:inputerror','No points to track (pu/pv is all nans)')
end

if ~isfloat(A),A=im2float(A); end
if ~isfloat(B),B=im2float(B); end
gf=[1 0 -1]; %gf=[1 0;0 -1]; gf=[1 -1];
ofilter=@(A)exp(1i*atan2(imfilter(A,gf,'replicate'),imfilter(A,rot90(gf),'replicate')));
A=ofilter(A);B=ofilter(B);

if ~isreal(B)
    B=conj(B); %TODO: if you pass it orientation angles.
end


for ii=1:Np
    initialdupart=0;
    initialdvpart=0;
    p=[pu(ii) pv(ii)];
    SearchWidth=max_d(min(numel(max_d),ii))-1;
    SearchHeight=max_d(min(numel(max_d),ii))-1;
    TemplateWidth=inputs.searchwindowsize(min(numel(inputs.searchwindowsize),ii))-1;
    TemplateHeight=inputs.searchwindowsize(min(numel(inputs.searchwindowsize),ii))-1;
    Acenter=round(p) - mod([TemplateWidth TemplateHeight]/2,1);  % centre coordinate of template
    Bcenter=round(p+[initialdupart initialdvpart]) - mod([SearchWidth SearchHeight]/2,1); % centre coordinate of search region
    
    %what was actually used:
    pu(ii)=Acenter(1);
    pv(ii)=Acenter(2);
    initialdupart=Bcenter(1)-Acenter(1);
    initialdvpart=Bcenter(2)-Acenter(2);
    
    try
        BB=B( Bcenter(2)+(-SearchHeight/2:SearchHeight/2)  ,Bcenter(1)+(-SearchWidth/2:SearchWidth/2),:);
        if any(any(isnan(BB([1 end],[1 end]))))
            continue
        end
        AA=A( Acenter(2)+(-TemplateHeight/2:TemplateHeight/2),Acenter(1)+(-TemplateWidth/2:TemplateWidth/2),:);
        if any(any(isnan(AA([1 end],[1 end]))))
            continue
        end
    catch
        %out of bounds... continue (and thus return a nan for that point)
        continue
    end
    
    sT=size(AA); sB=size(BB);
    sz=sB+sT-1;
    fT=fft2(rot90(AA,2),sz(1),sz(2));
    fB=fft2(BB,sz(1),sz(2));
    C=real(ifft2(fB.*fT));
    %crop to central part not affected by edges.
    wkeep=(sB-sT)/2;
    c=(sz+1)/2;
    C=C(c(1)+(-wkeep(1):wkeep(1)),c(2)+(-wkeep(2):wkeep(2)));
    uu=-wkeep(2):wkeep(2);
    vv=-wkeep(1):wkeep(1);
    %TODO: allow for using max(C.*prior(uu,vv))
    [Cmax,mix]=max(C(:));
    [mix(1),mix(2)]=ind2sub(size(C),mix);
    
    meanAbsCorr(ii)=mean(abs(C(:))); %"noise" correlation level (we can accept that estimate even if we cannot find a good peak.)
    
    edgedist=min(abs([1-mix mix-size(C)]));
    
    %Slightly crude sub-pixel estimator
    switch edgedist  %SUBPIXEL METHOD:...
        case 0 %do-nothing....
            mix=[];% do not accept peaks on edge
        case 1 %3x3
            c=C(mix(1)+(-1:1),mix(2)+(-1:1));
            [uu,vv]=meshgrid(uu(mix(2)+(-1:1)),vv(mix(1)+(-1:1)));
            c=(c-mean(c([1:4 6:9])));c(c<0)=0; %simple and excellent performance for landsat test images...
            c=c./sum(c(:));
            mix(2)=sum(uu(:).*c(:));
            mix(1)=sum(vv(:).*c(:));
            
        otherwise %5x5....
            c=C(mix(1)+(-2:2),mix(2)+(-2:2));
            [uu,vv]=meshgrid(uu(mix(2)+(-2:2)),vv(mix(1)+(-2:2)));
            c=(c-mean(c([1:12 14:end])));c(c<0)=0;%simple and excellent performance for landsat test images...
            c=c./sum(c(:));
            mix(2)=sum(uu(:).*c(:));
            mix(1)=sum(vv(:).*c(:));
            
    end
    if ~isempty(mix)
        mix=mix([2 1]);
        du(ii)=mix(1)+initialdupart;
        dv(ii)=mix(2)+initialdvpart;
        peakCorr(ii)=Cmax;
    end
    
    % Find the signal to Noise ratio
    R2=C;
    
    if ~isnan(nanmax(R2(:)))
        try
            %consider changing this from try-catch to a simpler
            %distance check. The key here is the distance tot he
            %image edge. When peak is close to edge, this NaN
            %allocation may fail.
            R2(max_y1-3:max_y1+3,max_x1-3:max_x1+3)=NaN;
        catch
            R2(max(max_y1,1):min(max_y1,size(R2,1)),max(max_x1,1):min(max_x1,size(R2,2)))=NaN;
        end
        [p2_y2,p2_x2]=find(R2==max(R2(:)));
        
        if length(p2_x2)>1
            p2_x2=p2_x2(round(length(p2_x2)/2));
            p2_y2=p2_y2(round(length(p2_y2)/2));
        elseif isempty(p2_x2)
            
        end
        % signal to noise:
        pkr(ii)=C(max_y1,max_x1)/R2(p2_y2,p2_x2);
    else
        pkr(ii)=NaN;
    end
    
end

snr = peakCorr./meanAbsCorr;
