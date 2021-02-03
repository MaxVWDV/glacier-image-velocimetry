function [images,inputs]=GIVcore(images,inputs)
%
%This functions calculates the image pairs and sends them off to be
%calculated. If the code is running in parralel mode then it will slice the
%pairs into portions the size of the number of cores on your computer to
%improve the efficiency of the calculations.
%
%If you are running in single pass mode, pairs are feature tracked with
%GIVtrack.m
%
%If you are running in multi pass mode, pairs are feature tracked with
%GIVtrackmulti.m

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
% https://doi.org/10.5194/tc-2020-204
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Version 0.7, Autumn 2020%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Feel free to contact me at vanwy048@umn.edu%


%% Perform some initial tasks

%Initialize the timer. This will tell the user how long is remaining until
%the run is complete.
time_all_iterations = tic;

%Logo for msg boxes
logo = imread('GIV_LOGO_SMALL.png');

%IF images are being compared to a portion of stable ground, the stable
%mask is loaded and processed here.
if  strcmpi(inputs.stable, 'Yes')
    
    if exist(fullfile(inputs.folder,'stable.png'),'file')  > 0
        cdata = imread(fullfile(inputs.folder,'stable.png'));
    elseif exist(fullfile(inputs.folder,'stable.jpg'),'file') >0
        cdata = imread(fullfile(inputs.folder,'stable.jpg'));
    end
    
    % Create binary mask with pure white pixels
    cdata = double(cdata);
    cdata = cdata(:,:,1)+cdata(:,:,2)+cdata(:,:,3);
    cdata(cdata==765) = NaN;
    cdata(cdata>0)= 0;
    cdata(isnan(cdata))= 1;
    stable = cdata;
    stable = flipud(stable);
    
else
    
    %Create dummy stable mask if not needed
    stable = zeros(size(images{2,3}));
    
end

scale_length = size(images{2,3});

%Calculate resolution of image
if strcmpi(inputs.isgeotiff,'No')
    NS1 = [inputs.minlat,inputs.minlon];
    NS2 = [inputs.maxlat,inputs.minlon];
    EW1 = [inputs.minlat,inputs.minlon];
    EW2 = [inputs.minlat,inputs.maxlon];
else
    NS1 = [inputs.geotifflocationdata.CornerCoords.Lat(1,4),inputs.geotifflocationdata.CornerCoords.Lon(1,4)];
    NS2 = [inputs.geotifflocationdata.CornerCoords.Lat(1,1),inputs.geotifflocationdata.CornerCoords.Lon(1,1)];
    EW1 = [inputs.geotifflocationdata.CornerCoords.Lat(1,4),inputs.geotifflocationdata.CornerCoords.Lon(1,4)];
    EW2 = [inputs.geotifflocationdata.CornerCoords.Lat(1,3),inputs.geotifflocationdata.CornerCoords.Lon(1,3)];
end

%Convert lat long to distances
dy=coordtom(EW1,EW2);
dx=coordtom(NS1,NS2);

stepx=dx/scale_length(1); %m/pixel
stepy=dy/scale_length(2); %m/pixel
mean_resolution = 0.5*(stepx+stepy);

%Write the resolution to the inputs array for future use
inputs.realresolution = ceil(inputs.idealresolution/mean_resolution)*8;
%

%Initialize some parameters
newcol1 = {}; %import to external (new) array in order to be parralelized
newcol2 = {};
number_in_range = 0;
meta_dum = 0;
emptycount_inner = 0;
emptycount_outer = 0;

%% CREATE IMAGE PAIRS ARRAY

for time_loop = 1:inputs.temporaloversampling  %for multisampling in time
    for inner_loop = 2:inputs.numimages-time_loop  %main loop
        loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket
        
        %Work out time between two images, if too long then do not run
        %templatematch.
        
        A1_t= (images{inner_loop,5});
        B1_t= (images{loop2,5});
        
        timestep = (B1_t-A1_t)/365;
        
        if timestep <= inputs.maxinterval && timestep >= inputs.mininterval
            
            number_in_range = number_in_range + 1;
            
        end
        emptycount_outer = emptycount_outer + emptycount_inner;
        emptycount_inner = 0;
        meta_dum = meta_dum + inputs.numimages-time_loop-1;
        
        
    end
end

emptycount_inner = 0;

column_save_variable = 1;

parralel_timestep = 1;

[~,Num_cores] = evalc('feature(''numcores'')');


%% Main feature tracking
% This can (and should!) be parralelized. But it can also be run in series

if strcmpi(inputs.parralelize, 'No')
    
    for time_loop = 1:inputs.temporaloversampling  %for multisampling in time
        
        for inner_loop = 2:inputs.numimages-time_loop  %main loop
            loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket
            
            %Work out time between two images, if too long then do not run
            %feature track.
            A1_t= (images{inner_loop,5});
            B1_t= (images{loop2,5});
            timestep = (B1_t-A1_t)/365;
            dt = 0;
            
            %this loop accounts for several dt steps where dum > 1
            %(non-consecutive images being considered).
            for iit = inner_loop+1:loop2
                dt = dt + images{iit,6};
            end
            
            %Include only images within the bounds
            if timestep <= inputs.maxinterval && timestep >= inputs.mininterval
                
                %Load the two images
                A1= (images{inner_loop,3});
                B1= (images{loop2,3});
                
                %Write them to a parralel chip array. This chip is then sent to the
                %processors instead of the entire array, reducing overhead and
                %runtime.
                parralel_chip{parralel_timestep,1} =  A1;
                parralel_chip{parralel_timestep,2} =  B1;
                parralel_chip{parralel_timestep,3} =  dt;
                parralel_timestep = parralel_timestep+1;
            else
                emptycount_inner = emptycount_inner + 1;
            end
            
            %Check that a parralel chip has been created (not at end of run) and
            %that some conditions are met.
            
            if exist('parralel_chip') == 1 && ...
                    size(parralel_chip,1) == Num_cores | (time_loop == inputs.temporaloversampling && inner_loop == inputs.numimages-time_loop)
                
                for inner_loop_parralel = 1:size(parralel_chip,1)
                    A1= parralel_chip{inner_loop_parralel,1};
                    B1= parralel_chip{inner_loop_parralel,2};
                    dt = parralel_chip{inner_loop_parralel,3};
                    
                    %This function will perform the feature tracking. The multipass method is generally better.
                    
                    if strcmpi(inputs.numpass, 'Multi')
                        [u,v,snr,pkr]=GIVtrackmulti(A1,B1,inputs.realresolution,inputs.windowoverlap);
                    elseif strcmpi(inputs.numpass, 'Single')
                        
                        %set maximum expected velocity
                        max_expected = round(dt * inputs.maxvel/mean_resolution);  % Rounding is necessary
                        
                        % make minimum limit, else can become too small if close images.
                        if max_expected < inputs.minsearcharea
                            max_d = inputs.minsearcharea;
                        else
                            max_d = max_expected;
                        end
                        
                        [u,v,snr,pkr]=GIVtrack(A1,B1,inputs,max_d,inputs.idealresolution);
                    else
                        disp('Check bottom of inputs file for single or multipass entry')
                    end
                    
                    %%   Convert to velocity and perform filtering
                    
                    %Apply a signal to noise ratio filter
                    [u,v] = GIVsnrfilt(u,v,snr,pkr,inputs);
                    
                    
                    %Switch to velocity and flow direction
                    [V,~] = xytoV(u, v,  stepx, stepy , dt);
                    
                    %Now apply a filter to remove outlier values (see myfilter function for
                    %details, detects values that are too different from their neighbors
                    %and removes them)
                    filtermask = myfilter(V, inputs);
                    u(filtermask == 1) = NaN;
                    v(filtermask == 1) = NaN;
                    V(V > inputs.maxvel) = -1;
                    V(V == -1) = NaN;
                    
                    %Finally apply a selective interpolation and smoothing algorithm to
                    %infill the gaps created and prior non-tracked values without creating
                    %spurious peaks/troughs. If not sufficient data is present in the area
                    %to make an interpolation, it will not be done.
                    
                    % First pass with a small window size and higher tolerance to fill
                    % small gaps:
                    u = nanfillsm(u,2,2);
                    v = nanfillsm(v,2,2);
                    
                    if  strcmpi(inputs.stable, 'Yes')
                        stable_used = (interp2(stable, linspace(1,size(images{2,3},2),size(u,2)).', linspace(1,size(images{2,3},1),size(u,1))));
                        dudiff = nanmean(u(stable_used == 1));
                        dvdiff = nanmean(v(stable_used == 1));
                        u = u - dudiff;
                        v = v - dvdiff;
                    end
                    
                    [V,fd] = xytoV(u, v,stepx, stepy , dt);
                    V(V > inputs.maxvel) = -1;
                    V(V == -1) = NaN;
                    
                    %Exclude displacements in wrong direction.
                    if strcmpi(inputs.excludeangle, 'Yes')
                        
                        %Remove areas flowing in wrong direction (change direction for specific
                        %glaciers or remove, on Amalia it is all flowing W)
                        tempwrongfd1 = double(fd>inputs.excudedangle1.min) + double(fd<inputs.excudedangle1.max);
                        tempwrongfd2 = double(fd>inputs.excudedangle2.min) + double(fd<inputs.excudedangle2.max);
                        fd(tempwrongfd1==2)=-1;
                        fd(tempwrongfd2==2)=-1;
                        fd(fd==-1)=NaN;
                        V(fd==-1)=NaN;
                        
                    end
                    
                    %Smooth the velocity matrix with a small 2 by 2 filter, this
                    %function also interpolates over isolated missing pixels
                    V = nanfillsm(V,2,2);
                    
                    %Make the mask the same size as the velocity matrix
                    mask = flipud((interp2(inputs.cropmask,...
                        linspace(1, size(images{2,3},2), size(V,2)).',...
                        linspace(1, size(images{2,3},1), size(V,1)))));
                    
                    %Mask out areas
                    V(mask==0) = NaN;
                    fd(mask==0) = NaN;
                    
                    %import results to master index before loop continues. Name first
                    %row of each.
                    newcol1{inner_loop_parralel,1}=V;
                    newcol2{inner_loop_parralel,1}=fd;
                    
                end %for end
                
                %write to array to save velocity and flow direction maps.
                column_save_variable2 = column_save_variable + size(newcol1,1) -1;
                for column_save_loop = column_save_variable:column_save_variable2
                    column_v{column_save_loop,1} = newcol1{column_save_loop-column_save_variable+1,1};
                    column_fd{column_save_loop,1} = newcol2{column_save_loop-column_save_variable+1,1};
                end
                column_save_variable = column_save_variable2 + 1;
                
                %calculate approx percent completed
                percent_completed = 100*column_save_variable2/number_in_range;
                
                %Cannot be over 100%
                if percent_completed > 100
                    percent_completed = 100;
                    disp('At last!');
                end
                
                %Calculate approximate time remaining;
                elapsed_time = toc(time_all_iterations);
                total_time = (elapsed_time * number_in_range) / column_save_variable2;
                remaining_time = total_time * (1-column_save_variable2/number_in_range);
                
                if percent_completed > 100
                    remaining_time = 0;
                end
                
                %Display time remaining in a reasonable unit.
                if remaining_time < 60 %seconds remaining
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'seconds remaining.'];
                elseif remaining_time > 60 && remaining_time < 3600
                    remaining_time = remaining_time/60;
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'minutes remaining.'];
                elseif remaining_time > 3600
                    remaining_time = remaining_time/3600;
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'hours remaining.'];
                end
                
                if exist('message_1', 'var')
                    delete(message_1);
                    clear('message_1');
                end
                
                message_1 = msgbox(text_percent,...
                    'GIV is running','custom',logo);
                
                %Display time remaining
                disp(text_percent);
                parralel_chip = {};
                parralel_timestep = 1;
                
                
            end
            
        end %size parralel if end
        
        emptycount_inner = 0;
        
    end
    
    
    %Or run it in parralel
elseif strcmpi(inputs.parralelize, 'Yes')
    
    for time_loop = 1:inputs.temporaloversampling  %for multisampling in time
        
        for inner_loop = 2:inputs.numimages-time_loop  %main loop
            loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket
            
            %Work out time between two images, if too long then do not run
            %feature track.
            A1_t= (images{inner_loop,5});
            B1_t= (images{loop2,5});
            timestep = (B1_t-A1_t)/365;
            dt = 0;
            
            %this loop accounts for several dt steps where dum > 1
            %(non-consecutive images being considered).
            for iit = inner_loop+1:loop2
                dt = dt + images{iit,6};
            end
            
            %Include only images within the bounds
            if timestep <= inputs.maxinterval && timestep >= inputs.mininterval
                
                %Load the two images
                A1= (images{inner_loop,3});
                B1= (images{loop2,3});
                
                %Write them to a parralel chip array. This chip is then sent to the
                %processors instead of the entire array, reducing overhead and
                %runtime.
                parralel_chip{parralel_timestep,1} =  A1;
                parralel_chip{parralel_timestep,2} =  B1;
                parralel_chip{parralel_timestep,3} =  dt;
                parralel_timestep = parralel_timestep+1;
            else
                emptycount_inner = emptycount_inner + 1;
            end
            
            %Check that a parralel chip has been created (not at end of run) and
            %that some conditions are met.
            
            if exist('parralel_chip') == 1 && ...
                    size(parralel_chip,1) == Num_cores | (time_loop == inputs.temporaloversampling && inner_loop == inputs.numimages-time_loop)
                
                %parralelized loop. Requires a slightly different code structure.
                parfor inner_loop_parralel = 1:size(parralel_chip,1)
                    A1= parralel_chip{inner_loop_parralel,1};
                    B1= parralel_chip{inner_loop_parralel,2};
                    dt = parralel_chip{inner_loop_parralel,3};
                    
                    %This function will perform the feature tracking. The multipass method is generally better.
                    
                    if strcmpi(inputs.numpass, 'Multi')
                        [u,v,snr,pkr]=GIVtrackmulti(A1,B1,inputs.realresolution,inputs.windowoverlap);
                    elseif strcmpi(inputs.numpass, 'Single')
                        
                        %set maximum expected velocity
                        max_expected = round(dt * inputs.maxvel/mean_resolution);  % Rounding is necessary
                        
                        % make minimum limit, else can become too small if close images.
                        if max_expected < inputs.minsearcharea
                            max_d = inputs.minsearcharea;
                        else
                            max_d = max_expected;
                        end
                        
                        [u,v,snr,pkr]=GIVtrack(A1,B1,inputs,max_d,inputs.idealresolution);
                    else
                        disp('Check bottom of inputs file for single or multipass entry')
                    end
                    
                    %%   Convert to velocity and perform filtering
                    
                    %Apply a signal to noise ratio filter
                    [u,v] = GIVsnrfilt(u,v,snr,pkr,inputs);
                    
                    
                    %Switch to velocity and flow direction
                    [V,~] = xytoV(u, v, stepx, stepy , dt);
                    
                    %Now apply a filter to remove outlier values (see myfilter function for
                    %details, detects values that are too different from their neighbors
                    %and removes them)
                    filtermask = myfilter(V, inputs);
                    u(filtermask == 1) = NaN;
                    v(filtermask == 1) = NaN;
                    V(V > inputs.maxvel) = -1;
                    V(V == -1) = NaN;
                    
                    %Finally apply a selective interpolation and smoothing algorithm to
                    %infill the gaps created and prior non-tracked values without creating
                    %spurious peaks/troughs. If not sufficient data is present in the area
                    %to make an interpolation, it will not be done.
                    
                    % First pass with a small window size and higher tolerance to fill
                    % small gaps:
                    u = nanfillsm(u,2,2);
                    v = nanfillsm(v,2,2);
                    
                    if  strcmpi(inputs.stable, 'Yes')
                        stable_used = (interp2(stable, linspace(1,size(images{2,3},2),size(u,2)).', linspace(1,size(images{2,3},1),size(u,1))));
                        dudiff = nanmean(u(stable_used == 1));
                        dvdiff = nanmean(v(stable_used == 1));
                        u = u - dudiff;
                        v = v - dvdiff;
                    end
                    
                    [V,fd] = xytoV(u, v, stepx, stepy , dt);
                    V(V > inputs.maxvel) = -1;
                    V(V == -1) = NaN;
                    
                    %Exclude displacements in wrong direction.
                    if strcmpi(inputs.excludeangle, 'Yes')
                        
                        %Remove areas flowing in wrong direction (change direction for specific
                        %glaciers or remove, on Amalia it is all flowing W)
                        tempwrongfd1 = double(fd>inputs.excudedangle1.min) + double(fd<inputs.excudedangle1.max);
                        tempwrongfd2 = double(fd>inputs.excudedangle2.min) + double(fd<inputs.excudedangle2.max);
                        fd(tempwrongfd1==2)=-1;
                        fd(tempwrongfd2==2)=-1;
                        fd(fd==-1)=NaN;
                        V(fd==-1)=NaN;
                        
                    end
                    
                    %Smooth the velocity matrix with a small 2 by 2 filter, this
                    %function also interpolates over isolated missing pixels
                    V = nanfillsm(V,2,2);
                    
                    %Make the mask the same size as the velocity matrix
                    mask = flipud((interp2(inputs.cropmask,...
                        linspace(1, size(images{2,3},2), size(V,2)).',...
                        linspace(1, size(images{2,3},1), size(V,1)))));
                    
                    %Mask out areas
                    V(mask==0) = NaN;
                    fd(mask==0) = NaN;
                    
                    %import results to master index before loop continues. Name first
                    %row of each.
                    newcol1{inner_loop_parralel,1}=V;
                    newcol2{inner_loop_parralel,1}=fd;
                    
                end %parfor end
                
                %write to array to save velocity and flow direction maps.
                column_save_variable2 = column_save_variable + size(newcol1,1) -1;
                for column_save_loop = column_save_variable:column_save_variable2
                    column_v{column_save_loop,1} = newcol1{column_save_loop-column_save_variable+1,1};
                    column_fd{column_save_loop,1} = newcol2{column_save_loop-column_save_variable+1,1};
                end
                column_save_variable = column_save_variable2 + 1;
                
                %calculate approx percent completed
                percent_completed = 100*column_save_variable2/number_in_range;
                
                %Cannot be over 100%
                if percent_completed > 100
                    percent_completed = 100;
                    disp('At last!');
                end
                
                %Calculate approximate time remaining;
                elapsed_time = toc(time_all_iterations);
                total_time = (elapsed_time * number_in_range) / column_save_variable2;
                remaining_time = total_time * (1-column_save_variable2/number_in_range);
                
                if percent_completed > 100
                    remaining_time = 0;
                end
                
                %Display time remaining in a reasonable unit.
                if remaining_time < 60 %seconds remaining
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'seconds remaining.'];
                elseif remaining_time > 60 && remaining_time < 3600
                    remaining_time = remaining_time/60;
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'minutes remaining.'];
                elseif remaining_time > 3600
                    remaining_time = remaining_time/3600;
                    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'hours remaining.'];
                end
                
                %Remove previous message if it exists
                if exist('message_1', 'var')
                    delete(message_1);
                    clear('message_1');
                end
                
                %Create pop up message box with duration remaining.
                message_1 = msgbox(text_percent,...
                    'GIV is running','custom',logo);
                parralel_chip = {};
                
                parralel_timestep = 1;
                
                %This section in case one worked in the parralel pool 'dies' during
                % a long calculation. Should reboot the full parralel pool.
                core_info = gcp('nocreate');
                try
                    current_cores = core_info.NumWorkers;
                catch
                    current_cores = 0;
                end
                clear core_info
                
                if current_cores < Num_cores
                    delete(gcp('nocreate'))
                    parpool(Num_cores)
                end
                
                
            end
            
        end %size parralel if end
        
        emptycount_inner = 0;
        
    end
    
end



%% REINSERT MATRICES INTO IMAGES ARRAY
% May be more efficient in future to remove this step?

%Reinitialize loop parameters
meta_dum = 0;
array_pos = 0;
emptycount_inner = 0;
emptycount_outer = 0;

%Run loop
for time_loop = 1:inputs.temporaloversampling
    position1 = time_loop + 6 + array_pos;
    position2 = time_loop + 7 + array_pos;
    for inner_loop = 2:inputs.numimages-time_loop
        loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket
        
        %Work out time between two images.
        A1_t= (images{inner_loop,5});
        B1_t= (images{loop2,5});
        timestep = (B1_t-A1_t)/365;
        dt = 0;
        
        %this loop accounts for several dt steps where dum > 1
        %(non-consecutive images being considered).
        for iit = inner_loop+1:loop2
            dt = dt + images{iit,6};
        end
        
        if timestep <= inputs.maxinterval && timestep >= inputs.mininterval
            %Replace velocity in array
            images{inner_loop,position1} = column_v{inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1};
            
            %Replace flow direction in array
            images{inner_loop,position2} = column_fd{inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1};
        else
            emptycount_inner = emptycount_inner + 1;
        end
        
    end
    
    
    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
    meta_dum = meta_dum + inputs.numimages-time_loop-1;
    array_pos = array_pos + 1;
end

%Calculate the size of raw images and write to inputs array for future
%reference
for i = 2:size(images,1)
    if ~isempty(images{i,3})
        inputs.sizeraw = size(images{i,3});
    end
end

%Calculate the size of processed images and write to inputs array for future
%reference
number_with_values = (size(images,2)-6)/2;
for ii = 7:(6+number_with_values*2)
    for i = 2:size(images,1)
        if ~isempty(images{i,ii})
            inputs.sizevel = size(images{i,ii});
        end
    end
end