function [images,inputs]=loadtseries(inputs)
%% load images
%
% Images to be tracked should be located in one single folder, and named
% with the following convention "yyyymmdd". This format is the most
% convinient for archiving time series, as images will sort into order.
%
%Any deviation from this naming convention will result in the images not
%being picked up correctly.
%
%Ideally at this point the images should be correctly georeferences
%(covering the same area). Downloaded Sentinel2 scenes should naturally
%have this property. Other images may need manually colocating in a GIS
%program prior to processing.
%
%
% Specify the folder where the files live. Copy paste the path from file
% explorer for example. An error message will be returned if it is somehow
% misspelt.
%
%Specify the first year of the timeseries (eg:2011) and the last year (eg:
%2017).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Toolbox written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Andrew Wickert and Ben Popken for advice and portions of the code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please also give credit if you do, and share your code 
%with the same conditions as this.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 0.6, Summer 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%


% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(inputs{1,2})
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inputs{1,2});
  uiwait(warndlg(errorMessage));
  return;
end

%The correct folder should now be located. The objective of the following
%loop is to read the images from the folder into an array named 'images'
%and extract relevant metadata.

images = {};   % create an empty cell array to store everything
%name columns for future clarity
images{1,1} = 'Image Number';
images{1,2} = 'Image Date';
images{1,3} = 'Image masked';
images{1,4} = 'Date code';
images{1,5} = 'Days from beginning';
images{1,6} = 'Interval in years';
k = 2;         % index into cell array for next read image

n_day = 0;
%load animate images
for y=inputs{2,2}:inputs{3,2};
    y = num2str(y);
    
    for m=inputs{4,2}:inputs{5,2};
        if m < 10
            m = strcat('0',num2str(m));
        else
           m = num2str(m); 
        end
        
        for d=inputs{6,2}:inputs{7,2}
                        if d < 10
            d = strcat('0',num2str(d));
        else
           d = num2str(d); 
        end
            datejpg = strcat(y,m,d,'.jpg');
            datepng = strcat(y,m,d,'.png');
            if exist(fullfile(inputs{1,2}, datejpg),'file') 
          % read k onto first column
          % read date into second column
          % read the image into the kth position of the cell array on the
          % third column
          %create n_day, the number of days between different images
          n_day = datenum(str2num(y),str2num(m),str2num(d));
          %load n_day to fouth column
          images{k,1}=k;
          images{k,2}=(strcat(y,m,d));
          images{k,3}=(imread(fullfile(inputs{1,2},datejpg)));
          images{k,4}=n_day;
          % increment k for the next iteration
          k=k+1;
            elseif exist(fullfile(inputs{1,2}, datepng),'file')
          % read k onto first column
          % read date into second column
          % read the image into the kth position of the cell array on the
          % third column
          %create n_day, the number of days between different images
          n_day = datenum(str2num(y),str2num(m),str2num(d));
          %load n_day to fouth column
          images{k,1}=k;
          images{k,2}=(strcat(y,m,d));
          images{k,3}=(imread(fullfile(inputs{1,2},datepng)));
          images{k,4}=n_day;
          % increment k for the next iteration
          k=k+1;
                
          end
                
        end
      end
end

size_tocrop = size(images);


num_images = size_tocrop(1);

inputs{34,1} = 'Number of Images + 1';
inputs{34,2} = num_images;

%this loop extracts the number of days that have passed for a given image
%since the first image in the series

l = 2;
for l = 2:(num_images)
    images{l,5} = images{l,4} - images{2,4};
    l=l+1;
end

%This loop extracts the number of days between succesive images from the
%previous result. This information is necessary to calculate ice velocity.
    
c = 2;
for c = 2:num_images
    if c < 3;
        images{c,6} = 0;
    else
    c_2 = c-1;
    images{c,6} = (images{c,5}(1) - images{c_2,5}(1))/365;
    end
    c = c+1;
    
end
    
% At this point all the data we need should be loaded into one array,
% called 'images'.
% We can call the images, image time spacing, etc from this array.
