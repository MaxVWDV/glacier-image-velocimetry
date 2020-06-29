function out = nanfill_timeandspace(in, inputs, nantolerance, smoothsize);
%This function fills in the NaN values in a given matrix where they are not
%adjacent to a large number of other NaN values. It then smooths the
%resulting matrix on a predefined size smoothing matrix.
% nantolerance range = 0 to 10
% smoothsize range 2 to 5
%
% if smoothsize == 2;
% mask    = [0 1 0; 1 0 1; 0 1 0 ]; 
% elseif smoothsize == 3;
% mask    = [1 1 1; 1 0 1; 1 1 1 ];
% elseif smoothsize == 4;
% mask    = [0 0 1 0 0; 0 1 1 1 0; 1 1 0 1 1; 0 1 1 1 0; 0 0 1 0 0];    
% elseif smoothsize == 5;
% mask    = [1 1 1 1 1; 1 1 1 1 1; 1 1 0 1 1; 1 1 1 1 1; 1 1 1 1 1];    

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

nanvalue = -1e10;

if smoothsize == 2;
numelts = 4;
elseif smoothsize == 3;
numelts = 8;
elseif smoothsize == 4;
numelts = 12;  
elseif smoothsize == 5;
numelts = 24;  
end

% Find the threshold value at which the average has too many nans

thresholdvalue = (nanvalue * nantolerance + (numelts-nantolerance) * 0)/numelts;

in_working = in;

in_working(isnan(in)) = nanvalue;

% Make sure size of mask is correct

if smoothsize == 2;
mask    = [0 1 0; 1 0 1; 0 1 0 ]; 
elseif smoothsize == 3;
mask    = [0 1 0;1 1 1; 1 0 1; 1 1 1; 0 1 0 ];
elseif smoothsize == 4;
mask    = [0 0 1 0 0 ;0 1 1 1 0 ;0 1 1 1 0; 1 1 1 1 1 ; 0 1 1 1 0; 0 1 1 1 0; 0 0 1 0 0 ];    
elseif smoothsize == 5;
mask    = [0 0 1 0 0 ;0 1 1 1 0 ;0 1 1 1 0;1 1 1 1 1 ;1 1 1 1 1 ; 1 1 1 1 1 ; 0 1 1 1 0; 0 1 1 1 0; 0 0 1 0 0 ];  
end

% Identify where too many NaNs are present

in_working   = conv2(in_working, mask, 'same')/numelts;

in_working(in_working<=thresholdvalue) = -999;

in_working(in_working~=-999) = 0;

in_working(in_working==-999) = 1;

in_nan = in;

in_nan(~isnan(in))=10;

%in with matrix 10 where not NaN and 1 where NaN

in_nan(isnan(in)) = 1;

in_nansbad = in_working.*in_nan;

%now this is a matrix with a 1 where NaNs are present AND are too close to
%too many other NaNs

in_nansbad(in_nansbad~=1)=0;

%Now lets find which ones are NOT too close

in_nan = zeros(size(in));

in_nan(isnan(in)) = 1;

%now this is a matrix with a 1 where NaNs are present AND are NOT close to
%too many other NaNs

in_goodnan = in_nan - in_nansbad;


%% Replace the NaNs

    nanX    = isnan(in);
    
    %start off by making NaNs zero so that the convolution is possible
    
    in(nanX) = 0;
    
means   = conv2(in,  mask, 'same') ./ ...
          conv2(~nanX, mask, 'same');
      
in(nanX) = means(nanX);

in(in_nansbad==1)=NaN;

out = in;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DO NOT SMOOTH HERE

% % % %% Smooth the whole matrix
% % % 
% % % in_working = in;
% % % 
% % % in_working(isnan(in)) = -999;
% % % 
% % % in_working(in_goodnan==1) = 0;
% % % 
% % %     nanX    = isnan(in);
% % %     in(nanX) = 0;
% % %     out   = conv2(in,     mask, 'same') ./ ...
% % %           conv2(~nanX, mask, 'same');  
% % % 
% % % out(in_working==-999)=NaN;
% % % 
% % % out(in_nansbad==1)=NaN;





