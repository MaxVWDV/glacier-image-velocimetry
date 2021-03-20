function md = circ_median(alpha,dim)
%
% mu = circ_median(alpha, w)
%   Computes the median direction for circular data.
%
%   Input:
%     alpha	sample of angles in radians
%
%   Output:
%     mu		mean direction
%
% PHB 3/19/2009
%
% References:
%   Biostatistical Analysis, J. H. Zar (26.6)
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

% if size(alpha,2) > size(alpha,1)
% 	alpha = alpha';
% end
alpha = mod(alpha,2*pi);
n = length(alpha);

m1 = (sum(circ_dist2(alpha,alpha)>0,dim));
m2 = (sum(circ_dist2(alpha,alpha)<0,dim));

dm = abs(m1-m2);
dm = abs(m1-m2);
% if mod(n,2)==1
  [m idx] = min(dm,[],dim);
% else
%   m = min(dm);
%   idx = find(dm==m,2);
% end
% if dim==1
%   [m idx] = min(dm,[],1);
% elseif dim==2
%   m = min(dm);
%   idx = find(dm==m);
% end

if m > 1
  warning('Ties detected.') %#ok<WNTAG>
end

% md = nancirc_mean(alpha(idx),dim);
md = nancirc_mean(alpha(idx),dim);
  
if abs(circ_dist(nancirc_mean(alpha,dim),md)) > abs(circ_dist(nancirc_mean(alpha,dim),md+pi))
  md = mod(md+pi,2*pi);
end

  