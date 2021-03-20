function [mu ul ll] = nancirc_mean(alpha, dim, w)
%
% mu = circ_mean(alpha, w)
%   Computes the mean direction for circular data.
%
%   Input:
%     alpha	sample of angles in radians
%     [w		weightings in case of binned angle data]
%
%   Output:
%     mu		mean direction
%     ul    upper 95% confidence limit
%     ll    lower 95% confidence limit 
%
% PHB 7/6/2008
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%   Topics in circular statistics, S. R. Jammalamadaka et al. 
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

% check vector size
% if size(alpha,2) > size(alpha,1)
% 	alpha = alpha';
% end

if nargin<3
  % if no specific weighting has been specified
  % assume no binning has taken place
	w = ones(size(alpha));
else
%   if size(w,2) > size(w,1)
%     w = w';
%   end 
end

% compute weighted sum of cos and sin of angles
% r = w'*exp(1i*alpha);
r = nancov_circ(w,exp(1i*alpha),dim); %*size(alpha,1)

% obtain mean by
mu = angle(r);

% % confidence limits if desired %Add file from toolbox if needed
% if nargout > 1
%   t = circ_confmean(alpha,0.05,w);
%   ul = mu + t;
%   ll = mu - t;
% end