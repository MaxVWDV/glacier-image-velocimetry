function [images, images_stack]=filtall(images,inputs)
% %% Take newly created velocity maps and filter based upon entire time series
% %
% %Aim here is to use the information from the entire dataset to filter
% %individual velocity maps- including the knowledge that glacier velocity
% %will be smoothly varying through time (no jumps) and will only vary at a
% %relatively slow rate in general.


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

%% calculate velocity statistics

%Initialize
meta_dum = 0;
array_pos = 0;
emptycount_inner = 0;
emptycount_outer = 0;
number_in_range = 0;
number_with_values = (size(images,2)-6)/2;

%loop through all images
for time_loop = 1:number_with_values
    position1 = 6+time_loop*2;
    for inner_loop = 2:inputs.numimages-time_loop
        if ~isempty(images{inner_loop,position1})
            number_in_range = number_in_range + 1;
        end
    end
end

%Create matrix to store all x and y velocity components
full_u = NaN(number_in_range,inputs.sizevel(1)*inputs.sizevel(2)+2);
full_v = NaN(number_in_range,inputs.sizevel(1)*inputs.sizevel(2)+2);

%loop through all
for time_loop = 1:number_with_values
    position1 = time_loop + 6 + array_pos;
    position2 = time_loop + 7 + array_pos;
    for inner_loop = 2:inputs.numimages-time_loop
        if ~isempty(images{inner_loop,position1})
            %calculate time interval
            time_gap = (images{inner_loop+time_loop,5}-images{inner_loop,5});
            % Here calculates a median date for the interval that we will use
            date_current = round(images{inner_loop+time_loop,4}-(time_gap/2));
            full_u(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= date_current;
            full_v(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= date_current;
            
            %Recreate x-y velocity from V and fd
            [u,v] = Vtoxy(images{inner_loop,position1},images{inner_loop,position2});
            
            %Linearize each velocity map
            lin_u = reshape(u,[1 inputs.sizevel(1)*inputs.sizevel(2)]);
            full_u(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,3:inputs.sizevel(1)*inputs.sizevel(2)+2)= lin_u;
            
            %Linearize each flow direction map
            lin_v = reshape(v,[1 inputs.sizevel(1)*inputs.sizevel(2)]);
            full_v(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,3:inputs.sizevel(1)*inputs.sizevel(2)+2)= lin_v;
        else
            emptycount_inner = emptycount_inner + 1;
        end
    end
    
    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
    meta_dum = meta_dum + inputs.numimages-time_loop-1;
    array_pos = array_pos + 1;
end

%Create a column with sequential numbers in order for the initial order to
%be recovered (we are going to sort by date to filter). Add to second
%column so that sortrows function can sort by date (looks at first column).
numbers_order=(1:size(full_u,1))';
full_u(:,2) = numbers_order;
full_v(:,2) = numbers_order;

% Sort based on date.
full_u = sortrows(full_u, 1);
full_v = sortrows(full_v, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%strip the numbering and date list off the main array and store separately.
only_numlist = full_u(:,2); %list of numbers for re-ordering

%delete first two columns to leave just data itself
full_u(:,1:2)=[];
full_v(:,1:2)=[];

%% remove outliers in stack
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_stand_dev = 2; %Number of standard deviations to consider outliers. Set to 2 by default

%u (x velocity component).
mean_u = nanmean(full_u);
std_u = nanstd(full_u);

% find points in the stack that are more than xx standard deviations outside
% of the mean.
low_u = mean_u - num_stand_dev * std_u;
high_u = mean_u + num_stand_dev * std_u;
full_low_u = [];
full_high_u = [];

%faster than repmat
for index = 1:size(full_u,1) %make full arrays of limits
    full_low_u(index,:) = low_u;
    full_high_u(index,:) = high_u;
end

%create array of where it is out of limits
out_limits_low_u = double(full_u < full_low_u);
out_limits_high_u = double(full_u > full_high_u);
out_limits_u = double((out_limits_low_u + out_limits_high_u)>=1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%v (y velocity component).
mean_v = nanmean(full_v);
std_v = nanstd(full_v);

% find points in the stack that are more than xx standard deviations outside
% of the mean.
low_v = mean_v - num_stand_dev * std_v;
high_v = mean_v + num_stand_dev * std_v;
full_low_v = [];
full_high_v = [];

%faster than repmat
for index = 1:size(full_v,1) %make full arrays of limits
    full_low_v(index,:) = low_v;
    full_high_v(index,:) = high_v;
end

%create array of where it is out of limits
out_limits_low_v = double(full_v < full_low_v);
out_limits_high_v = double(full_v > full_high_v);
out_limits_v = double((out_limits_low_v + out_limits_high_v)>=1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove values more than 2 std away from mean in either u or v
full_u(out_limits_u==1)=NaN;
full_v(out_limits_u==1)=NaN;
full_u(out_limits_v==1)=NaN;
full_v(out_limits_v==1)=NaN;

%% Filter data in time and space if requested


%TIME FILTER
if strcmpi(inputs.finalsmooth, 'Time')
    full_u = nanfill_time(full_u, inputs, 2, 3);
    full_v = nanfill_time(full_v, inputs, 2, 3);
    %TIME AND SPACE FILTER
elseif strcmpi(inputs.finalsmooth, 'Time and Space')
    full_u = nanfill_timeandspace(full_u, inputs, 4, 3);
    full_v = nanfill_timeandspace(full_v, inputs, 4, 3);
end


%% Calculate statistics in x-y space

%Mean
mean_u = nanmean(full_u);
mean_v = nanmean(full_v);

%std
std_u = nanstd(full_u);
std_v = nanstd(full_v);

%Median
median_u = nanmedian(full_u);
median_v = nanmedian(full_v);

%local smoothing and NaN filling
mean_u = nanfillsm(mean_u, 4,3);
mean_v = nanfillsm(mean_v, 4,3);
std_u = nanfillsm(std_u, 4,3);
std_v = nanfillsm(std_v, 4,3);
median_u = nanfillsm(median_u, 4,3);
median_v = nanfillsm(median_v, 4,3);



%% Convert to V - fd space

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate some additional statistics: Minimum, Maximum, Median, 'Percent
%error'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Mean
[mean_vel,mean_fd] = xytoV_basic(mean_u,mean_v);
mean_vel=reshape(mean_vel,inputs.sizevel);
mean_fd=reshape(mean_fd,inputs.sizevel);

%Median
[median_vel,median_fd] = xytoV_basic(median_u,median_v);
median_vel=reshape(median_vel,inputs.sizevel);
median_fd=reshape(median_fd,inputs.sizevel);

%Min
[min_vel,min_fd] = xytoV_basic(min(mean_u-std_u,mean_u+std_u),min(mean_v-std_v,mean_v+std_v));
min_vel=reshape(min_vel,inputs.sizevel);
min_fd=reshape(min_fd,inputs.sizevel);

%Max
[max_vel,max_fd] = xytoV_basic(max(mean_u-std_u,mean_u+std_u),max(mean_v-std_v,mean_v+std_v));
max_vel=reshape(max_vel,inputs.sizevel);
max_fd=reshape(max_fd,inputs.sizevel);

%std
std_vel = max_vel-min_vel;
fdtemp(:,:,1) = max_fd-min_fd; fdtemp(:,:,2) = min_fd-max_fd; fdtemp(:,:,3) = max_fd+360-min_fd; fdtemp(:,:,4) = min_fd+360-max_fd;
std_fd = min(fdtemp,[],3); %Smallest angle
std_vel=reshape(std_vel,inputs.sizevel);
std_fd=reshape(std_fd,inputs.sizevel);

perc_error_vel = 100*std_vel./mean_vel;

%% Covert back to V, fd stack and order


%Add back in numbering scheme, sort rows back into order then remove it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[ordered_vel(:,2:inputs.sizevel(1)*inputs.sizevel(2)+1), ...
    ordered_fd(:,2:inputs.sizevel(1)*inputs.sizevel(2)+1)]...
    =xytoV_basic(full_u,full_v);
ordered_vel(:,1)=only_numlist;
ordered_fd(:,1)=only_numlist;
ordered_vel = sortrows(ordered_vel, 1);
ordered_fd = sortrows(ordered_fd, 1);
ordered_vel(:,1)=[];
ordered_fd(:,1)=[];


%% Create output array with useful data in it

%initialize stack
images_stack = {};

%Load data into it
%All velocities (for plotting timeseries and querying points)
images_stack{1,1} = 'Full Velocity Array';   images_stack{1,2} = ordered_vel;

%All flow directions (for plotting timeseries and querying points)
images_stack{2,1} = 'Full Flow Direction Array';   images_stack{2,2} = ordered_fd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load additional statistics into output array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

images_stack{3,1} = 'Mean Velocity';   images_stack{3,2} = mean_vel;
images_stack{5,1} = 'Velocity Standard Deviation';   images_stack{5,2} = std_vel;

images_stack{4,1} = 'Mean Flow Direction';   images_stack{4,2} = mean_fd;
images_stack{6,1} = 'Flow Direction Standard Deviation';   images_stack{6,2} = std_fd;

images_stack{7,1} = 'Median Velocity';   images_stack{7,2} = median_vel;
images_stack{8,1} = 'Median Flow Direction';   images_stack{8,2} = median_fd;

images_stack{9,1} = 'Maximum Velocity';   images_stack{9,2} = max_vel;
images_stack{10,1} = 'Maximum Flow Direction';   images_stack{10,2} = max_fd;

images_stack{11,1} = 'Minimum Velocity';   images_stack{11,2} = min_vel;
images_stack{12,1} = 'Minimum flow direction';   images_stack{12,2} = min_fd;

images_stack{13,1} = 'Percentage Error-Variability in Velocity';   images_stack{13,2} = perc_error_vel;

%Mean and standard deviation of velocity arrays
images_stack{14,1} = 'Mean Velocity x component';   images_stack{14,2} = reshape(mean_u,inputs.sizevel);
images_stack{15,1} = 'Velocity x component Standard Deviation';   images_stack{15,2} = reshape(std_u,inputs.sizevel);

%Mean and standard deviation of velocity arrays
images_stack{16,1} = 'Mean Velocity y component';   images_stack{16,2} = reshape(mean_v,inputs.sizevel);
images_stack{17,1} = 'Velocity y component Standard Deviation';   images_stack{17,2} = reshape(std_v,inputs.sizevel);

images_stack{18,1} = 'Median Velocity x component';   images_stack{18,2} = reshape(median_u,inputs.sizevel);
images_stack{19,1} = 'Median Velocity y component';   images_stack{19,2} = reshape(median_v,inputs.sizevel);


