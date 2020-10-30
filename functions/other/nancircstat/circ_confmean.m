function t = circ_confmean(alpha, xi, w, d)
%
% t = circ_mean(alpha, xi, w, d)
%   Computes the confidence limits on the mean for circular data.
%
%   Input:
%     alpha	sample of angles in radians
%     [xi   (1-xi)-confidence limits are computed, default 0.05]
%     [w		number of incidences in case of binned angle data]
%     [d    spacing of bin centers for binned data, if supplied 
%           correction factor is used to correct for bias in 
%           estimation of r, in radians (!)]

%
%   Output:
%     t     mean +- d yields upper/lower (1-xi)% confidence limit
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

% set confidence limit size to default
if nargin<2 || isempty(xi)
  xi = 0.05;
end

if nargin<3
  % if no specific weighting has been specified
  % assume no binning has taken place
	w = ones(size(alpha));
else
%   if size(w,2) > size(w,1)
%     w = w';
%   end 
  
  if length(alpha)~=length(w)
    error('Input dimensions do not match.')
  end

end

if nargin<4
  % per default do not apply correct for binned data
  d = 0;
end

% compute ingredients for conf. lim.
r = circ_r(alpha,w,d);
n = sum(w);
R = n*r;
c2 = chi2inv((1-xi),1);

% check for resultant vector length and select appropriate formula
if r < .9 && r > sqrt(c2/2/n)
  t = sqrt((2*n*(2*R^2-n*c2))/(4*n-c2));  % equ. 26.24
elseif r >= .9
  t = sqrt(n^2-(n^2-R^2)*exp(c2/n));      % equ. 26.25
else 
  t = NaN;
  warning('Resultant vector does not allow to specify confidence limits on mean. \nResults may be wrong or inaccurate.');
end

% apply final transform
t = acos(t/R);
  



