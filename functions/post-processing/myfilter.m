function out = myfilter(in, inputs)
%Exit file is a matrix the size of the input with 0 where no outlier was
%detected and 1 where an outlier was detected. Used to filter out poorly
%matched velocity values.
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

out = zeros(size(in));
 %% Maximum velocity filter

 %Firstly points with too fast velocities
ofilter = out;
out(in>inputs.maxvel) = 1;
    
%% Lowpass filter outlier detection

%Local, small filter area
nanX    = isnan(in);
in(nanX) = 0;
mask    = [0 1 0; 1 0 1; 0 1 0];
in2   = conv2(in,     mask, 'same') ./ ...
        conv2(~nanX, mask, 'same');
      
in_diff = abs(in2 - in)./in;
out(in_diff>0.3)=1; %cannot be more than 30% different from mean of immediate neighbours
      
%Larger area filter
nanX    = isnan(in);
in(nanX) = 0;
mask    = [0 0 0 1 0 0 0; 0 0 1 1 1 0 0; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 1 1 1 1 1 1 1; 0 0 1 1 1 0 0; 0 0 0 1 0 0 0];
in2   = conv2(in,     mask, 'same') ./ ...
        conv2(~nanX, mask, 'same');
      
in_diff = abs(in2 - in)./in;   
out(in_diff>1.00)=1; %cannot be more than 100% different from regional mean
      
%% Moving median and percentile detection (if needed)
% % 
% %     Out_param1 =~isoutlier(in,'movmedian',5);
% % 
% %     Out_param2 =~isoutlier(in,'percentiles',[0 100]); 
% %          
% %     out(Out_param1 == 0) = 1;
% %     
% %     out(Out_param2 == 0) = 1;
% %   
    
out(in==0)=0;
    
