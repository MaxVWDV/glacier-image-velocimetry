function [mp  rho_p mu_p] = nancirc_moment(alpha, w, p, cent)

% [mp cbar sbar] = circ_moment(alpha, w, p, cent)
%   Calculates the complex p-th centred or non-centred moment 
%   of the angular data in angle.
%
%   Input:
%     alpha     sample of angles
%     [w        weightings in case of binned angle data]
%     [p        p-th moment to be computed, default is p=1]
%     [cent     if true, central moments are computed, default = false]
%
%   Output:
%     mp        complex p-th moment
%     rho_p     magnitude of the p-th moment
%     mu_p      angle of th p-th moment
%
%
%   References:
%     Statistical analysis of circular data, Fisher, p. 33/34
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de


alpha = alpha(:);

if nargin < 2 || isempty(p)
  w = ones(size(alpha));
else 
  w = w(:);
end

if nargin < 3 || isempty(p)
    p = 1;
end

if nargin < 4
  cent = false;
end

if cent
  theta = nancirc_mean(alpha,w);
  alpha = circ_dist(alpha,theta);
end
  

n = length(alpha);
cbar = nansum(cos(p*alpha'*w))/n;
sbar = nansum(sin(p*alpha'*w))/n;
mp = cbar + i*sbar;

rho_p = abs(mp);
mu_p = angle(mp);


