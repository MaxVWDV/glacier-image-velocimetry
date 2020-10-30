function stats = circ_stats(alpha, w, d)
%
% stats = circ_stats(alpha, w)
%   Computes descriptive statistics for circular data.
%
%   Input:
%     alpha   sample of angles in radians
%     [w      weightings in case of binned angle data]
%     [d    spacing of bin centers for binned data, if supplied 
%           correction factor is used to correct for bias in 
%           estimation of r]
%
%   Output:
%     stats   structure containing descriptive statistics
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%   Topics in circular statistics, S. R. Jammalamadaka et al. 
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de 

alpha = alpha(:);
if nargin<2
  w = ones(size(alpha));
end

if nargin < 3
  d = 0;
end

% mean
stats.mean = circ_mean(alpha,w);

% median
if sum(w)==length(alpha)
  stats.median = circ_median(alpha);
else
  stats.median = NaN;
end

% variance
stats.var = circ_var(alpha,w,d);

% standard deviation
stats.std = circ_std(alpha,w,d);
stats.std_mardia = circ_std(alpha,w,d,'mardia');

% skewness
[stats.skewness stats.skewness_mardia] = circ_skewness(alpha,w);

% kurtosis
[stats.kurtosis stats.kurtosi_mardia] = circ_kurtosis(alpha,w);




