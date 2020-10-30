function  out = imageprefilter (in, inputs)
%This function takes an initial image and filters it according to user
%inputted parameters to improve its potential for cross correlation.
%
%Inputs: 1- Input image
%        2- inputs array
%
%Outputs - Filtered image

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

%Parts of this funtion are partially based on the matlab 'PIVlab' toolbox. 
%Credit to the original authors for CLAHE and lowpass pre-processing.

%Note that the order of filtering can be modified. I have tested it out and
%found that this order typically works best, but if you e.g. wish to
%combine lowpass and Sobel you may wish to re-arrange.

%If the image has multiple bands, compress to one.
if size(in,3)>1
    temp = zeros(size(in,1),size(in,2));
    
    for i = 1:size(in,3)
        temp = temp + double(in(:,:,i));
    end
    
    in = temp;
end

%Preprocess:

x=1;
y=1;
width=size(in,2)-1;
height=size(in,1)-1;
in_roi=(in(y:y+height,x:x+width));
out=in;
out(y:y+height,x:x+width)=in_roi;
out=double(out);


%Perform Orientation filtering.

%Note that different filters can be used
%here, I tested many and found that the 45 degree filters (termed NAOF,
%described in more detail in the paper) seem to preserve feature uniqueness
%best. See Filch et al., 2002:
%http://www.bmva.org/bmvc/2002/papers/95/full_95.pdf for a description of
%orientation filtering and its advantages. The paper is very readable.

if inputs.NAOF == 1
    filter_1 = [-1 2 -1];
    filter_2 = [-1; 2; -1];
    filter_3 = [-1 0 0;0 2 0; 0 0 -1];
    filter_4 = [0 0 -1;0 2 0; -1 0 0]; 
    out = real(exp(1i*atan2(imfilter(out,filter_1,'replicate'),imfilter(out,rot90(filter_1),'replicate'))))...
        +real(exp(1i*atan2(imfilter(out,filter_2,'replicate'),imfilter(out,rot90(filter_2),'replicate'))))...
        +real(exp(1i*atan2(imfilter(out,filter_3,'replicate'),imfilter(out,rot90(filter_3),'replicate'))))...
        +real(exp(1i*atan2(imfilter(out,filter_4,'replicate'),imfilter(out,rot90(filter_4),'replicate'))));
end

in = out;

%Intensity Capping: a simple method to improve cross-correlation PIV results
%Uri Shavit Æ Ryan J. Lowe Æ Jonah V. Steinbuck
if inputs.intenscap == 1
    n = 2; 
    up_lim_im_1 = median(double(in(:))) + n*std2(in); % upper limit for image 1
    brightspots_im_1 = find(in > up_lim_im_1); % bright spots in image 1
    capped_im_1 = in; capped_im_1(brightspots_im_1) = up_lim_im_1; % capped image 1
    in=capped_im_1;
end

%CLAHE evens contrasts out throughout image. It is very good for shaded or
%cloudy images, but often not necessary when images are already orientation
%filtered.
if inputs.CLAHE == 1
    numberoftiles1=round(size(in,1)/inputs.CLAHEsize);
    numberoftiles2=round(size(in,2)/inputs.CLAHEsize);
    
    if numberoftiles1 < 2
        numberoftiles1=2;
    end
    
    if numberoftiles2 < 2
        numberoftiles2=2;
    end
    
    in=adapthisteq(in, 'NumTiles',[numberoftiles1 numberoftiles2], 'ClipLimit', 0.01, 'NBins', 256, 'Range', 'full', 'Distribution', 'uniform');
end

%Highpass filter
if inputs.hipass == 1
    h = fspecial('gaussian',inputs.hipasssize,inputs.hipasssize);
    in=double(in-(imfilter(in,h,'replicate')));
    in=in/max(max(in))*255;
end

%Sobel and Laplacian edge enhancing filters.
if inputs.sobel == 1
 in = SobelFilter(in,3);
end

if inputs.laplacian == 1
 in = LaplaceFilter(in,4);
end

out = in;