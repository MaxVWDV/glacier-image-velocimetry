function [im] = NAOF2(im)
%Anisotropic orientation filter. Input is a raw image, output is a filtered
%image.

% Create filter bank
filter_1 = [-1 2 -1];
filter_2 = [-1; 2; -1];
filter_3 = [-1 0 0;0 2 0; 0 0 -1];
filter_4 = [0 0 -1;0 2 0; -1 0 0];

%begin by creating filtered images
filt1 = conv2(im,filter_1,'same');
filt2 = conv2(im,filter_2,'same');
filt3 = conv2(im,filter_3,'same');
filt4 = conv2(im,filter_4,'same');

%Run 2-argument arctan
at1=atan2(filt1,filt2);
at2=atan2(filt3,filt4);

%Rereate original features
im = cos(at1)+cos(pi()/2-at1)+...
    cos(at2)+cos(pi()/2-at2);

end

