function [images,inputs]=EFFICIENTimvelp(images,inputs)
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


if  strcmpi(inputs{51,2}, 'Yes') 

cdata = imread(fullfile(myFolder,'stable.png'));

cdata = double(cdata);

cdata = cdata(:,:,1)+cdata(:,:,2)+cdata(:,:,3);

cdata(cdata==765) = NaN;

cdata(cdata>0)= 0;

cdata(isnan(cdata))= 1;

stable = cdata;

stable = flipud(stable);

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

%% interval loop
for time_loop = 1:inputs{20,2}  %for multisampling in time
    
    %dummy variables. Just to get the right place in array. Please change
    %if there is a better and easier way to do this.
    
    dum1 = 6+time_loop+array_pos; %dummy variable to get right array cell
    dum2 = 7+time_loop+array_pos; %dummy variable to get right array cell
    
   for inner_loop = 2:inputs{34,2}-time_loop  %main loop
    loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket

    %Work out time between two images, if too long or short then do not run
    %templatematch.
    
    A1_t= (images{inner_loop,5});
    B1_t= (images{loop2,5});
    
    timestep = (B1_t-A1_t)/365;
    
    if timestep <= inputs{21,2} && timestep >= inputs{22,2}
    

    A1= (images{inner_loop,3});
    B1= (images{loop2,3});
    
    dt = 0;
    
    %this loop accounts for several dt steps where dum > 1
    %(non-consecutive images being considered).
    for iit = inner_loop+1:loop2
        dt = dt + images{iit,6};
        
        iit = iit+1;
    end
        
    %set maximum expected velocity 
    max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
    
    % make minimum limit, else can become too small if close images.
    if max_expected < inputs{23,2}
    max_d = inputs{23,2};
    else
    max_d = max_expected;
    end
    
    %This function will correlate the two images.      
    
if strcmpi(inputs{41,2}, 'Multi') 
[~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
elseif strcmpi(inputs{41,2}, 'Single') 
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
    u(snr<inputs{36,2}) = NaN;
    v(snr<inputs{36,2}) = NaN;
    
    
    % calculate flow direction
    
    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    if strcmpi(inputs{9,2}, 'Yes')
    
    %Remove areas flowing in wrong direction (change direction for specific
    %glaciers or remove, on Amalia it is all flowing W)
      
    fd(fd>inputs{37,2})=-1;    
    fd(fd<inputs{10,2})=-1;    
    
    V(fd==-1)=NaN;
    fd(fd==-1)=NaN;

    end
    
    %Now apply a filter to remove outlier values (see myfilter function for
    %details, detects values that are too different from their neighbors
    %and removes them)
    
    filtermask = myfilter(V, inputs);
    
    u(filtermask == 1) = NaN;
    
    v(filtermask == 1) = NaN;
    
    %Finally apply a selective interpolation and smoothing algorithm to
    %infill the gaps created and prior non-tracked values without creating
    %spurious peaks/troughs. If not sufficient data is present in the area
    %to make an interpolation, it will not be done.
    
    % First pass with a small window size and higher tolerance to fill
    % small gaps:
    
    u = nanfillsm(u,inputs,2,2);
    v = nanfillsm(v,inputs,2,2);
    
    if  strcmpi(inputs{51,2}, 'Yes') 
        
    stable_used = (interp2(stable, linspace(1,size(images{2,7},2),size(du,2)).', linspace(1,size(images{2,7},1),size(du,1))));
    
    
    
        
    end

    
    
    %Second pass with larger window size and lower tolerance to fill any
    %remaining larger holes:
    
%     V = nanfillsm(V,inputs,4,5);
 
% % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % %     
% % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % 
% % % %     %flip it
% % % %     %make the mask the right size and flip it to the right orientation
% % % %     else
     mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % %     end
    %crop all outside of mask to no value (NaN)
    
    V(mask==0) = NaN;
    fd(mask==0) = NaN;
    
    %The data is now ready to import to the master array!

    %import results to master index before loop continues. Name first
    %row of each.
% %     if strcmpi(inputs{41,2}, 'Multi')
% %     images{inner_loop,dum1}=flipud(V);
% %     
% %     images{inner_loop,dum2}=flipud(fd);
% %     else
    images{inner_loop,dum1}= V;
    
    images{inner_loop,dum2}= fd;
% %     end
    % % PLOTS

    if strcmpi(inputs{29,2}, 'Yes')
    figure;    
    % plot at each timestep. I like to see what is happening. Remove this
    % part for speed when running in background or many images.
    [~, hContour] = contourf(V,'LineColor','w');
    title(strcat('Dates: ',images{inner_loop,2},'__and__',images{loop2,2}));
    drawnow;  % this is important, to ensure that FacePrims is ready in the next line!
    hFills = hContour.FacePrims;  % array of TriangleStrip objects
    [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
    for idx = 1 : numel(hFills)
    hFills(idx).ColorData(4) = 120;   % default=255
    end
    c = colorbar;
    c.Label.String = 'Ice Velocity (m/yr)';
    hold on
    q = quiver(u,v);
    c = q.Color;
    q.Color = 'black';
    hold off
    end
    
    %display point in loop, to keep track of progress.
    disp(inner_loop)
    disp(time_loop)
    
   
    %display date of first image in pair
    disp(images{inner_loop,2})
    %display date of second image in pair
    disp(images{loop2,2})
    
    end
    
    inner_loop=inner_loop+1;
    
   end
   
    name1 = strcat('Velocity total_',num2str(time_loop));
    images{1,dum1}= name1;

    name2 = strcat('Flow direction_',num2str(time_loop));
    images{1,dum2}= name2;   
    
time_loop = time_loop+1;
array_pos = array_pos+1;
end

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
    
%     %flip it
%     u = flipud(u);
%     v = flipud(v);

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

    % calculate flow direction and Velocity

    [V,fd] = xytoV(u, v, mean_resolution, dt);
    
    if strcmpi(inputs{9,2}, 'Yes')
    
    %Remove areas flowing in wrong direction (change direction for specific
    %glaciers or remove, on Amalia it is all flowing W)
        
    fd(fd>inputs{37,2})=-1;    
    fd(fd<inputs{10,2})=-1;     

    
    V(fd==-1)=NaN;
    fd(fd==-1)=NaN;

    end
    
    %Remove areas with unrealistic values
    
    %Firstly points with too fast velocities
    filtermask = myfilter(V, inputs);

    V(filtermask == 1) = NaN;
    
    fd(filtermask == 1) = NaN;
    
    %Finally apply a selective interpolation and smoothing algorithm to
    %infill the gaps created and prior non-tracked values without creating
    %spurious peaks/troughs. If not sufficient data is present in the area
    %to make an interpolation, it will not be done.
    
    % First pass with a small window size and higher tolerance to fill
    % small gaps:
    
    V = nanfillsm(V,inputs,2,2);
    
    %Second pass with larger window size and lower tolerance to fill any
    %remaining larger holes:
    
%     V = nanfillsm(V,inputs,3,5);
        
%     if strcmpi(inputs{41,2}, 'Multi') 
%     
%     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% 
%     %flip it
%     %make the mask the right size and flip it to the right orientation
%     else
     mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
%     end
%     %crop all outside of mask to no value (NaN)
    
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
    
    text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated'];
    
    disp(text_percent);
        
    parralel_chip = {};

    parralel_timestep = 1;
    
    
    core_info = gcp('nocreate');
    current_cores = core_info.NumWorkers;
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


% % % % %% CALCULATE IMAGE PAIRS
% % % % 
% % % % column_v = {};
% % % % 
% % % % column_fd = {};
% % % % 
% % % % for outer_loop = 1:Num_cores:size(full_v,1)
% % % %     if outer_loop+Num_cores-1 < size(full_v,1)
% % % %         second_limit = outer_loop + Num_cores-1;
% % % %     else
% % % %         second_limit = size(full_v,1);
% % % %     end
% % % %     
% % % %     %create small chip to send to parralel pool
% % % %     
% % % %     parralel_chip = {};
% % % %     
% % % %     for i = outer_loop:second_limit
% % % %         
% % % %     parralel_chip{i-outer_loop+1,1} = full_v{i,1};
% % % %     
% % % %     parralel_chip{i-outer_loop+1,2} = full_v{i,2};
% % % %     
% % % %     parralel_chip{i-outer_loop+1,3} = full_v{i,3};
% % % %     
% % % %     end
% % % %     
% % % %     parfor inner_loop = 1:size(parralel_chip,1)
% % % %         
% % % %     A1= full_v{inner_loop,1};   
% % % %         
% % % %     B1= full_v{inner_loop,2};   
% % % %     
% % % %     dt = full_v{inner_loop,3};    
% % % %     
% % % %        %This function will correlate the two images.      
% % % %     
% % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % %     [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % %     elseif strcmpi(inputs{41,2}, 'Single') 
% % % %         
% % % %     %set maximum expected velocity 
% % % %     max_expected = round(dt * inputs{8,2}/mean_resolution);  % Rounding is necessary
% % % %     
% % % %     % make minimum limit, else can become too small if close images.
% % % %     if max_expected < inputs{23,2}
% % % %     max_d = inputs{23,2};
% % % %     else
% % % %     max_d = max_expected;
% % % %     end
% % % %         
% % % %     [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d,inputs{38,2});
% % % %     else
% % % %     disp('Check bottom of inputs file for single or multipass entry')
% % % %     end
% % % %     
% % % %     %%   Convert to velocity and filter it
% % % %     
% % % %     %flip it
% % % %     u = flipud(u);
% % % %     v = flipud(v);
% % % % 
% % % %     % filter out portions with signal to noise lower than a given value
% % % %     % implement value
% % % %     if strcmpi(inputs{41,2}, 'Single') 
% % % %     snr = C./Cnoise;
% % % %     end
% % % %     u(snr<inputs{36,2}) = NaN;
% % % %     v(snr<inputs{36,2}) = NaN;
% % % % 
% % % %     % calculate flow direction and Velocity
% % % % 
% % % %     [V,fd] = xytoV(u, v, mean_resolution, dt);
% % % %     
% % % %     if strcmpi(inputs{9,2}, 'Yes')
% % % %     
% % % %     %Remove areas flowing in wrong direction (change direction for specific
% % % %     %glaciers or remove, on Amalia it is all flowing W)
% % % %         
% % % %     fd(fd>inputs{37,2})=-1;    
% % % %     fd(fd<inputs{10,2})=-1;     
% % % % 
% % % %     
% % % %     V(fd==-1)=NaN;
% % % %     fd(fd==-1)=NaN;
% % % % 
% % % %     end
% % % %     
% % % %     %Remove areas with unrealistic values
% % % %     
% % % %     %Firstly points with too fast velocities
% % % %     filtermask = myfilter(V, inputs);
% % % % 
% % % %     V(filtermask == 1) = NaN;
% % % %     
% % % %     fd(filtermask == 1) = NaN;
% % % %     
% % % %     %Finally apply a selective interpolation and smoothing algorithm to
% % % %     %infill the gaps created and prior non-tracked values without creating
% % % %     %spurious peaks/troughs. If not sufficient data is present in the area
% % % %     %to make an interpolation, it will not be done.
% % % %     
% % % %     % First pass with a small window size and higher tolerance to fill
% % % %     % small gaps:
% % % %     
% % % %     V = nanfillsm(V,inputs,2,2);
% % % %     
% % % %     %Second pass with larger window size and lower tolerance to fill any
% % % %     %remaining larger holes:
% % % %     
% % % % %     V = nanfillsm(V,inputs,3,5);
% % % %         
% % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % %     
% % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % 
% % % % %     %flip it
% % % % %     %make the mask the right size and flip it to the right orientation
% % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % %     end
% % % % %     %crop all outside of mask to no value (NaN)
% % % %     
% % % %     V(mask==0) = NaN;
% % % %     fd(mask==0) = NaN;
% % % %    
% % % %     %import results to master index before loop continues. Name first
% % % %     %row of each.
% % % %     newcol1{inner_loop,1}=V;
% % % % 
% % % %     newcol2{inner_loop,1}=fd;       
% % % %         
% % % %     end %parfor end
% % % %     
% % % %     for i = outer_loop:second_limit
% % % %         
% % % %     column_v{i,1} = newcol1{i-outer_loop+1,1};
% % % %     
% % % %     column_fd{i,1} = newcol2{i-outer_loop+1,1};
% % % % 
% % % %     end
% % % %     
% % % %     %calculate approx percent completed
% % % %     
% % % %     percent_completed = 100*second_limit/size(full_v,1);
% % % %     
% % % %     text_percent = ['Approximatively'  ' '  num2str(percent_completed)  '%'  ' '  'of image pairs calculated'];
% % % %     
% % % %     disp(text_percent);
% % % %     
% % % % end %'outer loop' end

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

% % % % % %% interval loop
% % % % % for time_loop = 1:inputs{20,2}  %for multisampling in time
% % % % %     dum1 = 6+time_loop+array_pos;
% % % % %     dum2 = 7+time_loop+array_pos;
% % % % %    parfor inner_loop = 2:inputs{34,2}-time_loop  %main loop
% % % % %     loop2 = inner_loop+time_loop; %for multisampling in time, will skip one for higher time_bracket
% % % % % 
% % % % %     %Work out time between two images, if too long then do not run
% % % % %     %templatematch.
% % % % %     
% % % % %     A1_t= (images{inner_loop,5});
% % % % %     B1_t= (images{loop2,5});
% % % % %     
% % % % %     timestep = (B1_t-A1_t)/365;
% % % % %     
% % % % %     if timestep <= inputs{21,2} && timestep >= inputs{22,2}
% % % % %     
% % % % % 
% % % % %     A1= (images{inner_loop,3});
% % % % %     B1= (images{loop2,3});
% % % % %     
% % % % %     dt = 0;
% % % % %     
% % % % %     %this loop accounts for several dt steps where dum > 1
% % % % %     %(non-consecutive images being considered).
% % % % %     for iit = inner_loop+1:loop2
% % % % %         dt = dt + images{iit,6};
% % % % %         
% % % % %     end
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
% % % % %    %This function will correlate the two images.      
% % % % %     
% % % % % if strcmpi(inputs{41,2}, 'Multi') 
% % % % % [~,~,u,v,snr]=GIVtrackmulti(A1,B1,inputs{40,2},inputs{39,2});
% % % % % elseif strcmpi(inputs{41,2}, 'Single') 
% % % % % [u, v, C, Cnoise]=GIVtrack(A1,B1,inputs,max_d,inputs{38,2});
% % % % % else
% % % % %     disp('Check bottom of inputs file for single or multipass entry')
% % % % % end
% % % % % 
% % % % %     %%   Convert to velocity and filter it
% % % % %     
% % % % %     %flip it
% % % % %     u = flipud(u);
% % % % %     v = flipud(v);
% % % % % 
% % % % %     % filter out portions with signal to noise lower than a given value
% % % % %     % implement value
% % % % %     if strcmpi(inputs{41,2}, 'Single') 
% % % % %     snr = C./Cnoise;
% % % % %     end
% % % % %     u(snr<inputs{36,2}) = NaN;
% % % % %     v(snr<inputs{36,2}) = NaN;
% % % % % 
% % % % %     % calculate flow direction
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
% % % % %     if strcmpi(inputs{41,2}, 'Multi') 
% % % % %     
% % % % %     mask = flipud((interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1)))));
% % % % % 
% % % % %     %flip it
% % % % %     %make the mask the right size and flip it to the right orientation
% % % % %     else
% % % % %      mask = (interp2(images{2,3}, linspace(1, size(images{2,3},2), size(V,2)).', linspace(1, size(images{2,3},1), size(V,1))));
% % % % %     end
% % % % %     %crop all outside of mask to no value (NaN)
% % % % %     
% % % % %     V(mask==0) = NaN;
% % % % %     fd(mask==0) = NaN;
% % % % %    
% % % % %     %import results to master index before loop continues. Name first
% % % % %     %row of each.
% % % % %     newcol1{inner_loop,1}=V;
% % % % % 
% % % % %     newcol2{inner_loop,1}=fd;
% % % % %    
% % % % %     % % PLOTS
% % % % % 
% % % % %     if strcmpi(inputs{29,2}, 'Yes')
% % % % %     figure;    
% % % % %     % plot at each timestep. I like to see what is happening. Remove this
% % % % %     % part for speed when running in background or many images.
% % % % %     [~, hContour] = contourf(V,'LineColor','w');
% % % % %     title(strcat('Dates: ',images{inner_loop,2},'__and__',images{loop2,2}));
% % % % %     drawnow;  % this is important, to ensure that FacePrims is ready in the next line!
% % % % %     hFills = hContour.FacePrims;  % array of TriangleStrip objects
% % % % %     [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
% % % % %     for idx = 1 : numel(hFills)
% % % % %     hFills(idx).ColorData(4) = 120;   % default=255
% % % % %     end
% % % % %     c = colorbar;
% % % % %     c.Label.String = 'Ice Velocity (m/yr)';
% % % % %     hold on
% % % % %     q = quiver(u,v);
% % % % %     c = q.Color;
% % % % %     q.Color = 'black';
% % % % %     hold off
% % % % %     end
% % % % %     
% % % % %     %display point in loop, to keep track of progress.
% % % % %     disp(inner_loop)
% % % % %     disp(time_loop)
% % % % %     
% % % % %    
% % % % %     %display date of first image in pair
% % % % %     disp(images{inner_loop,2})
% % % % %     %display date of second image in pair
% % % % %     disp(images{loop2,2})
% % % % %     
% % % % %     end
% % % % %     
% % % % %    
% % % % %    end
% % % % %    
% % % % % for i=2:inputs{34,2}-time_loop %now import to master array outside of parralel loop
% % % % %     images{i,dum1}=newcol1{i};
% % % % %     images{i,dum2}=newcol2{i};
% % % % % end
% % % % % 
% % % % % newcol1 = {}; %empty arrays again
% % % % % newcol2 = {};
% % % % % 
% % % % %     name1 = strcat('Velocity total_',num2str(time_loop)); %add column labels
% % % % %     images{1,dum1}= name1;
% % % % % 
% % % % %     name2 = strcat('Flow direction_',num2str(time_loop));
% % % % %     images{1,dum2}= name2;   
% % % % % 
% % % % % time_loop = time_loop+1;
% % % % % array_pos = array_pos+1;
% % % % % end

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