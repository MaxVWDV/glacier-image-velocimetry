function out = smooth_snr(in, inputs);
%This function smooths the signal to noise ratio matrixes. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Toolbox written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Andrew Wickert and Ben Popken for advice and portions of the code.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please also give credit if you do, and share your code 
%with the same conditions as this.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 0.6, Summer 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%


%% Find the right NaNs

% Make NaN values a very large negative number

smoothscale1 = round(0.1*size(in,1));
smoothscale2 = round(0.1*size(in,2));



mask    = ones(smoothscale1,smoothscale2);


%% Smooth the whole matrix

in_working = in;

in_working(isnan(in)) = -999;

    nanX    = isnan(in);
    in(nanX) = 0;
    out   = conv2(in,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  

out(in_working==-999)=NaN;






