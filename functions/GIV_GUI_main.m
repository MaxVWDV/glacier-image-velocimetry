function GIV_GUI_main(inputs)
%
%This is the main wrapper script for GIV. It simply calls the following
%functions to calculate glacier velocities. Functions called are:
%
% loadtseries.m : load the images
%
% cropmask.m : crop the images to a mask and pre-process them
%
% GIVcore.m : perform the feature tracking
%
% filtall.m : filter the velocity maps and exlude outliers
%
% im2month.m : create monthly velocity maps
%
% save_images.m : create plots and save results
%
% An additional function, save_raw_array.m saves the results prior to
% filtering, such that they may be post-processed using different settings
% or recovered if the run crashes or is interrupted.

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


%% Load image series
% Loads all of the images from a folder.

[images,inputs]=loadtseries(inputs);


%% Crop to mask
% Crops and pre-processes the images

[images,inputs]=cropmask(images,inputs);
save_raw_array(images,inputs);

%Display message to let the user know that the pre-processing is completed.
logo = imread('GIV_LOGO_SMALL.png');
message_1 = msgbox({'Images loaded and cropped to mask.';'Calculating glacier velocities via feature tracking of image pairs. Please be patient, this step may take a while.'},...
    'GIV is running','custom',logo);


%% Calculate velocity from image pairs
%Perform the feature tracking. GIV will most likely spend ~90% of its
%runtime on this step.

[images,inputs]=GIVcore(images,inputs);

%Delete previous message box if has not been closed.
if exist('message_1', 'var')
    delete(message_1);
    clear('message_1');
end

%Save raw feature tracking results so that they can be recovered if
%necessary. Note that file sizes can be several GB for large datasets and
%you may wish to delete this file.
save_raw_array(images,inputs);

%Let the user know that feature tracking is completed.
message_2 = msgbox('Velocity pairs calculated. Filtering and saving entire dataset.',...
    'GIV is running','custom',logo);


%% Filter based on entire dataset
%Perform post-processing

[images,images_stack]=filtall(images,inputs);


%% Create monthly average velocities
%Resample to monthly maps

[monthly_averages]=im2month(images,inputs,images_stack);


%% Save the data
%Plot and save the data.

[images] = save_images (images, inputs, images_stack, monthly_averages);

%Delete previous message box if has not been closed.
if exist('message_2', 'var')
    delete(message_2);
    clear('message_2');
end

%Let the user know that GIV is finished.
message_3 = msgbox({'COMPLETE.'; 'ALL IMAGES AMD FILES HAVE BEEN FILTERED AND SAVED TO THE RESULTS FOLDER. SEE USER MANUAL FOR MORE DETAILS.'},...
    'GIV is running','custom',logo);


%% Open up the timeseries selection dialogue (you can come back to this later).
%Open timeseries ui for convenience. App users will have to open the
%interface this way, it can also be called from the following matlab
%function at any later point:

GIV_GUI_timeseries;