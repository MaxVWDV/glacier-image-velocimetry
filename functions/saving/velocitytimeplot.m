 function velocitytimeplot(vtplotinputs)
%This function loads the previously saved data, and according to the inputs
%of a user plots the monthly averages and/or the raw data at one point over
%time.

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

%% First load the previously saved data in

my_path_velocitytimeplot = uigetdir('./Results','SELECT YOUR SAVE FILE');
load(strcat(my_path_velocitytimeplot,'/Matlab data files/Run input parameters.mat'));
load(strcat(my_path_velocitytimeplot,'/Matlab data files/Raw Images array.mat'));
load(strcat(my_path_velocitytimeplot,'/Matlab data files/Stacked and averaged data array.mat'));
load(strcat(my_path_velocitytimeplot,'/Matlab data files/Monthly averages data array.mat'));

%DATA IS NOW LOADED BACK IN. DOING IT THIS WAY MEAN THIS FUNCTION CAN BE
%RUN INDEPENDANTLY OF THE MAIN RUN AT ANY LATER TIME.
%% Calculate positions of lat long data provided on grid, cycle through different data provided
for latlongloop = 1:size(vtplotinputs{1,2}, 1)
    if vtplotinputs{1,2}(latlongloop)~=0
        longpoint = vtplotinputs{1,2}(latlongloop,2);
        latpoint = vtplotinputs{1,2}(latlongloop,1);

        % Find lat/long of point in image
        x_position = round(inputs.sizevel(2)*(longpoint-inputs.minlon)/(inputs.maxlon-inputs.minlon));
        y_position = round(inputs.sizevel(1)*(latpoint-inputs.minlat)/(inputs.maxlat-inputs.minlat));

        % Check point is not on the edge of the image
        if x_position > inputs.sizevel(2) - vtplotinputs{2,2} 
            x_position = inputs.sizevel(2) - vtplotinputs{2,2} ;
        end

        if x_position < 1 + vtplotinputs{2,2} 
            x_position = 1 + vtplotinputs{2,2};
        end

        if y_position > inputs.sizevel(1) - vtplotinputs{2,2} 
            y_position = inputs.sizevel(1) - vtplotinputs{2,2} ;
        end

        if y_position < 1 + vtplotinputs{2,2} 
            y_position = 1 + vtplotinputs{2,2};
        end

        %% Calculate time series for raw data
        if strcmpi(vtplotinputs{3,2}, 'Yes')

        %% Load the time data for raw velocities
        meta_dum = 0;
        array_pos = 0;
        emptycount_inner = 0;
        emptycount_outer = 0;
        number_in_range = 0;
        number_with_values = (size(images,2)-6)/2;  
        for i = 8:2:8+(number_with_values*2)-1
            for i2 = 2:size(images,1)
                if ~isempty(images{i2,i})
                    number_in_range = number_in_range+1;
                end
            end
        end

        full_date = NaN(number_in_range,1);
 
        for time_loop = 1:number_with_values
            dum1 = time_loop + 6 + array_pos;
            for inner_loop = 2:inputs.numimages-time_loop
                if ~isempty(images{inner_loop,dum1})
                    %calculate time interval
                    time_gap = (images{inner_loop+time_loop,5}-images{inner_loop,5});
                    % Here calculates a median date for the interval that we will use
                    date_current = round(images{inner_loop+time_loop,4}-(time_gap/2));
                    full_date(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= date_current;
                    full_date(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,2)= time_gap;   
                else
                    emptycount_inner = emptycount_inner + 1;
                end
            end
            emptycount_outer = emptycount_outer + emptycount_inner;
            emptycount_inner = 0;
            meta_dum = meta_dum + inputs.numimages-time_loop-1;
            array_pos = array_pos + 1;
        end
        %append this array to the full velocity array
        full_velocity_array = NaN(size(images_stack{1,2},1),size(images_stack{1,2},2)+1);
        full_velocity_array(:,1) = full_date(:,1);
        full_velocity_array(:,2:end) = images_stack{1,2};
        %sort based on date
        full_velocity_array = sortrows(full_velocity_array,1);
        %Make an array of all the positions to calculate
        all_positions = [];
        position_place = 1;
        for position_loop = x_position - vtplotinputs{2,2} : x_position + vtplotinputs{2,2}
            y_moved = abs(vtplotinputs{2,2}-(position_loop-x_position));
            for position_loop_2 = y_position-y_moved : y_position+y_moved
                all_positions(position_place,1) =  position_loop*inputs.sizevel(1)-position_loop_2+1;
                position_place = position_place+1;
            end
        end
        % Calculate mean of all of these positions, for each date. Note the +1
        % because of the date column.
        final_velocity_array = [];
        for date_loop = 1:size(full_velocity_array,1)
            inner_array = [];
            for position_loop = 1:size(all_positions,1)
                inner_array(position_loop,1) = full_velocity_array(date_loop,all_positions(position_loop)+1);
            end
            final_velocity_array(date_loop,2) = nanmean(inner_array,'all');
        end
        final_velocity_array(:,1) = full_date(:,1);
        %Create a new, similar array to save with 4 columns for year, month, day
        %and velocity
        save_velocity_array = [];
        for time_loop = 1:size(final_velocity_array,1)
            save_velocity_array(time_loop,1) = year(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
            save_velocity_array(time_loop,2) = month(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
            save_velocity_array(time_loop,3) = day(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
            save_velocity_array(time_loop,4) = final_velocity_array(time_loop,2);
        end 

        % Now lets save a .csv file of results that can be opened in excel
        if ~exist(strcat(my_path_velocitytimeplot,'/csv files of raw timeseries'))
            mkdir(strcat(my_path_velocitytimeplot,'/csv files of raw timeseries'));
        end
        writematrix(save_velocity_array,strcat(my_path_velocitytimeplot,'/csv files of raw timeseries/','Velocities_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.csv'))

        % Finally, let's save a png plot of the image
        if ~exist(strcat(my_path_velocitytimeplot,'/png files of raw timeseries'))
            mkdir(strcat(my_path_velocitytimeplot,'/png files of raw timeseries'));
        end
        
        %Saving hidden figure
        x_axis_date = [];
        for i = 1:size(save_velocity_array,1)
            x_axis_date(i,1) = save_velocity_array(i,1) + save_velocity_array(i,2)/12 + save_velocity_array(i,3)/365;
        end
        h = figure;set(h, 'Visible', 'off');
        h = errorbar(x_axis_date(:,1),save_velocity_array(:,4),0.0014*full_date(:,2),'horizontal','LineStyle','none');
        h.Color = [0.2,0.2,0.2,0.1];
        h.CapSize = 0;
        saveas(h,strcat(my_path_velocitytimeplot,'/png files of raw timeseries/','Velocities_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.png'))

        % NOW DO THE SAME FOR FLOW DIRECTION IF WANTED
        if strcmpi(vtplotinputs{5,2}, 'Yes')
            %append this array to the full flow direction array
            full_fd_array = NaN(size(images_stack{1,2},1),size(images_stack{1,2},2)+1);
            full_fd_array(:,1) = full_date(:,1);
            full_fd_array(:,2:end) = images_stack{2,2};
            %sort based on date
            full_fd_array = sortrows(full_fd_array,1);
            %Make an array of all the positions to calculate
            all_positions = [];
            position_place = 1;
            for position_loop = x_position - vtplotinputs{2,2} : x_position + vtplotinputs{2,2}
                y_moved = abs(vtplotinputs{2,2}-(position_loop-x_position));
                for position_loop_2 = y_position-y_moved : y_position+y_moved
                    all_positions(position_place,1) =  position_loop*inputs.sizevel(1)-position_loop_2+1;
                    position_place = position_place+1;
                end
            end      
            % Calculate mean of all of these positions, for each date. Note the +1
            % because of the date column.
            final_fd_array = [];
            for date_loop = 1:size(full_fd_array,1)
                inner_array = [];
                for position_loop = 1:size(all_positions,1)
                    inner_array(position_loop,1) = full_fd_array(date_loop,all_positions(position_loop)+1);
                end
                final_fd_array(date_loop,2) = nanmean(inner_array,'all');
            end
            final_fd_array(:,1) = full_date(:,1);

            %Create a new, similar array to save with 4 columns for year, month, day
            %and fd
            save_fd_array = [];
            for time_loop = 1:size(final_fd_array,1)
                save_fd_array(time_loop,1) = year(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
                save_fd_array(time_loop,2) = month(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
                save_fd_array(time_loop,3) = day(datetime(full_date(time_loop,1),'ConvertFrom','datenum'));
                save_fd_array(time_loop,4) = final_fd_array(time_loop,2);
            end 

            % Now lets save a .csv file of results that can be opened in excel
            if ~exist(strcat(my_path_velocitytimeplot,'/csv files of raw timeseries'))
                mkdir(strcat(my_path_velocitytimeplot,'/csv files of raw timeseries'));
            end
            writematrix(save_fd_array,strcat(my_path_velocitytimeplot,'/csv files of raw timeseries/','FD_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.csv'))

            % Finally, let's save a png plot of the image
            if ~exist(strcat(my_path_velocitytimeplot,'/png files of raw timeseries'))
                mkdir(strcat(my_path_velocitytimeplot,'/png files of raw timeseries'));
            end

            %Saving hidden figure
            for i = 1:size(save_fd_array,1)
                x_axis_date(i,1) = save_fd_array(i,1) + save_fd_array(i,2)/12 + save_fd_array(i,3)/365;
            end
            h = figure;set(h, 'Visible', 'off');
            h = errorbar(x_axis_date(:,1),save_fd_array(:,4),0.0014*full_date(:,2),'horizontal','LineStyle','none');
            h.Color = [0.2,0.2,0.2,0.1];
            h.CapSize = 0;  
            saveas(h,strcat(my_path_velocitytimeplot,'/png files of raw timeseries/','FD_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.png'))    
    
    end %end for fd loop
end %end for raw data loop

%NOW CALCULATE MONTHLY DATA. THIS IS SLIGHTLY EASIER AS IT IS ALREADY
%SORTED IN ORDER.

if strcmpi(vtplotinputs{4,2}, 'Yes')
    %Make an array of all the positions to calculate. Here need pairs of
    %coordinates rather than single value as velocities have not been
    %linearized.
    all_positions = {};
    position_place = 1;
    for position_loop = x_position - vtplotinputs{2,2} : x_position + vtplotinputs{2,2}
        y_moved = abs(vtplotinputs{2,2}-(position_loop-x_position));
        for position_loop_2 = y_position-y_moved : y_position+y_moved
           all_positions{position_place,1} =  [position_loop_2, position_loop];
           position_place = position_place+1;
       end
    end 
    % Calculate mean of all of these positions, for each date. 
	final_velocity_array = [];
    for date_loop = 1:size(monthly_averages,1)
        inner_array = [];
        for position_loop = 1:size(all_positions,1)
            inner_array(position_loop,1) = monthly_averages{date_loop,3}(all_positions{position_loop,1}(1),all_positions{position_loop,1}(2));
        end
        final_velocity_array(date_loop,2) = nanmean(inner_array,'all');
    end
    x_axis_date = [];
    for loop = 1:size(monthly_averages,1)
        x_axis_date(loop) = monthly_averages{loop,1} + monthly_averages{loop,2}/12;
    end
    final_velocity_array(:,1) = x_axis_date(1,:)';

    %Create a new, similar array to save with 4 columns for year, month, day
    %and velocity
    save_velocity_array = [];
    for time_loop = 1:size(final_velocity_array,1)
        save_velocity_array(time_loop,1) = monthly_averages{time_loop,1};
        save_velocity_array(time_loop,2) = monthly_averages{time_loop,2};
        save_velocity_array(time_loop,3) = final_velocity_array(time_loop,2);
    end 
    % Now lets save a .csv file of results that can be opened in excel
    if ~exist(strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries'))
        mkdir(strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries'));
    end
    writematrix(save_velocity_array,strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries/','Velocities_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.csv'))
    % Finally, let's save a png plot of the image
    if ~exist(strcat(my_path_velocitytimeplot,'/png files of monthly timeseries'))
        mkdir(strcat(my_path_velocitytimeplot,'/png files of monthly timeseries'));
    end
	%Saving hidden figure
    h = figure;set(h, 'Visible', 'off');
    h = plot(final_velocity_array(:,1),final_velocity_array(:,2),'k-o');
    saveas(h,strcat(my_path_velocitytimeplot,'/png files of monthly timeseries/','Velocities_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.png'));
    if strcmpi(vtplotinputs{5,2}, 'Yes')
        %Make an array of all the positions to calculate. Here need pairs of
        %coordinates rather than single value as velocities have not been
        %linearized.
        all_positions = {};
        position_place = 1;
        for position_loop = x_position - vtplotinputs{2,2} : x_position + vtplotinputs{2,2}
            y_moved = abs(vtplotinputs{2,2}-(position_loop-x_position));
            for position_loop_2 = y_position-y_moved : y_position+y_moved
                all_positions{position_place,1} =  [position_loop_2, position_loop];
                position_place = position_place+1;
            end
        end 
        % Calculate mean of all of these positions, for each date. 
        final_fd_array = [];
        for date_loop = 1:size(monthly_averages,1)
            inner_array = [];
            for position_loop = 1:size(all_positions,1)
                inner_array(position_loop,1) = monthly_averages{date_loop,4}(all_positions{position_loop,1}(1),all_positions{position_loop,1}(2));
            end
            final_fd_array(date_loop,2) = nanmean(inner_array,'all');
        end
        for loop = 1:size(monthly_averages,1)
            x_axis_date(loop) = monthly_averages{loop,1} + monthly_averages{loop,2}/12;
        end
        final_fd_array(:,1) = x_axis_date;

        %Create a new, similar array to save with 3 columns for year, month, day
        %and fd 
        save_fd_array = [];
        for time_loop = 1:size(final_fd_array,1)
            save_fd_array(time_loop,1) = monthly_averages{time_loop,1};
            save_fd_array(time_loop,2) = monthly_averages{time_loop,2};
            save_fd_array(time_loop,3) = final_fd_array(time_loop,2);
        end 

        % Now lets save a .csv file of results that can be opened in excel
        if ~exist(strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries'))
                mkdir(strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries'));
        end
        writematrix(save_fd_array,strcat(my_path_velocitytimeplot,'/csv files of monthly timeseries/','FD_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.csv'))

        % Finally, let's save a png plot of the image
        if ~exist(strcat(my_path_velocitytimeplot,'/png files of monthly timeseries'))
            mkdir(strcat(my_path_velocitytimeplot,'/png files of monthly timeseries'));
        end
        
        %Saving hidden figure
        h = figure;set(h, 'Visible', 'off');
        h = plot(final_fd_array(:,1),final_fd_array(:,2),'k-o');
        saveas(h,strcat(my_path_velocitytimeplot,'/png files of monthly timeseries/','FD_lat=',num2str(latpoint),'_long=',num2str(longpoint),'.png'));
    end %end for monthly averages (flow direction if loop)
    
end %end for monthly averages loop

    end %end for ~empty condition

end %end for main loop

logo = imread('GIV_LOGO_SMALL.png');

msgbox({'ALL TIMESERIES POINTS HAVE BEEN EXTRACTED AND SAVED TO THE RESULTS FOLDER. SEE USER MANUAL FOR MORE DETAILS.'},...
    'TIMESERIES EXTRACTION COMPLETE.','custom',logo);