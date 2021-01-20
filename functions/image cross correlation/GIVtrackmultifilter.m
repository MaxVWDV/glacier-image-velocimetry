function img = GIVtrackmultifilter(img,fsize)
%Exit file is a matrix the size of the input with 0 where no outlier was
%detected and 1 where an outlier was detected. Used to filter out poorly
%matched velocity values.

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

    
%% Lowpass filter outlier detection

%Local, small filter area
nanX    = isnan(img);   %Find NaNs
img(nanX) = 0; %Convert NaN to zero
mask = strel('disk',fsize);
mask = double(mask.Neighborhood);
mask(fsize,fsize)=0; %Crop out central value
in2   = conv2(img,     mask, 'same') ./ ...
        conv2(~nanX, mask, 'same');
      
in_diff = abs(in2 - img);   
img(in_diff>stdfilt(img,mask)*1)=NaN; %cannot be more than 1SD different from regional mean
      
img(nanX) = NaN; %Restore NAN
    
