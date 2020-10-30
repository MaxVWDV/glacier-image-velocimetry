function [mask] = make_mask(smoothsize)
% generates a neighborhood kernel in the form of a diamond,
% though excludes the central pixel
% input:
% smoothsize - integer value
% output:
% mask - logical array
%
%Note: this function was contributed by Anonymous Reviewer 2 of The
%Cryosphere manuscript. We thank them for a very thoughtful and
%constructive review.

if nargin<1, smoothsize = 3; end
mask_radius = floor(smoothsize/2);
mask = strel('diamond', mask_radius); % make a diamond shape
mask = double(mask.Neighborhood); %added a 'double'
mask(mask_radius+1, mask_radius+1) = 0; % exclude the central element
end