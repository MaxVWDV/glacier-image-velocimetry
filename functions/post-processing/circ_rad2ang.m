function alpha = circ_rad2ang(alpha)

% alpha = circ-rad2ang(alpha)
%   converts values in radians to values in degree (0-360)
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

alpha = alpha / pi *180;

pos = alpha<0;

alpha(pos)=360+alpha(pos);