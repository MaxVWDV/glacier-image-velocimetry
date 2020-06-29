function GIVruntime(inputs)
%This function calculates the number of possible image pairs in a given
%dataset. 

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


% %% Make sure to add functions to matlab path so that they are accessible
% addpath(genpath(pwd));
% 
% disp('Path Added.')
% %% Load the input parameters.
% % 
% inputs = {};
% % 
% [inputs]=loadinputs(inputs);  
% 
% disp('Parameters Loaded.');
%% Load image series

%% load images
%
% Images to be tracked should be located in one single folder, and named
% with the following convention "yyyymmdd". This format is the most
% convinient for archiving time series, as images will sort into order.
%
%Any deviation from this naming convention will result in the images not
%being picked up correctly.
%
%Ideally at this point the images should be correctly georeferences
%(covering the same area). Downloaded Sentinel2 scenes should naturally
%have this property. Other images may need manually colocating in a GIS
%program prior to processing.
%
%
% Specify the folder where the files live. Copy paste the path from file
% explorer for example. An error message will be returned if it is somehow
% misspelt.
%
%Specify the first year of the timeseries (eg:2011) and the last year (eg:
%2017).


% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isdir(inputs{1,2})
  errorMessage = sprintf('Error: The following folder does not exist:\n%s', inputs{1,2});
  uiwait(warndlg(errorMessage));
  return;
end

%The correct folder should now be located. The objective of the following
%loop is to read the images from the folder into an array named 'images'
%and extract relevant metadata.

images = {};   % create an empty cell array to store everything
%name columns for future clarity
images{1,1} = 'Image Number';
images{1,2} = 'Image Date';
images{1,3} = 'Image masked';
images{1,4} = 'Date code';
images{1,5} = 'Days from beginning';
images{1,6} = 'Interval in years';
k = 2;         % index into cell array for next read image

n_day = 0;
%load animate images
for y=inputs{2,2}:inputs{3,2};
    y = num2str(y);
    
    for m=inputs{4,2}:inputs{5,2};
        if m < 10
            m = strcat('0',num2str(m));
        else
           m = num2str(m); 
        end
        
        for d=inputs{6,2}:inputs{7,2}
                        if d < 10
            d = strcat('0',num2str(d));
        else
           d = num2str(d); 
        end
            datejpg = strcat(y,m,d,'.jpg');
            datepng = strcat(y,m,d,'.png');
            if exist(fullfile(inputs{1,2}, datejpg),'file') 
          % read k onto first column
          % read date into second column
          % read the image into the kth position of the cell array on the
          % third column
          %create n_day, the number of days between different images
          n_day = datenum(str2num(y),str2num(m),str2num(d));
          %load n_day to fouth column
          images{k,1}=k;
          images{k,2}=(strcat(y,m,d));
          images{k,3}=(imread(fullfile(inputs{1,2},datejpg)));
          images{k,4}=n_day;
          % increment k for the next iteration
          k=k+1;
            elseif exist(fullfile(inputs{1,2}, datepng),'file')
          % read k onto first column
          % read date into second column
          % read the image into the kth position of the cell array on the
          % third column
          %create n_day, the number of days between different images
          n_day = datenum(str2num(y),str2num(m),str2num(d));
          %load n_day to fouth column
          images{k,1}=k;
          images{k,2}=(strcat(y,m,d));
          images{k,3}=(imread(fullfile(inputs{1,2},datepng)));
          images{k,4}=n_day;
          % increment k for the next iteration
          k=k+1;
                
          end
                
        end
      end
end

size_tocrop = size(images);


num_images = size_tocrop(1);

inputs{34,1} = 'Number of Images + 1';
inputs{34,2} = num_images;

%this loop extracts the number of days that have passed for a given image
%since the first image in the series

l = 2;
for l = 2:(num_images)
    images{l,5} = images{l,4} - images{2,4};
    l=l+1;
end

%This loop extracts the number of days between succesive images from the
%previous result. This information is necessary to calculate ice velocity.
    
c = 2;
for c = 2:num_images
    if c < 3;
        images{c,6} = 0;
    else
    c_2 = c-1;
    images{c,6} = (images{c,5}(1) - images{c_2,5}(1))/365;
    end
    c = c+1;
    
end
    
% At this point all the data we need should be loaded into one array,
% called 'images'.
% We can call the images, image time spacing, etc from this array.

%% Crop to mask

% [images]=cropmask(images,inputs);

% logo = imread('GIV_LOGO_SMALL.png');
% 
% message_1 = msgbox({'Images loaded and cropped to mask.';'Calculating glacier velocities via feature tracking of image pairs. Please be patient, this step may take a while.'},...
%     'GIV is running','custom',logo);

%% Now calculate the time taken to calculate image pairs


%%%%%%%%%%%%%%%%%%% code that calculates number of image pairs available
%%%%%%%%%%%%%%%%%%% for different temporal oversampling



numpairs = zeros(inputs{34,2},3);

previous_number = 0;

for i = 1:inputs{34,2}

number_in_range = 0;

meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

for time_loop = 1:i  %for multisampling in time
   for inner_loop = 2:inputs{34,2}-time_loop  %main loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images, if too long then do not run
    %templatematch.
    
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    
    timestep = (B1_t-A1_t)/365;
       
    if timestep <= inputs{21,2} && timestep >= inputs{22,2}

    number_in_range = number_in_range + 1;

   end
    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
    meta_dum = meta_dum + inputs{34,2}-time_loop-1;


array_pos = array_pos+1;
   end
end

numpairs(i,1) = i;

numpairs(i,2) = number_in_range;

numpairs(i,3) = number_in_range-previous_number;

previous_number = number_in_range;

end


% % % % % 
% % % % % 
% % % % % %% Time tests for different settings
% % % % % 
% % % % % 
% % % % % scale_length = size(images{2,3});
% % % % % 
% % % % %     %Calculate resolution of image
% % % % %     NS1 = [inputs{14,2},inputs{16,2}];
% % % % %     NS2 = [inputs{15,2},inputs{16,2}];
% % % % %     EW1 = [inputs{14,2},inputs{16,2}];
% % % % %     EW2 = [inputs{14,2},inputs{17,2}];
% % % % %     
% % % % %     dy=coordtom(EW1,EW2);
% % % % %     dx=coordtom(NS1,NS2);
% % % % %     
% % % % %     stepx=dx/scale_length(1); %m/pixel
% % % % %     stepy=dy/scale_length(2); %m/pixel
% % % % %     
% % % % %     mean_resolution = 0.5*(stepx+stepy);
% % % % % 
% % % % % 
% % % % % A1 = images{2,3};
% % % % % B1 = images{3,3};
% % % % % dt = ((images{3,5})-(images{2,5}))/365;
% % % % % 
% % % % % 
% % % % % if mean_resolution > 100
% % % % %     errordlg('Your image resolution is either coarser than 100m (and likely not suitable for feature tracking) or your coordinates have been entered wrong.')
% % % % % end
% % % % % %%%%%%%% SINGLE PASS 200
% % % % % 
% % % % % inputs{38,2} = 200;
% % % % % inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;
% % % % % 
% % % % % 
% % % % % sp200time = tic;
% % % % % 
% % % % %     %set maximum expected velocity 
% % % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % % %     
% % % % %     % make minimum limit, else can become too small if close images.
% % % % %     if max_expected < inputs{23,2}
% % % % %     max_d = inputs{23,2};
% % % % %     else
% % % % %     max_d = max_expected;
% % % % %     end
% % % % %         
% % % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d);
% % % % %     
% % % % %         snr = C./Cnoise;
% % % % %         
% % % % %             snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % % 
% % % % %         
% % % % %     
% % % % % sp200 = toc(sp200time);
% % % % % 
% % % % % 
% % % % % %%%%%%%% MULTI PASS 200
% % % % % 
% % % % % mp200time =tic;
% % % % % 
% % % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % 
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %     
% % % % %     
% % % % % mp200 = toc(mp200time);
% % % % % 
% % % % % %%%%%%%% SINGLE PASS 100
% % % % % 
% % % % % inputs{38,2} = 100;
% % % % % inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;
% % % % % 
% % % % % 
% % % % % sp100time =tic;
% % % % % 
% % % % %     %set maximum expected velocity 
% % % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % % %     
% % % % %     % make minimum limit, else can become too small if close images.
% % % % %     if max_expected < inputs{23,2}
% % % % %     max_d = inputs{23,2};
% % % % %     else
% % % % %     max_d = max_expected;
% % % % %     end
% % % % %         
% % % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d);
% % % % %     
% % % % %         snr = C./Cnoise;
% % % % %         
% % % % %             snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % % sp100 = toc(sp100time);
% % % % % 
% % % % % %%%%%%%% MULTI PASS 100
% % % % % 
% % % % % mp100time = tic;
% % % % % 
% % % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % 
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %     
% % % % %     
% % % % % mp100 = toc(mp100time);
% % % % % 
% % % % % 
% % % % % 
% % % % % if mean_resolution < 50
% % % % % %%%%%%%% SINGLE PASS 50
% % % % % 
% % % % % inputs{38,2}=50;
% % % % % inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;
% % % % % 
% % % % % 
% % % % % sp50time =tic;
% % % % % 
% % % % %     %set maximum expected velocity 
% % % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % % %     
% % % % %     % make minimum limit, else can become too small if close images.
% % % % %     if max_expected < inputs{23,2}
% % % % %     max_d = inputs{23,2};
% % % % %     else
% % % % %     max_d = max_expected;
% % % % %     end
% % % % %         
% % % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d);
% % % % %     
% % % % %         snr = C./Cnoise;
% % % % %         
% % % % %             snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % % 
% % % % % sp50 = toc(sp50time);
% % % % % 
% % % % % %%%%%%%% MULTI PASS 50
% % % % % 
% % % % % mp50time =tic;
% % % % % 
% % % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % 
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %     
% % % % %     
% % % % % mp50 = toc(mp50time);
% % % % % 
% % % % % 
% % % % % if mean_resolution < 25
% % % % % %%%%%%%% SINGLE PASS 25
% % % % % 
% % % % % inputs{38,2} = 25;
% % % % % inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;
% % % % % 
% % % % % 
% % % % % sp25time =tic;
% % % % % 
% % % % %     %set maximum expected velocity 
% % % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % % %     
% % % % %     % make minimum limit, else can become too small if close images.
% % % % %     if max_expected < inputs{23,2}
% % % % %     max_d = inputs{23,2};
% % % % %     else
% % % % %     max_d = max_expected;
% % % % %     end
% % % % %         
% % % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d);
% % % % %     
% % % % %         snr = C./Cnoise;
% % % % %         
% % % % %             snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % % sp25 = toc(sp25time);
% % % % % 
% % % % % %%%%%%%% MULTI PASS 25
% % % % % 
% % % % % mp25time =tic;
% % % % % 
% % % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % 
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %     
% % % % %     
% % % % % mp25 = toc(mp25time);
% % % % % 
% % % % % end
% % % % % end
% % % % % 
% % % % % if strcmpi(inputs{30,2}, 'Yes')
% % % % %     
% % % % % core_info = evalc('feature(''numcores'')');
% % % % % Num_cores = ans;
% % % % % clear ans
% % % % % clear core_info
% % % % % 
% % % % % %Make fake parralel chip to save time
% % % % % parralel_chip = {};
% % % % % for i = 1:Num_cores
% % % % %     parralel_chip{i,1} = A1;
% % % % %     parralel_chip{i,2} = B1;
% % % % %     parralel_chip{i,3} = dt;
% % % % % end
% % % % %     
% % % % % inputs{38,2}=200;
% % % % % inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;
% % % % % 
% % % % % 
% % % % % %%%%%%% Test PARRALEL SINGLE PASS (slow to do too many, so will just test
% % % % % %%%%%%% coarsest resolution and scale)
% % % % % 
% % % % % 
% % % % % sp200timepara =tic;
% % % % % 
% % % % % 
% % % % % parfor inner_loop_parralel = 1:size(parralel_chip,1)
% % % % %          
% % % % %     A1= parralel_chip{inner_loop_parralel,1};   
% % % % %         
% % % % %     B1= parralel_chip{inner_loop_parralel,2};   
% % % % %     
% % % % %     dt = parralel_chip{inner_loop_parralel,3};    
% % % % %     
% % % % %        %This function will correlate the two images.      
% % % % %     
% % % % %         
% % % % %     %set maximum expected velocity 
% % % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % % %     
% % % % %     % make minimum limit, else can become too small if close images.
% % % % %     if max_expected < inputs{23,2}
% % % % %     max_d = inputs{23,2};
% % % % %     else
% % % % %     max_d = max_expected;
% % % % %     end
% % % % %         
% % % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d);
% % % % % 
% % % % %     
% % % % %     %%   Convert to velocity and filter it
% % % % %     
% % % % %     
% % % % %     snr = C./Cnoise;
% % % % %     
% % % % %     
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % % % % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %    
% % % % %     %import results to master index before loop continues. Name first
% % % % %     %row of each.
% % % % %     newcol1{inner_loop_parralel,1}=V;
% % % % % 
% % % % %     newcol2{inner_loop_parralel,1}=fd;       
% % % % %         
% % % % %     end %parfor end
% % % % %     
% % % % %     
% % % % % sp200para = toc(sp200timepara);
% % % % % 
% % % % % sp200para = sp200para/Num_cores;
% % % % % 
% % % % % 
% % % % % %%%%%%% Test PARRALEL MULTI PASS (slow to do too many, so will just test
% % % % % %%%%%%% coarsest resolution and scale)
% % % % % 
% % % % % 
% % % % % mp200timepara =tic;
% % % % % 
% % % % % parfor inner_loop_parralel = 1:size(parralel_chip,1)
% % % % %          
% % % % %     A1= parralel_chip{inner_loop_parralel,1};   
% % % % %         
% % % % %     B1= parralel_chip{inner_loop_parralel,2};   
% % % % %     
% % % % %     dt = parralel_chip{inner_loop_parralel,3};    
% % % % %     
% % % % %        %This function will correlate the two images.      
% % % % %     
% % % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % 
% % % % %     
% % % % %     %%   Convert to velocity and filter it
% % % % %     
% % % % % 
% % % % %        
% % % % %     snrsm = nanfillsm(snr,inputs,2,2);
% % % % %     
% % % % %     snrextra = snrsm;
% % % % %     snrextra(snrsm<=(inputs{36,2}+0.5))=0;
% % % % %     snrextra(snrextra>0)=1;
% % % % %     
% % % % %     snrextra = smooth_snr(snrextra, inputs);
% % % % %     
% % % % %     
% % % % %     snrfn = snrextra.*snrsm;
% % % % %     
% % % % %     snrfn(snrfn<=0.1) = 0;
% % % % %     snrfn(snrfn>0) = 1;
% % % % %     
% % % % %     u = u.*snrfn;
% % % % %     u(u==0) = NaN;
% % % % %     
% % % % %         v = v.*snrfn;
% % % % %     v(v==0) = NaN;
% % % % %         
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction and Velocity
% % % % % 
% % % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % % %     
% % % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % % %     
% % % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % % %         
% % % % %     fd(fd>inputs{37,2})=-1;    
% % % % %     fd(fd<inputs{10,2})=-1;     
% % % % % 
% % % % %     
% % % % %     V(fd==-1)=NaN;
% % % % %     fd(fd==-1)=NaN;
% % % % % 
% % % % %     end
% % % % %     
% % % % %     %Remove areas with unrealistic values
% % % % %     
% % % % %     %Firstly points with too fast velocities
% % % % %     filtermask = myfilter(V, inputs);
% % % % % 
% % % % %     V(filtermask == 1) = NaN;
% % % % %     
% % % % %     fd(filtermask == 1) = NaN;
% % % % %     
% % % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % % %     %infill the gaps created and prior non-tracked values without creating
% % % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % % %     %to make an interpolation, it will not be done.
% % % % %     
% % % % %     % First pass with a small window size and higher tolerance to fill
% % % % %     % small gaps:
% % % % %     
% % % % %     V = nanfillsm(V,inputs,2,2);
% % % % %     
% % % % %     %Second pass with larger window size and lower tolerance to fill any
% % % % %     %remaining larger holes:
% % % % %     
% % % % % %     V = nanfillsm(V,inputs,3,5);
% % % % %         
% % % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % % %     
% % % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % % 
% % % % % %     %flip it
% % % % % %     %make the mask the right size and flip it to the right orientation
% % % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % % %     end
% % % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %    
% % % % %     %import results to master index before loop continues. Name first
% % % % %     %row of each.
% % % % %     newcol1{inner_loop_parralel,1}=V;
% % % % % 
% % % % %     newcol2{inner_loop_parralel,1}=fd;       
% % % % %         
% % % % %     end %parfor end
% % % % %     
% % % % %     
% % % % % mp200para = toc(mp200timepara);
% % % % % mp200para = mp200para/Num_cores;
% % % % % 
% % % % % end
% % % % % 
% % % % % parralel_ratio_sp = sp200para/sp200;
% % % % % parralel_ratio_mp = mp200para/mp200;
% % % % % 
% % % % % %%Work out timing
% % % % % timing_matrix = [];
% % % % % 
% % % % % timing_matrix(:,1) = numpairs(:,2)*sp200;
% % % % % timing_matrix(:,2) = numpairs(:,2)*mp200;
% % % % % timing_matrix(:,3) = numpairs(:,2)*sp100;
% % % % % timing_matrix(:,4) = numpairs(:,2)*mp100;
% % % % % if mean_resolution < 50
% % % % % 
% % % % % timing_matrix(:,5) = numpairs(:,2)*sp50;
% % % % % timing_matrix(:,6) = numpairs(:,2)*mp50;
% % % % % if mean_resolution < 25
% % % % % 
% % % % % timing_matrix(:,7) = numpairs(:,2)*sp25;
% % % % % timing_matrix(:,8) = numpairs(:,2)*mp25;
% % % % % 
% % % % % end
% % % % % end
% % % % % 
% % % % % timing_matrix(:,9) = numpairs(:,2)*sp200*parralel_ratio_sp;
% % % % % timing_matrix(:,10) = numpairs(:,2)*mp200*parralel_ratio_mp;
% % % % % timing_matrix(:,11) = numpairs(:,2)*sp100*parralel_ratio_sp;
% % % % % timing_matrix(:,12) = numpairs(:,2)*mp100*parralel_ratio_mp;
% % % % % if mean_resolution < 50
% % % % % 
% % % % % timing_matrix(:,13) = numpairs(:,2)*sp50*parralel_ratio_sp;
% % % % % timing_matrix(:,14) = numpairs(:,2)*mp50*parralel_ratio_mp;
% % % % % if mean_resolution < 25
% % % % % 
% % % % % timing_matrix(:,15) = numpairs(:,2)*sp25*parralel_ratio_sp;
% % % % % timing_matrix(:,16) = numpairs(:,2)*mp25*parralel_ratio_mp;
% % % % % 
% % % % % end
% % % % % end


%Line plot of total number of pairs vs t oversampling
figure; plot(numpairs(:,1),numpairs(:,2),'k')
    title('Total number of image pairs')
    xlabel('Temporal oversampling value') 
    ylabel('Number of pairs') 
% % %Line plot of total number of pairs vs t oversampling, only first 10
% % figure; plot(numpairs(1:10,1),numpairs(1:10,2),'k')
%Scatter plot of number of pairs for each oversampling
figure; bar(numpairs(:,1),numpairs(:,3),'k')
    title('Number of image pairs per individual oversample')
    xlabel('Temporal oversampling value') 
    ylabel('Number of pairs')
    
    
    
    
% % % % % % % %Scatter plot of number of pairs for each oversampling, only first 10
% % % % % % % figure; scatter(numpairs(1:10,1),numpairs(1:10,3),'k','Marker','+')
% % % % % %Lineplot of time oversampling vs model runtime 
% % % % % %Single pass vs multipass
% % % % % if max(timing_matrix,'all')<300 %less than 5 mins, plot in seconds
% % % % %     figure;
% % % % %     hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,1),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,3),'Color','b','DisplayName','100m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,5),'Color','g','DisplayName','50m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,7),'Color','r','DisplayName','25m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     legend
% % % % %     title('Runtime of single pass and multipass runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (seconds)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %     %parralel vs non parralel
% % % % % 
% % % % %     figure;
% % % % %     hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,10),'Color','k','LineStyle',':','DisplayName','200m resolution, multi pass (parralel)'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,12),'Color','b','LineStyle',':','DisplayName','100m resolution, multi pass (parralel)'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,14),'Color','g','LineStyle',':','DisplayName','50m resolution, multi pass (parralel)')    ; hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,16),'Color','r','LineStyle',':','DisplayName','25m resolution, multi pass (parralel)')    ; hold on
% % % % %     legend
% % % % %     title('Runtime parralel and non-parralel runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (seconds)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %     
% % % % % elseif max(timing_matrix,'all')>18000 %if more than 5 hours, convert to hours
% % % % %     timing_matrix = timing_matrix/3600;
% % % % %         figure;
% % % % %         hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,1),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,3),'Color','b','DisplayName','100m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,5),'Color','g','DisplayName','50m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,7),'Color','r','DisplayName','25m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     legend
% % % % %     title('Runtime of single pass and multipass runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (hours)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %     %parralel vs non parralel
% % % % % 
% % % % %     figure;
% % % % %     hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,10),'Color','k','LineStyle',':','DisplayName','200m resolution, multi pass (parralel)'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,12),'Color','b','LineStyle',':','DisplayName','100m resolution, multi pass (parralel)'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,14),'Color','g','LineStyle',':','DisplayName','50m resolution, multi pass (parralel)')    ; hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,16),'Color','r','LineStyle',':','DisplayName','25m resolution, multi pass (parralel)')    ; hold on
% % % % %     legend
% % % % %     title('Runtime parralel and non-parralel runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (hours)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %     
% % % % % else
% % % % %  
% % % % %     timing_matrix = timing_matrix/60;
% % % % %         figure;
% % % % %         hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,1),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,3),'Color','b','DisplayName','100m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,5),'Color','g','DisplayName','50m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,7),'Color','r','DisplayName','25m resolution, single pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     legend
% % % % %     title('Runtime of single pass and multipass runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (minutes)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %     %parralel vs non parralel
% % % % % 
% % % % %     figure;
% % % % %     hA = gca;
% % % % %     plot(numpairs(:,1),timing_matrix(:,2),'Color','k','DisplayName','200m resolution, single pass') ; hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,10),'Color','k','LineStyle',':','DisplayName','200m resolution, multi pass (parralel)'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,4),'Color','b','DisplayName','100m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,12),'Color','b','LineStyle',':','DisplayName','100m resolution, multi pass (parralel)'); hold on
% % % % %     if mean_resolution < 50
% % % % %     plot(numpairs(:,1),timing_matrix(:,6),'Color','g','DisplayName','50m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,14),'Color','g','LineStyle',':','DisplayName','50m resolution, multi pass (parralel)')    ; hold on
% % % % %     if mean_resolution < 25
% % % % %     plot(numpairs(:,1),timing_matrix(:,8),'Color','r','DisplayName','25m resolution, multi pass'); hold on
% % % % %     plot(numpairs(:,1),timing_matrix(:,16),'Color','r','LineStyle',':','DisplayName','25m resolution, multi pass (parralel)')    ; hold on
% % % % %     legend
% % % % %     title('Runtime parralel and non-parralel runs')
% % % % %     xlabel('Temporal oversampling value') 
% % % % %     ylabel('Runtime (minutes)') 
% % % % %     set(hA,'FontUnits','points','FontWeight','normal', ...
% % % % %     'FontSize',9,'FontName','Times New Roman');
% % % % %     end
% % % % %     end
% % % % %        
% % % % % end


