function GIVruntime(inputs)
%This function calculates the number of possible image pairs in a given
%dataset. 

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


% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(inputs.folder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inputs.folder);
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
for y=inputs.minyear:inputs.maxyear;
    y = num2str(y);
    for m=inputs.minmonth:inputs.maxmonth;
        if m < 10
            m = strcat('0',num2str(m));
        else
           m = num2str(m); 
        end
        
        for d=inputs.minday:inputs.maxday
                        if d < 10
            d = strcat('0',num2str(d));
        else
           d = num2str(d); 
                        end
        if strcmpi(inputs.isgeotiff,'No')
            datejpg = strcat(y,m,d,'.jpg');
            datepng = strcat(y,m,d,'.png');
          if exist(fullfile(inputs.folder, datejpg),'file') 
            % read k onto first column
            % read date into second column
            % read the image into the kth position of the cell array on the
            % third column
            %create n_day, the number of days between different images
            n_day = datenum(str2num(y),str2num(m),str2num(d));
            %load n_day to fouth column
            images{k,1}=k;
            images{k,2}=(strcat(y,m,d));
            images{k,3}=(imread(fullfile(inputs.folder,datejpg)));
            images{k,4}=n_day;
            % increment k for the next iteration
            k=k+1;
          elseif exist(fullfile(inputs.folder, datepng),'file')
            % read k onto first column
            % read date into second column
            % read the image into the kth position of the cell array on the
            % third column
            %create n_day, the number of days between different images
            n_day = datenum(str2num(y),str2num(m),str2num(d));
            %load n_day to fouth column
            images{k,1}=k;
            images{k,2}=(strcat(y,m,d));
            images{k,3}=(imread(fullfile(inputs.folder,datepng)));
            images{k,4}=n_day;
            % increment k for the next iteration
            k=k+1;
                
          end
        else
            datetif = strcat(y,m,d,'.tif');
            
            if exist(fullfile(inputs.folder, datetif),'file') 
                n_day = datenum(str2num(y),str2num(m),str2num(d));
                %load n_day to fouth column
                images{k,1}=k;
                images{k,2}=(strcat(y,m,d));
                images{k,3}=(imread(fullfile(inputs.folder,datetif)));
                images{k,4}=n_day;
                % increment k for the next iteration
                k=k+1;
            end
        end
        end
      end
end

size_tocrop = size(images);
num_images = size_tocrop(1);
inputs.numimages = 'Number of Images + 1';
inputs.numimages = num_images;

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


%% Now calculate the time taken to calculate image pairs

%%%%%%%%%%%%%%%%%%% code that calculates number of image pairs available
%%%%%%%%%%%%%%%%%%% for different temporal oversampling

numpairs = zeros(inputs.numimages,3);
previous_number = 0;

for i = 1:inputs.numimages
    number_in_range = 0;
    meta_dum = 0;
    array_pos = 0;
    emptycount_inner = 0;
    emptycount_outer = 0;

for time_loop = 1:i  %for multisampling in time
   for inner_loop = 2:inputs.numimages-time_loop  %main loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images.
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    timestep = (B1_t-A1_t)/365;
    if timestep <= inputs.maxinterval && timestep >= inputs.mininterval
        number_in_range = number_in_range + 1;
    end
    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
    meta_dum = meta_dum + inputs.numimages-time_loop-1;
    array_pos = array_pos+1;
   end
end

numpairs(i,1) = i;
numpairs(i,2) = number_in_range;
numpairs(i,3) = number_in_range-previous_number;
previous_number = number_in_range;
end


%Line plot of total number of pairs vs t oversampling
figure; plot(numpairs(:,1),numpairs(:,2),'k')
    title('Total number of image pairs')
    xlabel('Temporal oversampling value') 
    ylabel('Number of pairs') 
% % %Line plot of total number of pairs vs t oversampling, only first 10
% % figure; plot(numpairs(1:10,1),numpairs(1:10,2),'k')
%Scatter plot of number of pairs for each oversampling
figure; bar(numpairs(:,1),numpairs(:,3),'k')
    title('Number of image pairs per individual oversample')
    xlabel('Temporal oversampling value') 
    ylabel('Number of pairs')
