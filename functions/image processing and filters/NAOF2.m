function [im] = NAOF2(im)
%Anisotropic orientation filter. Input is a raw image, output is a filtered
%image.
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    %% GLACIER IMAGE VELOCIMETRY (GIV) %%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Code written by Max Van Wyk de Vries @ University of Minnesota
% %Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %Portions of this toolbox are based on a number of codes written by
% %previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
% %Credit and thanks are due to the authors of these toolboxes, and for
% %sharing their codes online. See the user manual for a full list of third 
% %party codes used here. Accordingly, you are free to share, edit and
% %add to this GIV code. Please give us credit if you do, and share your code 
% %with the same conditions as this.
% 
% % Read the associated paper here: 
% % doi.org/10.5194/tc-15-2115-2021
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         %Version 1.0, Spring-Summer 2021%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %Feel free to contact me at vanwy048@umn.edu%


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

%Recreate original features
im = cos(at1)+cos(pi()/2-at1)+...
    cos(at2)+cos(pi()/2-at2);

end

