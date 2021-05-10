function [u,v] = GIVsnrfilt(u,v,snr,pkr,inputs)
%Filter the signal to noise ratio map to increase the confidence around
%high-confidence values
%
%GIVSNRFILT Inputs: u and v velocity components, signal to noise ratio,
%peak ratio and inputs .strct array
%
%           Outputs: filtered u and v components


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                   %% GLACIER IMAGE VELOCIMETRY (GIV) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Code written by Max Van Wyk de Vries @ University of Minnesota
%Credit to Ben Popken and Andrew Wickert for portions of the toolbox.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Portions of this toolbox are based on a number of codes written by
%previous authors, including matPIV, IMGRAFT, PIVLAB, M_Map and more.
%Credit and thanks are due to the authors of these toolboxes, and for
%sharing their codes online. See the user manual for a full list of third 
%party codes used here. Accordingly, you are free to share, edit and
%add to this GIV code. Please give us credit if you do, and share your code 
%with the same conditions as this.

% Read the associated paper here: 
% doi.org/10.5194/tc-15-2115-2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Version 1.0, Spring-Summer 2021%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                  %Feel free to contact me at vanwy048@umn.edu%

%% Signal to noise ratio

%Remove extreme values
snr(snr>100)=25;
pkr(pkr>20) = 5;

%Smooth signal to noise map and add it on, meaning that values
%close to 'good' pixels are kept, and groups of 'bad' pixels
%are excluded. Minimises loss of information.
snrsm = nanfillsm(snr,2,2);
snrextra = snrsm;
snrextra(snrsm<=(inputs.snr+0.5))=0;
snrextra(snrextra>0)=1;
snrextra = smooth_img(snrextra);
snrfn = snrextra.*snrsm;
snrfn(snrfn<=0.1) = 0;
snrfn(snrfn>0) = 1;
u = u.*snrfn;
u(u==0) = NaN;
v = v.*snrfn;
v(v==0) = NaN;
u(snr<inputs.snr) = NaN;
v(snr<inputs.snr) = NaN;


%% Peak ratio

%Smooth signal to noise map and add it on, meaning that values
%close to 'good' pixels are kept, and groups of 'bad' pixels
%are excluded. Minimises loss of information.
pkrsm = nanfillsm(pkr,2,2);
pkrextra = pkrsm;
pkrextra(pkrsm<=(inputs.pkr+0.5))=0;
pkrextra(pkrextra>0)=1;
pkrextra = smooth_img(pkrextra);
pkrfn = pkrextra.*pkrsm;
pkrfn(pkrfn<=0.1) = 0;
pkrfn(pkrfn>0) = 1;
u = u.*pkrfn;
u(u==0) = NaN;
v = v.*pkrfn;
v(v==0) = NaN;
u(pkr<inputs.pkr) = NaN;
v(pkr<inputs.pkr) = NaN;
end


function img = smooth_img(img)

% Make NaN values a very large negative number
smoothscale1 = round(0.1*size(img,1));
smoothscale2 = round(0.1*size(img,2));
mask    = ones(smoothscale1,smoothscale2);

%% Smooth the whole matrix
in_working = img;
in_working(isnan(img)) = -999;
    nanX    = isnan(img);
    img(nanX) = 0;
    img   = conv2(img,     mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');  
img(in_working==-999)=NaN;
end
