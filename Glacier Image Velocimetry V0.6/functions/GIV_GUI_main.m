function GIV_GUI_main(inputs)
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



% %% Make sure to add functions to matlab path so that they are accessible
% addpath(genpath(pwd));
% 
% disp('Path Added.')
% %% Load the input parameters.
% 
% inputs = {};
% 
% [inputs]=loadinputs(inputs);  
% 
% disp('Parameters Loaded.')
%% Load image series

[images,inputs]=loadtseries(inputs);

%% Crop to mask

[images,inputs]=cropmask(images,inputs);

save_raw_array(images,inputs);

logo = imread('GIV_LOGO_SMALL.png');

message_1 = msgbox({'Images loaded and cropped to mask.';'Calculating glacier velocities via feature tracking of image pairs. Please be patient, this step may take a while.'},...
    'GIV is running','custom',logo);

%% Calculate velocity from image pairs

[images,inputs]=EFFICIENTimvelp_STABLE(images,inputs);

if exist('message_1', 'var')
  delete(message_1);
  clear('message_1');
end

save_raw_array(images,inputs);


message_2 = msgbox('Velocity pairs calculated. Filtering and saving entire dataset.',...
    'GIV is running','custom',logo);

%% Filter based on entire dataset 

[images,images_stack]=filtall(images,inputs);

%% Create monthly average velocities

[monthly_averages]=im2month(images,inputs,images_stack);

%% Save the data

[images] = save_images (images, inputs, images_stack, monthly_averages);

if exist('message_2', 'var')
  delete(message_2);
  clear('message_2');
end


message_3 = msgbox({'COMPLETE.'; 'ALL IMAGES AMD FILES HAVE BEEN FILTERED AND SAVED TO THE RESULTS FOLDER. SEE USER MANUAL FOR MORE DETAILS.'},...
    'GIV is running','custom',logo);


%% Open up the timeseries selection dialogue (you can come back to this later).
GIV_GUI_timeseries;