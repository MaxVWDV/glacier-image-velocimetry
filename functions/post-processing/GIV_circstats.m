function [mean_fd,std_fd] = GIV_circstats(input,weighting)
%This function calculates the statistics (mean, standard deviation) of a 
% circular (anglular) dataset. This is done in degrees.
%
%Inputs: -1 input circular dataset to calculate statistics on. Stats will
%be calculated in the 'y' dimension (column, dim=1)
%
%Outputs: -Mean
%         -Standard deviation
%         -Maximum
%         -Minimum
%         -Median
%
%Note: This is based on functions by Philipp Berens's CircStat, modified to
%tolerate NaN values and multi-column matrices.
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

if nargin<2 %No weighting
    mean_fd = circ_rad2ang(nancirc_mean(deg2rad(input),1));
    std_fd = circ_rad2ang(nancirc_std(deg2rad(input),1));

else %Weighting is applied
    mean_fd = circ_rad2ang(nancirc_mean(deg2rad(input),1,weighting));
    std_fd = circ_rad2ang(nancirc_std(deg2rad(input),1,weighting));

end



end

