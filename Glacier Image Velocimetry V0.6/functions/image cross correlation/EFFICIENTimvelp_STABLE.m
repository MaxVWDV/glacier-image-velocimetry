function [images,inputs]=EFFICIENTimvelp_STABLE(images,inputs)
% 
%This functions calculates the image pairs and sends them off to be
%calculated. If the code is running in parralel mode then it will slice the
%pairs into portions the size of the number of cores on your computer to
%improve the efficiency of the calculations.

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


%% Compare the images to determine velocity map

time_all_iterations = tic;
logo = imread('GIV_LOGO_SMALL.png');


if  strcmpi(inputs{51,2}, 'Yes') 

    if exist(fullfile(inputs{1,2},'stable.png'))  > 0  
    
cdata = imread(fullfile(inputs{1,2},'stable.png'));

elseif exist(fullfile(inputs{1,2},'stable.jpg')) >0
    
cdata = imread(fullfile(inputs{1,2},'stable.jpg'));

end
    
cdata = double(cdata);

cdata = cdata(:,:,1)+cdata(:,:,2)+cdata(:,:,3);

cdata(cdata==765) = NaN;

cdata(cdata>0)= 0;

cdata(isnan(cdata))= 1;

stable = cdata;

stable = flipud(stable);

else

stable = zeros(size(images{2,3}));


end


if strcmpi(inputs{30,2}, 'No')

%% Parameters
scale_length = size(images{2,3});

    %Calculate resolution of image
    NS1 = [inputs{14,2},inputs{16,2}];
    NS2 = [inputs{15,2},inputs{16,2}];
    EW1 = [inputs{14,2},inputs{16,2}];
    EW2 = [inputs{14,2},inputs{17,2}];
    
    dy=coordtom(EW1,EW2);
    dx=coordtom(NS1,NS2);
    
    stepx=dx/scale_length(1); %m/pixel
    stepy=dy/scale_length(2); %m/pixel
    
    mean_resolution = 0.5*(stepx+stepy);
    
    inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;

array_pos = 0; %initialize dummy variable

newcol1 = {}; %import to external (new) array in order to parralelise
newcol2 = {};

%% CREATE IMAGE PAIRS ARRAY

number_in_range = 0;

meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

for time_loop = 1:inputs{20,2}  %for multisampling in time
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

array_pos = 0;

emptycount_inner = 0;

column_save_variable = 1;

parralel_timestep = 1;

full_v = {};

core_info = evalc('feature(''numcores'')');
Num_cores = ans;
clear ans
clear core_info

for time_loop = 1:inputs{20,2}  %for multisampling in time
    dum1 = 6+time_loop+array_pos;
    dum2 = 7+time_loop+array_pos;
   for inner_loop = 2:inputs{34,2}-time_loop  %main loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images, if too long then do not run
    %templatematch.
    
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    
    timestep = (B1_t-A1_t)/365;
    
        dt = 0;
    
    %this loop accounts for several dt steps where dum > 1
    %(non-consecutive images being considered).
    for iit = inner_loop+1:loop2
        dt = dt + images{iit,6};
        
    end
    
    if timestep <= inputs{21,2} && timestep >= inputs{22,2}
    

    A1= (images{inner_loop,3});
    B1= (images{loop2,3});
    
       
    parralel_chip{parralel_timestep,1} =  A1;
    
    parralel_chip{parralel_timestep,2} =  B1;
    
    parralel_chip{parralel_timestep,3} =  dt;
    
    parralel_timestep = parralel_timestep+1;
    
    else 
        emptycount_inner = emptycount_inner + 1;
    end
    
    if exist('parralel_chip') == 1
    if size(parralel_chip,1) == Num_cores | (time_loop == inputs{20,2} && inner_loop == inputs{34,2}-time_loop)
        
        
    
    for inner_loop_parralel = 1:size(parralel_chip,1)
         
    A1= parralel_chip{inner_loop_parralel,1};   
        
    B1= parralel_chip{inner_loop_parralel,2};   
    
    dt = parralel_chip{inner_loop_parralel,3};    
    
       %This function will correlate the two images.      
    
    if strcmpi(inputs{41,2}, 'Multi') 
    [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
    elseif strcmpi(inputs{41,2}, 'Single') 
        
    %set maximum expected velocity 
    max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
    
    % make minimum limit, else can become too small if close images.
    if max_expected < inputs{23,2}
    max_d = inputs{23,2};
    else
    max_d = max_expected;
    end
        
    [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d,inputs{38,2});
    else
    disp('Check bottom of inputs file for single or multipass entry')
    end
    
    %%   Convert to velocity and filter it
    
%     if strcmpi(inputs{41,2}, 'Multi') 
% 
%     %flip it
%     u = flipud(u);
%     v = flipud(v);
%     end
    
    % filter out portions with signal to noise lower than a given value
    % implement value
    if strcmpi(inputs{41,2}, 'Single') 
    snr = C./Cnoise;
    end
snrsm = nanfillsm(snr,inputs,2,2);
snrextra = snrsm;
snrextra(snrsm<=(inputs{36,2}+0.5))=0;
snrextra(snrextra>0)=1;
snrextra = smooth_snr(snrextra, inputs);
snrfn = snrextra.*snrsm;
snrfn(snrfn<=0.1) = 0;
snrfn(snrfn>0) = 1;
u = u.*snrfn;
u(u==0) = NaN;
v = v.*snrfn;
v(v==0) = NaN;
u(snr<inputs{36,2}) = NaN;
v(snr<inputs{36,2}) = NaN;
    
    
    % calculate flow direction
    
    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    %Now apply a filter to remove outlier values (see myfilter function for
    %details, detects values that are too different from their neighbors
    %and removes them)
    
    filtermask = myfilter(V, inputs);
        
    u(filtermask == 1) = NaN;
    
    v(filtermask == 1) = NaN;
    
    V(V > inputs{8,2}) = -1;
    
    V(V == -1) = NaN;
    
    %Finally apply a selective interpolation and smoothing algorithm to
    %infill the gaps created and prior non-tracked values without creating
    %spurious peaks/troughs. If not sufficient data is present in the area
    %to make an interpolation, it will not be done.
    
    % First pass with a small window size and higher tolerance to fill
    % small gaps:
    
    u = nanfillsm(u,inputs,2,2);
    v = nanfillsm(v,inputs,2,2);
    
    if  strcmpi(inputs{51,2}, 'Yes') 
        
    stable_used = (interp2(stable, linspace(1,size(images{2,3},2),size(u,2)).', linspace(1,size(images{2,3},1),size(u,1))));
    
    dudiff = nanmean(u(stable_used == 1));
    dvdiff = nanmean(v(stable_used == 1));
    
    u = u - dudiff;
    v = v - dvdiff;
    
        
    end
       
    
    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    V(V > inputs{8,2}) = -1;
    
    V(V == -1) = NaN;
    
    
    if strcmpi(inputs{9,2}, 'Yes')
    
    %Remove areas flowing in wrong direction (change direction for specific
    %glaciers or remove, on Amalia it is all flowing W)
    tempwrongfd1 = double(fd>inputs{10,2}) + double(fd<inputs{37,2});
    tempwrongfd2 = double(fd>inputs{18,2}) + double(fd<inputs{19,2});

    fd(tempwrongfd1==2)=-1;    
    fd(tempwrongfd2==2)=-1;    
    
    fd(fd==-1)=NaN;
    V(fd==-1)=NaN;

    end
    
    
    

    V = nanfillsm(V,inputs,2,2);
    
    
    %Second pass with larger window size and lower tolerance to fill any
    %remaining larger holes:
    
%     V = nanfillsm(V,inputs,4,5);
 
% % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % %
    mask = flipud((interp2(inputs{52,2}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));

% % % % 
% % % %     %flip it
% % % %     %make the mask the right size and flip it to the right orientation
% % % %     else
% % % %     end
    %crop all outside of mask to no value (NaN)
    
    V(mask==0) = NaN;
    fd(mask==0) = NaN;
   
    %import results to master index before loop continues. Name first
    %row of each.
    newcol1{inner_loop_parralel,1}=V;

    newcol2{inner_loop_parralel,1}=fd;           
        
    end %parfor end
    
    
           
    column_save_variable2 = column_save_variable + size(newcol1,1) -1;
    
    for column_save_loop = column_save_variable:column_save_variable2
        
    column_v{column_save_loop,1} = newcol1{column_save_loop-column_save_variable+1,1};
    
    column_fd{column_save_loop,1} = newcol2{column_save_loop-column_save_variable+1,1};
    
    end
    
    column_save_variable = column_save_variable2 + 1;
    
        %calculate approx percent completed
    
    percent_completed = 100*column_save_variable2/number_in_range;
    
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
    
    if remaining_time < 60 %seconds remaining
    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'seconds remaining.'];
    elseif remaining_time > 60 && remaining_time < 3600
        remaining_time = remaining_time/60;
    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'minutes remaining.'];
    elseif remaining_time > 3600
        remaining_time = remaining_time/3600;
    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated and' ' ' num2str(remaining_time) ' ' 'hours remaining.'];
    end
    
%     text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated.'];
    
    disp(text_percent);
        
    parralel_chip = {};

    parralel_timestep = 1;
    
    
    core_info = gcp('nocreate');
    try 
    current_cores = core_info.NumWorkers;
    catch
        current_cores = 0
    end
    clear core_info
    
    if current_cores < Num_cores %This section in case one worked in the parralel pool 'dies' during 
        % a long calculation. Should reboot the full parralel pool.
        delete(gcp('nocreate'))
        parpool(Num_cores)
    end
    
       
    end
   end
    
       
    end %size parralel if end
    
   emptycount_inner = 0;
   end

array_pos = array_pos+1;
elseif strcmpi(inputs{30,2}, 'Yes')

%% Parameters
scale_length = size(images{2,3});

    %Calculate resolution of image
    NS1 = [inputs{14,2},inputs{16,2}];
    NS2 = [inputs{15,2},inputs{16,2}];
    EW1 = [inputs{14,2},inputs{16,2}];
    EW2 = [inputs{14,2},inputs{17,2}];
    
    dy=coordtom(EW1,EW2);
    dx=coordtom(NS1,NS2);
    
    stepx=dx/scale_length(1); %m/pixel
    stepy=dy/scale_length(2); %m/pixel
    
    mean_resolution = 0.5*(stepx+stepy);
    
    inputs{40,2} = ceil(inputs{38,2}/mean_resolution)*8;

array_pos = 0; %initialize dummy variable

newcol1 = {}; %import to external (new) array in order to parralelise
newcol2 = {};

%% CREATE IMAGE PAIRS ARRAY

number_in_range = 0;

meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

for time_loop = 1:inputs{20,2}  %for multisampling in time
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

array_pos = 0;

emptycount_inner = 0;

column_save_variable = 1;

parralel_timestep = 1;

full_v = {};

core_info = evalc('feature(''numcores'')');
Num_cores = ans;
clear ans
clear core_info

for time_loop = 1:inputs{20,2}  %for multisampling in time
    dum1 = 6+time_loop+array_pos;
    dum2 = 7+time_loop+array_pos;
   for inner_loop = 2:inputs{34,2}-time_loop  %main loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images, if too long then do not run
    %templatematch.
    
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    
    timestep = (B1_t-A1_t)/365;
    
        dt = 0;
    
    %this loop accounts for several dt steps where dum > 1
    %(non-consecutive images being considered).
    for iit = inner_loop+1:loop2
        dt = dt + images{iit,6};
        
    end
    
    if timestep <= inputs{21,2} && timestep >= inputs{22,2}
    

    A1= (images{inner_loop,3});
    B1= (images{loop2,3});
    
       
    parralel_chip{parralel_timestep,1} =  A1;
    
    parralel_chip{parralel_timestep,2} =  B1;
    
    parralel_chip{parralel_timestep,3} =  dt;
    
    parralel_timestep = parralel_timestep+1;
    
    else 
        emptycount_inner = emptycount_inner + 1;
    end
    
    if exist('parralel_chip') == 1
    if size(parralel_chip,1) == Num_cores | (time_loop == inputs{20,2} && inner_loop == inputs{34,2}-time_loop)
        
        
    
    parfor inner_loop_parralel = 1:size(parralel_chip,1) 
         
    A1= parralel_chip{inner_loop_parralel,1};   
        
    B1= parralel_chip{inner_loop_parralel,2};   
    
    dt = parralel_chip{inner_loop_parralel,3};    
    
       %This function will correlate the two images.      
    
    if strcmpi(inputs{41,2}, 'Multi') 
    [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
    elseif strcmpi(inputs{41,2}, 'Single') 
        
    %set maximum expected velocity 
    max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
    
    % make minimum limit, else can become too small if close images.
    if max_expected < inputs{23,2}
    max_d = inputs{23,2};
    else
    max_d = max_expected;
    end
        
    [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d,inputs{38,2});
    else
    disp('Check bottom of inputs file for single or multipass entry')
    end
    
    %%   Convert to velocity and filter it
    
%     if strcmpi(inputs{41,2}, 'Multi') 
% 
%     %flip it
%     u = flipud(u);
%     v = flipud(v);
%     end
    
    % filter out portions with signal to noise lower than a given value
    % implement value
    if strcmpi(inputs{41,2}, 'Single') 
    snr = C./Cnoise;
    end
snrsm = nanfillsm(snr,inputs,2,2);
snrextra = snrsm;
snrextra(snrsm<=(inputs{36,2}+0.5))=0;
snrextra(snrextra>0)=1;
snrextra = smooth_snr(snrextra, inputs);
snrfn = snrextra.*snrsm;
snrfn(snrfn<=0.1) = 0;
snrfn(snrfn>0) = 1;
u = u.*snrfn;
u(u==0) = NaN;
v = v.*snrfn;
v(v==0) = NaN;
u(snr<inputs{36,2}) = NaN;
v(snr<inputs{36,2}) = NaN;
    
    
    % calculate flow direction
    
    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    %Now apply a filter to remove outlier values (see myfilter function for
    %details, detects values that are too different from their neighbors
    %and removes them)
    
    filtermask = myfilter(V, inputs);
        
    u(filtermask == 1) = NaN;
    
    v(filtermask == 1) = NaN;
    
    V(V > inputs{8,2}) = -1;
    
    V(V == -1) = NaN;
    
    %Finally apply a selective interpolation and smoothing algorithm to
    %infill the gaps created and prior non-tracked values without creating
    %spurious peaks/troughs. If not sufficient data is present in the area
    %to make an interpolation, it will not be done.
    
    % First pass with a small window size and higher tolerance to fill
    % small gaps:
    
    u = nanfillsm(u,inputs,2,2);
    v = nanfillsm(v,inputs,2,2);
    
    if  strcmpi(inputs{51,2}, 'Yes') 
        
    stable_used = (interp2(stable, linspace(1,size(images{2,3},2),size(u,2)).', linspace(1,size(images{2,3},1),size(u,1))));
    
    dudiff = nanmean(u(stable_used == 1));
    dvdiff = nanmean(v(stable_used == 1));
    
    u = u - dudiff;
    v = v - dvdiff;
    
        
    end
    

    
    
    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    V(V > inputs{8,2}) = -1;
    
    V(V == -1) = NaN;
    
    
     if strcmpi(inputs{9,2}, 'Yes')
    
    %Remove areas flowing in wrong direction (change direction for specific
    %glaciers or remove, on Amalia it is all flowing W)
    tempwrongfd1 = double(fd>inputs{10,2}) + double(fd<inputs{37,2});
    tempwrongfd2 = double(fd>inputs{18,2}) + double(fd<inputs{19,2});

    fd(tempwrongfd1==2)=-1;    
    fd(tempwrongfd2==2)=-1;    
    
    fd(fd==-1)=NaN;
    V(fd==-1)=NaN;

    end
    
    

    V = nanfillsm(V,inputs,2,2);
    
    
    %Second pass with larger window size and lower tolerance to fill any
    %remaining larger holes:
    
%     V = nanfillsm(V,inputs,4,5);
 
% % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % %
    mask = flipud((interp2(inputs{52,2}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));

% % % % 
% % % %     %flip it
% % % %     %make the mask the right size and flip it to the right orientation
% % % %     else
% % % %     end
    %crop all outside of mask to no value (NaN)
    
    V(mask==0) = NaN;
    fd(mask==0) = NaN;
   
    %import results to master index before loop continues. Name first
    %row of each.
    newcol1{inner_loop_parralel,1}=V;

    newcol2{inner_loop_parralel,1}=fd;       
        
    end %parfor end
    
    
           
    column_save_variable2 = column_save_variable + size(newcol1,1) -1;
    
    for column_save_loop = column_save_variable:column_save_variable2
        
    column_v{column_save_loop,1} = newcol1{column_save_loop-column_save_variable+1,1};
    
    column_fd{column_save_loop,1} = newcol2{column_save_loop-column_save_variable+1,1};
    
    end
    
    column_save_variable = column_save_variable2 + 1;
    
        %calculate approx percent completed
    
    percent_completed = 100*column_save_variable2/number_in_range;
    
    
    %Calculate approximate time remaining;
    
    elapsed_time = toc(time_all_iterations);
    
    total_time = (elapsed_time * number_in_range) / column_save_variable2;
    
    remaining_time = total_time * (1-column_save_variable2/number_in_range);
    
   if percent_completed > 100
        percent_completed = 100;
        remaining_time = 0;
%         disp('At last!');
    end
    
    
    if remaining_time < 60 %seconds remaining
    text_percent = ['Approximatively'  ' '  num2str(round(percent_completed,2))  '%'  ' '  'of image pairs calculated and' ' ' num2str(round(remaining_time,2)) ' ' 'seconds remaining.'];
    elseif remaining_time > 60 && remaining_time < 3600
        remaining_time = remaining_time/60;
    text_percent = ['Approximatively'  ' '  num2str(round(percent_completed,2))  '%'  ' '  'of image pairs calculated and' ' ' num2str(round(remaining_time,2)) ' ' 'minutes remaining.'];
    elseif remaining_time > 3600
        remaining_time = remaining_time/3600;
    text_percent = ['Approximatively'  ' '  num2str(round(percent_completed,2))  '%'  ' '  'of image pairs calculated and' ' ' num2str(round(remaining_time,2)) ' ' 'hours remaining.'];
    end
    
%     text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated.'];
    
    if exist('message_1', 'var')
    delete(message_1);
    clear('message_1');
    end
    
    message_1 = msgbox(text_percent,...
    'GIV is running','custom',logo);        
    parralel_chip = {};

    parralel_timestep = 1;
    
    
    core_info = gcp('nocreate');
    try 
    current_cores = core_info.NumWorkers;
    catch
        current_cores = 0
    end
    clear core_info
    
    if current_cores < Num_cores %This section in case one worked in the parralel pool 'dies' during 
        % a long calculation. Should reboot the full parralel pool.
        delete(gcp('nocreate'))
        parpool(Num_cores)
    end
    
       
    end
   end
    
       
    end %size parralel if end
    
   emptycount_inner = 0;
   end

array_pos = array_pos+1;
end



%% REINSERT MATRICES INTO IMAGES ARRAY
% May be more efficient in future to remove this step.

%Reinitialize loop parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

%Run loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for time_loop = 1:inputs{20,2}
    dum1 = time_loop + 6 + array_pos;
    dum2 = time_loop + 7 + array_pos;
 for inner_loop = 2:inputs{34,2}-time_loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images, if too long then do not run
    %templatematch.
    
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    
    timestep = (B1_t-A1_t)/365;
    
        dt = 0;
    
    %this loop accounts for several dt steps where dum > 1
    %(non-consecutive images being considered).
    for iit = inner_loop+1:loop2
        dt = dt + images{iit,6};
        
    end
    
    if timestep <= inputs{21,2} && timestep >= inputs{22,2}
    
     %Replace velocity in array   
    images{inner_loop,dum1} = column_v{inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1};
    
     %Replace flow direction in array  
    images{inner_loop,dum2} = column_fd{inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1};  
    
    else
        emptycount_inner = emptycount_inner + 1;
    end
    
 end
 

    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
meta_dum = meta_dum + inputs{34,2}-time_loop-1;
array_pos = array_pos + 1;
end



inputs{12,1} = 'Size of initial image';
for i = 2:size(images,1)
    if ~isempty(images{i,3})
        inputs{12,2} = size(images{i,3});
    end
end



number_with_values = (size(images,2)-6)/2;
inputs{13,1} = 'Size of velocity data';
for ii = 7:(6+number_with_values*2)
for i = 2:size(images,1)
    if ~isempty(images{i,ii})
        inputs{13,2} = size(images{i,ii});
    end
end
end