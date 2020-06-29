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

%% calculate mean value

meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

number_in_range = 0;

number_with_values = (size(images,2)-6)/2;

for time_loop = 1:number_with_values
    dum1 = 6+time_loop*2;
 for inner_loop = 2:inputs{34,2}-time_loop

    if ~isempty(images{inner_loop,dum1})
        
    number_in_range = number_in_range + 1;

    end
    
 end
end; 

full_v = NaN(number_in_range,inputs{13,2}(1)*inputs{13,2}(2)+2);

full_fd = NaN(number_in_range,inputs{13,2}(1)*inputs{13,2}(2)+2);
  
for time_loop = 1:number_with_values
    dum1 = time_loop + 6 + array_pos;
    dum2 = time_loop + 7 + array_pos;
 for inner_loop = 2:inputs{34,2}-time_loop

    if ~isempty(images{inner_loop,dum1})
        
    %calculate time interval
    
    time_gap = (images{inner_loop+time_loop,5}-images{inner_loop,5});
    
    % Here calculates a median date for the interval that we will use
    
    date_current = round(images{inner_loop+time_loop,4}-(time_gap/2));
    
    full_v(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= date_current;
    
    full_fd(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= date_current;
    
    %Linearize each velocity map

    lin_v = reshape(images{inner_loop,dum1},[1 inputs{13,2}(1)*inputs{13,2}(2)]);
    
    full_v(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,3:inputs{13,2}(1)*inputs{13,2}(2)+2)= lin_v;
      
    %Linearize each flow direction map
    
    lin_fd = reshape(images{inner_loop,dum2},[1 inputs{13,2}(1)*inputs{13,2}(2)]);
    
    lin_fd(lin_fd==0)=NaN;
    
    full_fd(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,3:inputs{13,2}(1)*inputs{13,2}(2)+2)= lin_fd;
    
%     elseif isempty(images{inner_loop,dum1})
%     part_date(inner_loop-1,:)= NaN;
%     part_v(inner_loop-1,1:inputs{13,2}(1)*inputs{13,2}(2))= NaN;
%     part_fd(inner_loop-1,1:inputs{13,2}(1)*inputs{13,2}(2))= NaN;
    else
        emptycount_inner = emptycount_inner + 1;
    end
    
 end
 

    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
meta_dum = meta_dum + inputs{34,2}-time_loop-1;
array_pos = array_pos + 1;
end

%Create a column with sequential numbers in order for the initial order to
%be recovered (we are going to sort by date to filter). Add to second
%column so that sortrows function can sort by date (looks at first column).

numbers_order=(1:size(full_v,1))';

full_v(:,2) = numbers_order;

full_fd(:,2) = numbers_order;

% Sort based on date.

full_v = sortrows(full_v, 1);

full_fd = sortrows(full_fd, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%strip the numbering and date list off the main array and store separately.

only_datelist = full_v(:,1); %list of dates

only_numlist = full_v(:,2); %list of numbers for re-ordering

%delete first two columns to leave just data itself

full_v(:,1:2)=[];

full_fd(:,1:2)=[];

%% remove outliers in stack

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First let's do this with the FLOW DIRECTION. Trouble is at the 359-0
% degree boundary, so will do this twice with a second FLOW DIRECTION array
% where the degree scale is moved to 180-540.

%Create this second array

full_fd_540 = full_fd;

%Transpose it

findless180 = (double(full_fd_540<180).*full_fd_540)+360;

findless180(findless180 == 360) = 0;

full_fd_540(full_fd_540<180)=0;

full_fd_540 = full_fd_540 + findless180;

% find the MEAN and STANDARD DEVIATION of each point

mean_360 = nanmean(full_fd);

mean_540 = nanmean(full_fd_540);

std_360 = nanstd(full_fd);

std_540 = nanstd(full_fd_540);

% find points in the stack that are more than 2 standard deviations outside
% of the mean of BOTH the 360 and 540 arrays (i.e. not just wavering
% between 0 and 360 degrees).

low_360 = mean_360 - 2 * std_360;

high_360 = mean_360 + 2 * std_360;

low_540 = mean_540 - 2 * std_540;

high_540 = mean_540 + 2 * std_540;

full_low_360 = [];

full_high_360 = [];

full_low_540 = [];

full_high_540 = [];

for index = 1:size(full_v,1) %make full arrays of limits
    
    full_low_360(index,:) = low_360;
    
    full_high_360(index,:) = high_360;
    
    full_low_540(index,:) = low_540;

    full_high_540(index,:) = high_540;
    
end

% where are the values outside of limits on one side

out_limits_low_360 = double(full_fd < full_low_360);
out_limits_high_360 = double(full_fd > full_high_360);

out_limits_low_540 = double(full_fd < full_low_540);
out_limits_high_540 = double(full_fd > full_high_540);

% where are the values outside of limits on either side


out_limits_360 = double((out_limits_low_360 + out_limits_high_360)>=1);

out_limits_540 = double((out_limits_low_540 + out_limits_high_540)>=1);

% where is it out of limit in BOTH (i.e. not caused by the boundary)

out_limits_fd = double((out_limits_360 + out_limits_540) == 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Secondly, lets do this for the velocities.

mean_vel = nanmean(full_v);

std_vel = nanstd(full_v);

% find points in the stack that are more than 2 standard deviations outside
% of the mean of BOTH the 360 and 540 arrays (i.e. not just wavering
% between 0 and 360 degrees).

low_vel = mean_vel - 2 * std_vel;

high_vel = mean_vel + 2 * std_vel;


full_low_vel = [];

full_high_vel = [];


for index = 1:size(full_v,1) %make full arrays of limits
    
    full_low_vel(index,:) = low_vel;
    
    full_high_vel(index,:) = high_vel;
       
end

out_limits_low_vel = double(full_v < full_low_vel);
out_limits_high_vel = double(full_v > full_high_vel);

out_limits_vel = double((out_limits_low_vel + out_limits_high_vel)>=1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%remove values more than 2 std away from mean in data

full_v(out_limits_fd==1)=NaN;

full_fd(out_limits_fd==1)=NaN;

full_v(out_limits_vel==1)=NaN;

full_fd(out_limits_vel==1)=NaN;

%% Filter data in time and space if requested

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TIME FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(inputs{42,2}, 'Time') 
    
full_v = nanfill_time(full_v, inputs, 2, 3);

% full_fd = nanfill_time(full_fd, inputs, 2, 3); %cant smooth fd in same
% way

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TIME AND SPACE FILTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

elseif strcmpi(inputs{42,2}, 'Time and Space') 

full_v = nanfill_timeandspace(full_v, inputs, 4, 3);

% full_fd = nanfill_timeandspace(full_fd, inputs, 4, 3);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%recalculate mean and std values with filtered dataset

%%%%%%%% Account for 360 - 0 cyclicity




full_fd_540 = full_fd;

%Transpose it

findless180 = (double(full_fd_540<180).*full_fd_540)+360;

findless180(findless180 == 360) = 0;

full_fd_540(full_fd_540<180)=0;

full_fd_540 = full_fd_540 + findless180;

%

% Calculate mean of each and standard deviation of each:


mean_fd = nanmean(full_fd);

std_fd = nanstd(full_fd);

mean_fd_540 = nanmean(full_fd_540);

std_fd_540 = nanstd(full_fd_540);

for i = 1:size(mean_fd,2)
    if std_fd(1,i) > std_fd_540(1,i)
        mean_fd(1,i) = mean_fd_540(1,i);
        std_fd(1,i) = std_fd_540(1,i);
    end
end

tempover = mean_fd;
tempover(tempover<360) = 0;
tempover(tempover>360) = -360;
mean_fd = mean_fd + tempover;


%%%%%%%%
mean_v = nanmean(full_v);

std_v = nanstd(full_v);

%reshape mean and std datasets 

mean_fd = (reshape(mean_fd,inputs{13,2})); %flipud

std_fd = (reshape(std_fd,inputs{13,2})); %flipud

mean_v = (reshape(mean_v,inputs{13,2})); %flipud

std_v = (reshape(std_v,inputs{13,2})); %flipud

%local smoothing and NaN filling

mean_fd = nanfillsm(mean_fd, inputs, 4, 3);

std_fd = nanfillsm(std_fd, inputs, 4, 3);

mean_v = nanfillsm(mean_v, inputs, 4, 3);

std_v = nanfillsm(std_v, inputs, 4, 3);

%% Replace files in images array

%Add back in numbering scheme, sort rows back into order then remove it
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ordered_v(:,2:inputs{13,2}(1)*inputs{13,2}(2)+1)=full_v; ordered_v(:,1)=only_numlist;

ordered_fd(:,2:inputs{13,2}(1)*inputs{13,2}(2)+1)=full_fd; ordered_v(:,1)=only_numlist;

ordered_v = sortrows(ordered_v, 1);

ordered_fd = sortrows(ordered_fd, 1);

ordered_v(:,1)=[];



ordered_fd(:,1)=[];

%Reinitialize loop parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

%Run loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for time_loop = 1:number_with_values
    dum1 = time_loop + 6 + array_pos;
    dum2 = time_loop + 7 + array_pos;
 for inner_loop = 2:inputs{34,2}-time_loop

    if ~isempty(images{inner_loop,dum1})
    
     %Replace velocity in array   
    images{inner_loop,dum1} = (reshape(ordered_v(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,:),inputs{13,2}));%flipud
    
     %Replace flow direction in array  
    images{inner_loop,dum2} = (reshape(ordered_fd(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,:),inputs{13,2}));  %flipud
    
    else
        emptycount_inner = emptycount_inner + 1;
    end
    
 end
 

    emptycount_outer = emptycount_outer + emptycount_inner;
    emptycount_inner = 0;
meta_dum = meta_dum + inputs{34,2}-time_loop-1;
array_pos = array_pos + 1;
end


%% Create output array with useful data in it


%initialize stack
images_stack = {};


%Load data into it

%All velocities (for plotting timeseries and querying points)
images_stack{1,1} = 'Full Velocity Array';   images_stack{1,2} = ordered_v;

%All flow directions (for plotting timeseries and querying points)
images_stack{2,1} = 'Full Flow Direction Array';   images_stack{2,2} = ordered_fd;


%Mean and standard deviation of velocity arrays
images_stack{3,1} = 'Mean Velocity';   images_stack{3,2} = mean_v;


images_stack{5,1} = 'Velocity Standard Deviation';   images_stack{5,2} = std_v;


%Mean and standard deviation of velocity arrays
images_stack{4,1} = 'Mean Flow Direction';   images_stack{4,2} = mean_fd;


images_stack{6,1} = 'Flow Direction Standard Deviation';   images_stack{6,2} = std_fd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculate some additional statistics: Minimum, Maximum, Median, 'Percent
%error'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Calculate values
max_fd = nanmax(full_fd);

max_v = nanmax(full_v);

min_fd = nanmin(full_fd);

min_v = nanmin(full_v);

median_fd = nanmedian(full_fd);

median_v = nanmedian(full_v);

%reshape mean and std datasets 

max_fd = (reshape(max_fd,inputs{13,2}));%flipud

max_v = (reshape(max_v,inputs{13,2}));%flipud

min_fd = (reshape(min_fd,inputs{13,2}));%flipud

min_v = (reshape(min_v,inputs{13,2}));%flipud

median_fd = (reshape(median_fd,inputs{13,2}));%flipud

median_v = (reshape(median_v,inputs{13,2}));%flipud

%local smoothing and NaN filling

max_fd = nanfillsm(max_fd, inputs, 4, 3);

max_v = nanfillsm(max_v, inputs, 4, 3);

min_fd = nanfillsm(min_fd, inputs, 4, 3);

min_v = nanfillsm(min_v, inputs, 4, 3);

median_fd = nanfillsm(median_fd, inputs, 4, 3);

median_v = nanfillsm(median_v, inputs, 4, 3);

perc_error_v = 100*std_v./mean_v;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load additional statistics into output array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

images_stack{7,1} = 'Median Velocity';   images_stack{7,2} = median_v;

images_stack{8,1} = 'Median Flow Direction';   images_stack{8,2} = median_fd;

images_stack{9,1} = 'Maximum Velocity';   images_stack{9,2} = max_v;

images_stack{10,1} = 'Maximum Flow Direction';   images_stack{10,2} = max_fd;

images_stack{11,1} = 'Minimum Velocity';   images_stack{11,2} = min_v;

images_stack{12,1} = 'Minimum flow direction';   images_stack{12,2} = min_fd;

images_stack{13,1} = 'Percentage Error-Variability in Velocity';   images_stack{13,2} = perc_error_v;
