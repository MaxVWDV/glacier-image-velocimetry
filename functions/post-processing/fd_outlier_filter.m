function [out_limits_fd] = fd_outlier_filter(full_fd,mean_fd,std_fd,num_stand_dev)
%Input = multi-array of flow directions
%        mean flow direction
%        stv of flow direction
%Output = binary array with location of outliers
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    %% GLACIER IMAGE VELOCIMETRY (GIV) %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Code written by Max Van Wyk de Vries @ University of Minnesota
% %Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Portions of this toolbox are based on a number of codes written by
% %previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
% %Credit and thanks are due to the authors of these toolboxes, and for
% %sharing their codes online. See the user manual for a full list of third
% %party codes used here. Accordingly, you are free to share, edit and
% %add to this GIV code. Please give us credit if you do, and share your code
% %with the same conditions as this.
%
% % Read the associated paper here:
% % doi.org/10.5194/tc-15-2115-2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %Version 1.0, Spring-Summer 2021%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %Feel free to contact me at vanwy048@umn.edu%



%Calculate the radial distance between each measurement and the mean flow
%direction

fd_dist = min(abs(full_fd-mean_fd),360-abs(full_fd-mean_fd));

% Create stv outlier detection matrix

fd_detection = (repmat(std_fd,size(full_fd,1),1)*num_stand_dev);


%Identify regions where the radial distance is larger than XX times the stv

out_limits_fd = double(fd_dist>fd_detection);

%Remove any pixels with a stv*num_stand_dev larger than 180 (in this case,
%there are no outliers

out_limits_fd = out_limits_fd-double(fd_detection>=180);

