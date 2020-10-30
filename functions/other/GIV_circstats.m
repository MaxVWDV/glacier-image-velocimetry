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

if nargin<2 %No weighting
    mean_fd = circ_rad2ang(nancirc_mean(deg2rad(input),1));
    std_fd = circ_rad2ang(nancirc_std(deg2rad(input),1));

else %Weighting is applied
    mean_fd = circ_rad2ang(nancirc_mean(deg2rad(input),1,weighting));
    std_fd = circ_rad2ang(nancirc_std(deg2rad(input),1,weighting));

end



end

