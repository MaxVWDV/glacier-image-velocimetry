function save_raw_array(images,inputs)
%
%This functions saves the raw images array prior to filtering. This
%preserves the raw data and serves as a backup in case an error occurs
%later. Run portions of the GIV_main if an error occurs in filtering and
%you do not wish to recalculate image pairs.

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


%Check if Results folder exists yet
filename = strcat(inputs.folder,'/Results');
if ~exist(filename)
    mkdir(filename)
end

%Create main folder
mkdir(strcat(filename,'/',inputs.name))

%SAVE
if strcmpi(inputs.savearrays, 'Yes')
%Create subfolder for matlab arrays
mkdir(strcat(filename,'/',inputs.name,'/Initial data backup'))

%Save images, Inputs, Images_stack and Monthly_averages in this folder

save(strcat(filename,'/',inputs.name,'/Initial data backup/','Run Input Parameters'),'inputs');

save(strcat(filename,'/',inputs.name,'/Initial data backup/','Raw Images array'),'images','-v7.3');
end

