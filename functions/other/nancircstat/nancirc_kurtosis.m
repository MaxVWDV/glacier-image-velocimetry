function [k k0] = circ_kurtosis(alpha, w)

% [k k0] = circ_kurtosis(alpha,w)
%   Calculates a measure of angular kurtosis.
%
%   Input:
%     alpha     sample of angles
%     [w        weightings in case of binned angle data]
%
%   Output:
%     k         kurtosis (from Pewsey)
%
%   References:
%     Pewsey, Metrika, 2004
%     Fisher, Circular Statistics, p. 34
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de

alpha = alpha(:);

if nargin < 2
  w = ones(size(alpha));
else 
  w = w(:);
end

% compute mean direction
R = circ_var(alpha,w);
theta = nancirc_mean(alpha,w);
[foo rho2] = circ_moment(alpha,w,2,true);
[foo foo2 mu2] = circ_moment(alpha,w,2,false);

% compute skewness 
% k = w'*(cos(2*(circ_dist(alpha,theta))))/sum(w);
k = (nancov(w',(cos(2*(circ_dist(alpha,theta)))))*size(w,1))/sum(w);

k0 = (rho2*cos(circ_dist(mu2,2*theta))-R^4)/(1-R)^2;    % (formula 2.29)

