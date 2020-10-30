function r =  circ_dist(x,y)
%
% r = circ_dist(alpha, beta)
%   Pairwise difference x_i-y_i around the circle computed efficiently.
%
%   Input:
%     alpha      sample of linear random variable
%     beta       sample of linear random variable or one single angle
%
%   Output:
%     r       matrix with differences
%
% References:
%     Biostatistical Analysis, J. H. Zar, p. 651
%
% PHB 3/19/2009
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html


if size(x,2)>size(x,1)
  x = x';
end

if size(y,2)>size(y,1)
  y = y';
end

if length(x)~=length(y) && ~length(y)==1
  error('Input dimensions do not match.')
end

r = angle(exp(1i*x)./exp(1i*y));