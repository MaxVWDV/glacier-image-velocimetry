function [monthly_averages]=im2month(images,inputs,images_stack)
% This fucntion takes the 'randomly spaced' images from the timeseries and
% creates an evenly spaced timeseries of monthly averages.

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

%First create array of first and last dates for each velocity map

meta_dum = 0;
array_pos = 0;
emptycount_inner = 0;
emptycount_outer = 0;
number_with_values = (size(images,2)-6)/2;


for time_loop = 1:number_with_values
    dum1 = time_loop + 6 + array_pos;
    dum2 = time_loop + 7 + array_pos;
 for inner_loop = 2:inputs.numimages-time_loop

    if ~isempty(images{inner_loop,dum1})
        
    %calculate first and last date 
    
    Start_interval = images{inner_loop,4};
    
    End_interval = images{inner_loop+time_loop,4};

    % Add these to master arrays
      
    first_date(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= Start_interval;
    
    last_date(inner_loop+meta_dum-1-emptycount_inner-emptycount_outer,1)= End_interval;
      
    else
        emptycount_inner = emptycount_inner + 1;
    end
    
 end
 

emptycount_outer = emptycount_outer + emptycount_inner;
emptycount_inner = 0;
meta_dum = meta_dum + inputs.numimages-time_loop-1;
array_pos = array_pos + 1;
end

%This has now created arrays with the DATE CODE of each image (date code is
%numbered as 1 at the first of Jan year 0, and so on. This is not so
%workable. Let's append the year, month and day to each array

first_date(:,2) = year(datetime(first_date(:,1),'ConvertFrom','datenum'));
first_date(:,3) = month(datetime(first_date(:,1),'ConvertFrom','datenum'));
first_date(:,4) = day(datetime(first_date(:,1),'ConvertFrom','datenum'));

last_date(:,2) = year(datetime(last_date(:,1),'ConvertFrom','datenum'));
last_date(:,3) = month(datetime(last_date(:,1),'ConvertFrom','datenum'));
last_date(:,4) = day(datetime(last_date(:,1),'ConvertFrom','datenum'));

%Now let's find the first month we have data for, the last month we have
%data for and the amount of months between them.

first_year = min(first_date(:,2));
last_year = max(last_date(:,2));

% first_year_first=first_date(:,2);
% 
% first_year_first(first_year_first>first_year)=[];
% 
% first_year_filtered = first_date;
% 
% first_year_filtered(numel(first_year_first)+1:end,:) = [];

first_month = month(datetime(min(first_date(:,1)),'ConvertFrom','datenum'));

last_month = month(datetime(max(last_date(:,1)),'ConvertFrom','datenum'));

% last_year_first=last_date(:,2);
% 
% last_year_first(last_year_first<last_year)=[];
% 
% last_year_filtered = last_date;
% 
% last_year_filtered(1:end-numel(last_year_first)-1,:) = [];
% 
% last_month = max(last_year_filtered(:,3));

number_of_months = 12*(last_year - first_year) + last_month - first_month;

%Create mask

mask = ((interp2(images{2,3}, linspace(1, inputs.sizeraw(2), inputs.sizevel(2)).', linspace(1, inputs.sizeraw(1), inputs.sizevel(1))))); %flipud
                
mask_lin = reshape(mask,[1,inputs.sizevel(1)*inputs.sizevel(2)]);


%Now let's loop through the relevant years and months, determine what
%velocity maps are relevant for a given month, weight them according to the
%percentage of time that they are inside the relevant month and create an
%average for this month. We will also create a 'quality test' to determine
%whether the given month is trustworthy data or not (low, medium or high).

%Create master output arrary
monthly_averages = {};

for year_loop = first_year:last_year
    if year_loop == first_year && year_loop ~= last_year
        for month_loop = first_month:12
            %First lets create a number string with the first and last day
            %of this month
            
            first_day_code = datenum(year_loop,month_loop,01);
            if month_loop ~= 12
            last_day_code = datenum(year_loop,month_loop+1,01)-1;
            elseif month_loop == 12
            last_day_code = datenum(year_loop+1,01,01)-1;    
            end
            
            %Now let's find which velocity maps are relevant to this month
            
            inner_parameter = 1;
            
            %Let's create a temporary array to store this and the 
            %velocities in. And a second for the flow direction.
                
            current_month_v = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            current_month_fd = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            for inner_loop = 1:size(first_date,1)
                %This long formula is determining if the interval is in
                %range
                if ((first_day_code <= first_date(inner_loop,1) && first_date(inner_loop,1) <= last_day_code))...
                        | ((last_day_code >= last_date(inner_loop,1) && last_date(inner_loop,1)>= first_day_code))...
                        | ((first_date(inner_loop,1) <= first_day_code  && last_date(inner_loop,1) >= last_day_code))
                
                %Create weight parameter for this particular velocity map,
                %this will be equal to 1 if it is entirely within the
                %month, or equal to 'percentage of velocity map averaging
                %time period within this month' if not. For instance if the
                %velocity is averaged over 2 months from 1 March to 30
                %April, its weight will be 0.5 for March and April.
                
                if first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1)<= last_day_code
                    
                    %If both true, velocity map is entirely within this
                    %month.
                    weight = 1;
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) <= last_day_code
                    
                    %If it starts prior to the month relevant but finishes 
                    %prior to end of it.
                    weight = (last_date(inner_loop,1)-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                    
                elseif first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it ends after the month relevant but begins within
                    %it.
                    weight = (last_day_code-first_date(inner_loop,1))/(last_date(inner_loop,1)-first_date(inner_loop,1));                    
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it both begins before month in question and ends
                    %after it.
                    weight = (last_day_code-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                end
                
                %Add weighting parameter to the first column
                
                current_month_v(inner_parameter, 1) = weight;
                
                current_month_fd(inner_parameter, 1) = weight;


                %Add velocities to the remainder of the row
                
                %Make NANs 0
                
                %velocity
                
                temporary_row_v = images_stack{1,2}(inner_loop,:);
                
                temporary_row_v(isnan(temporary_row_v))=0;
                             
                temporary_row_v(isnan(mask_lin)) = NaN;
                
                current_month_v(inner_parameter, 2:end) = temporary_row_v;
                
                
                %flow direction
                
                
                temporary_row_fd = images_stack{2,2}(inner_loop,:);
                
                temporary_row_fd(isnan(temporary_row_fd))=0;
                             
                temporary_row_fd(isnan(mask_lin)) = NaN;
                
                current_month_fd(inner_parameter, 2:end) = temporary_row_fd;
                           
                inner_parameter = inner_parameter + 1;
                end
                  
            end
            
            %Calculate total weight for this month
            total_monthly_weight = sum(current_month_v(:, 1));
            
            %Decompose into x and y components
            [u,v] = Vtoxy(current_month_v(:,2:end),current_month_fd(:,2:end));
            
             %Calculate a weighted mean of u
            weighted_monthly_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                weighted_monthly_u = weighted_monthly_u + u(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
             %Calculate a weighted mean of v
            weighted_monthly_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                weighted_monthly_v = weighted_monthly_v + v(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
            %Calculate unweighted median of u
            median_monthly_u = nanmedian(u,1);
            
            %Calculate unweighted median of v
            median_monthly_v = nanmedian(v,1);
            
            %Calculate local weighting to account for NaN values
            local_weight_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                portion = u(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_u = local_weight_u + portion;
            end
            
             local_weight_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                portion = v(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_v = local_weight_v + portion;
            end
            
            %Divide by weight. Wrap in if loop to avoid error if all NaN.
            if ~isnan(nanmean(local_weight_u,'all'))
                
                weighted_monthly_u = weighted_monthly_u./local_weight_u;
                
            end
            
            if ~isnan(nanmean(local_weight_v,'all'))
                
                weighted_monthly_v = weighted_monthly_v./local_weight_v;
                
            end
            
            %Infill isolated NaNs and do some slight smoothing
            weighted_monthly_u = nanfill(weighted_monthly_u, 4,3);
            weighted_monthly_v = nanfill(weighted_monthly_v, 4,3);
            
            median_monthly_u = nanfill(median_monthly_u, 4,3);
            median_monthly_v = nanfill(median_monthly_v, 4,3);
            
            %We now have a linear matrix with the weighted velocities, we
            %simply need to make it the right shape.
            weighted_monthly_u = (reshape(weighted_monthly_u,inputs.sizevel));
            weighted_monthly_v = (reshape(weighted_monthly_v,inputs.sizevel));
            
            median_monthly_u = (reshape(median_monthly_u,inputs.sizevel));
            median_monthly_v = (reshape(median_monthly_v,inputs.sizevel));
            
            %Convert to weighted velocity and flow direction stats
            [weighted_monthly_velocity,weighted_monthly_fd] = xytoV_basic(weighted_monthly_u,weighted_monthly_v);
            
            %Convert to median velocity and flow direction stats
            [median_monthly_velocity,median_monthly_fd] = xytoV_basic(median_monthly_u,median_monthly_v);

            %Finally we need to load the data into the outputs array. First
            %we determine the position we are at in this array:
            
            position_in_array = 12*(year_loop-first_year) + month_loop-first_month + 1;
            
            %Then at last we load the data into this array!
            
            %First column is the year
            monthly_averages{position_in_array,1} = year_loop;
            
            %Second column is the month
            monthly_averages{position_in_array,2} = month_loop;
            
            %Third column is the mean weighted velocity
            monthly_averages{position_in_array,3} = weighted_monthly_velocity;
            
            %Fourth column is the mean weighted flow direction
            monthly_averages{position_in_array,4} = weighted_monthly_fd;
            
            %Fifth column is the median velocity
            monthly_averages{position_in_array,5} = median_monthly_velocity;
            
            %Sixth column is the median flow direction
            monthly_averages{position_in_array,6} = median_monthly_fd;
            
            %Seventh column is the quality of data for this month, as
            %determined from the total monthly weight. This uses the
            %following formula:
            %Low Reliability data : total monthly weight <= 1
            %Moderate Reliability data : 1 < total monthly weight <= 2.5
            %High Reliability data : 2.5 < total monthly weight 
            if total_monthly_weight <= 1
               monthly_averages{position_in_array,7} = 'Low Reliability data';
            elseif 1 < total_monthly_weight <= 2.5
               monthly_averages{position_in_array,7} = 'Moderate Reliability data';
            elseif 2.5 < total_monthly_weight
               monthly_averages{position_in_array,7} = 'High Reliability data';
            end    

 

        end

            
    elseif year_loop ~= first_year && year_loop ~= last_year
        for month_loop = 1:12
            
                   %First lets create a number string with the first and last day
            %of this month
            
            first_day_code = datenum(year_loop,month_loop,01);
            if month_loop ~= 12
            last_day_code = datenum(year_loop,month_loop+1,01)-1;
            elseif month_loop == 12
            last_day_code = datenum(year_loop+1,01,01)-1;    
            end
            
            %Now let's find which velocity maps are relevant to this month
            
            inner_parameter = 1;
            
            %Let's create a temporary array to store this and the 
            %velocities in. And a second for the flow direction.
                
            current_month_v = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            current_month_fd = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            
            for inner_loop = 1:size(first_date,1)
                %This long formula is determining if the interval is in
                %range
                if ((first_day_code <= first_date(inner_loop,1) && first_date(inner_loop,1) <= last_day_code))...
                        | ((last_day_code >= last_date(inner_loop,1) && last_date(inner_loop,1)>= first_day_code))...
                        | ((first_date(inner_loop,1) <= first_day_code  && last_date(inner_loop,1) >= last_day_code))                           
                
                %Create weight parameter for this particular velocity map,
                %this will be equal to 1 if it is entirely within the
                %month, or equal to 'percentage of velocity map averaging
                %time period within this month' if not. For instance if the
                %velocity is averaged over 2 months from 1 March to 30
                %April, its weight will be 0.5 for March and April.
                
                if first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1)<= last_day_code
                    
                    %If both true, velocity map is entirely within this
                    %month.
                    weight = 1;
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) <= last_day_code
                    
                    %If it starts prior to the month relevant but finishes 
                    %prior to end of it.
                    weight = (last_date(inner_loop,1)-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                    
                elseif first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it ends after the month relevant but begins within
                    %it.
                    weight = (last_day_code-first_date(inner_loop,1))/(last_date(inner_loop,1)-first_date(inner_loop,1));                    
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it both begins before month in question and ends
                    %after it.
                    weight = (last_day_code-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                end
                
%Add weighting parameter to the first column
                
                current_month_v(inner_parameter, 1) = weight;
                
                current_month_fd(inner_parameter, 1) = weight;


                %Add velocities to the remainder of the row
                
                %Make NANs 0
                
                %velocity
                
                temporary_row_v = images_stack{1,2}(inner_loop,:);
                
                temporary_row_v(isnan(temporary_row_v))=0;
                             
                temporary_row_v(isnan(mask_lin)) = NaN;
                
                current_month_v(inner_parameter, 2:end) = temporary_row_v;
                
                
                %flow direction
                
                
                temporary_row_fd = images_stack{2,2}(inner_loop,:);
                
                temporary_row_fd(isnan(temporary_row_fd))=0;
                             
                temporary_row_fd(isnan(mask_lin)) = NaN;
                
                current_month_fd(inner_parameter, 2:end) = temporary_row_fd;
                           
                inner_parameter = inner_parameter + 1;
                end
                  
            end
            
            %Calculate total weight for this month
            total_monthly_weight = sum(current_month_v(:, 1));
            
            %Decompose into x and y components
            [u,v] = Vtoxy(current_month_v(:,2:end),current_month_fd(:,2:end));
            
             %Calculate a weighted mean of u
            weighted_monthly_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                weighted_monthly_u = weighted_monthly_u + u(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
             %Calculate a weighted mean of v
            weighted_monthly_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                weighted_monthly_v = weighted_monthly_v + v(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
            %Calculate unweighted median of u
            median_monthly_u = nanmedian(u,1);
            
            %Calculate unweighted median of v
            median_monthly_v = nanmedian(v,1);
            
            %Calculate local weighting to account for NaN values
            local_weight_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                portion = u(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_u = local_weight_u + portion;
            end
            
             local_weight_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                portion = v(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_v = local_weight_v + portion;
            end
            
            %Divide by weight. Wrap in if loop to avoid error if all NaN.
            if ~isnan(nanmean(local_weight_u,'all'))
                
                weighted_monthly_u = weighted_monthly_u./local_weight_u;
                
            end
            
            if ~isnan(nanmean(local_weight_v,'all'))
                
                weighted_monthly_v = weighted_monthly_v./local_weight_v;
                
            end
            
            %Infill isolated NaNs and do some slight smoothing
            weighted_monthly_u = nanfill(weighted_monthly_u, 4,3);
            weighted_monthly_v = nanfill(weighted_monthly_v, 4,3);
            
            median_monthly_u = nanfill(median_monthly_u, 4,3);
            median_monthly_v = nanfill(median_monthly_v, 4,3);
            
            %We now have a linear matrix with the weighted velocities, we
            %simply need to make it the right shape.
            weighted_monthly_u = (reshape(weighted_monthly_u,inputs.sizevel));
            weighted_monthly_v = (reshape(weighted_monthly_v,inputs.sizevel));
            
            median_monthly_u = (reshape(median_monthly_u,inputs.sizevel));
            median_monthly_v = (reshape(median_monthly_v,inputs.sizevel));
            
            %Convert to weighted velocity and flow direction stats
            [weighted_monthly_velocity,weighted_monthly_fd] = xytoV_basic(weighted_monthly_u,weighted_monthly_v);
            
            %Convert to median velocity and flow direction stats
            [median_monthly_velocity,median_monthly_fd] = xytoV_basic(median_monthly_u,median_monthly_v);

            %Finally we need to load the data into the outputs array. First
            %we determine the position we are at in this array:
            
            position_in_array = 12*(year_loop-first_year) + month_loop-first_month + 1;
            
            %Then at last we load the data into this array!
            
            %First column is the year
            monthly_averages{position_in_array,1} = year_loop;
            
            %Second column is the month
            monthly_averages{position_in_array,2} = month_loop;
            
            %Third column is the mean weighted velocity
            monthly_averages{position_in_array,3} = weighted_monthly_velocity;
            
            %Fourth column is the mean weighted flow direction
            monthly_averages{position_in_array,4} = weighted_monthly_fd;
            
            %Fifth column is the median velocity
            monthly_averages{position_in_array,5} = median_monthly_velocity;
            
            %Sixth column is the median flow direction
            monthly_averages{position_in_array,6} = median_monthly_fd;
            
            %Seventh column is the quality of data for this month, as
            %determined from the total monthly weight. This uses the
            %following formula:
            %Low Reliability data : total monthly weight <= 1
            %Moderate Reliability data : 1 < total monthly weight <= 2.5
            %High Reliability data : 2.5 < total monthly weight 
            if total_monthly_weight <= 1
               monthly_averages{position_in_array,7} = 'Low Reliability data';
            elseif 1 < total_monthly_weight <= 2.5
               monthly_averages{position_in_array,7} = 'Moderate Reliability data';
            elseif 2.5 < total_monthly_weight
               monthly_averages{position_in_array,7} = 'High Reliability data';
            end     
            
        end
    elseif year_loop ~= first_year && year_loop == last_year
        for month_loop = 1:last_month
            
                 %First lets create a number string with the first and last day
            %of this month
            
            first_day_code = datenum(year_loop,month_loop,01);
            if month_loop ~= 12
            last_day_code = datenum(year_loop,month_loop+1,01)-1;
            elseif month_loop == 12
            last_day_code = datenum(year_loop+1,01,01)-1;    
            end
            
            %Now let's find which velocity maps are relevant to this month
            
            inner_parameter = 1;
            
            %Let's create a temporary array to store this and the 
            %velocities in. And a second for the flow direction.
                
            current_month_v = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            current_month_fd = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            for inner_loop = 1:size(first_date,1)
                %This long formula is determining if the interval is in
                %range
                if ((first_day_code <= first_date(inner_loop,1) && first_date(inner_loop,1) <= last_day_code))...
                        | ((last_day_code >= last_date(inner_loop,1) && last_date(inner_loop,1)>= first_day_code))...
                        | ((first_date(inner_loop,1) <= first_day_code  && last_date(inner_loop,1) >= last_day_code))                      
                
                %Create weight parameter for this particular velocity map,
                %this will be equal to 1 if it is entirely within the
                %month, or equal to 'percentage of velocity map averaging
                %time period within this month' if not. For instance if the
                %velocity is averaged over 2 months from 1 March to 30
                %April, its weight will be 0.5 for March and April.
                
                if first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1)<= last_day_code
                    
                    %If both true, velocity map is entirely within this
                    %month.
                    weight = 1;
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) <= last_day_code
                    
                    %If it starts prior to the month relevant but finishes 
                    %prior to end of it.
                    weight = (last_date(inner_loop,1)-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                    
                elseif first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it ends after the month relevant but begins within
                    %it.
                    weight = (last_day_code-first_date(inner_loop,1))/(last_date(inner_loop,1)-first_date(inner_loop,1));                    
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it both begins before month in question and ends
                    %after it.
                    weight = (last_day_code-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                end
                
                
               %Add weighting parameter to the first column
                
                current_month_v(inner_parameter, 1) = weight;
                
                current_month_fd(inner_parameter, 1) = weight;


                %Add velocities to the remainder of the row
                
                %Make NANs 0
                
                %velocity
                
                temporary_row_v = images_stack{1,2}(inner_loop,:);
                
                temporary_row_v(isnan(temporary_row_v))=0;
                             
                temporary_row_v(isnan(mask_lin)) = NaN;
                
                current_month_v(inner_parameter, 2:end) = temporary_row_v;
                
                
                %flow direction
                
                
                temporary_row_fd = images_stack{2,2}(inner_loop,:);
                
                temporary_row_fd(isnan(temporary_row_fd))=0;
                             
                temporary_row_fd(isnan(mask_lin)) = NaN;
                
                current_month_fd(inner_parameter, 2:end) = temporary_row_fd;
                           
                inner_parameter = inner_parameter + 1;
                end
                  
            end
            
            %Calculate total weight for this month
            total_monthly_weight = sum(current_month_v(:, 1));
            
            %Decompose into x and y components
            [u,v] = Vtoxy(current_month_v(:,2:end),current_month_fd(:,2:end));
            
             %Calculate a weighted mean of u
            weighted_monthly_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                weighted_monthly_u = weighted_monthly_u + u(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
             %Calculate a weighted mean of v
            weighted_monthly_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                weighted_monthly_v = weighted_monthly_v + v(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
            %Calculate unweighted median of u
            median_monthly_u = nanmedian(u,1);
            
            %Calculate unweighted median of v
            median_monthly_v = nanmedian(v,1);
            
            %Calculate local weighting to account for NaN values
            local_weight_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                portion = u(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_u = local_weight_u + portion;
            end
            
             local_weight_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                portion = v(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_v = local_weight_v + portion;
            end
            
            %Divide by weight. Wrap in if loop to avoid error if all NaN.
            if ~isnan(nanmean(local_weight_u,'all'))
                
                weighted_monthly_u = weighted_monthly_u./local_weight_u;
                
            end
            
            if ~isnan(nanmean(local_weight_v,'all'))
                
                weighted_monthly_v = weighted_monthly_v./local_weight_v;
                
            end
            
            %Infill isolated NaNs and do some slight smoothing
            weighted_monthly_u = nanfill(weighted_monthly_u, 4,3);
            weighted_monthly_v = nanfill(weighted_monthly_v, 4,3);
            
            median_monthly_u = nanfill(median_monthly_u, 4,3);
            median_monthly_v = nanfill(median_monthly_v, 4,3);
            
            %We now have a linear matrix with the weighted velocities, we
            %simply need to make it the right shape.
            weighted_monthly_u = (reshape(weighted_monthly_u,inputs.sizevel));
            weighted_monthly_v = (reshape(weighted_monthly_v,inputs.sizevel));
            
            median_monthly_u = (reshape(median_monthly_u,inputs.sizevel));
            median_monthly_v = (reshape(median_monthly_v,inputs.sizevel));
            
            %Convert to weighted velocity and flow direction stats
            [weighted_monthly_velocity,weighted_monthly_fd] = xytoV_basic(weighted_monthly_u,weighted_monthly_v);
            
            %Convert to median velocity and flow direction stats
            [median_monthly_velocity,median_monthly_fd] = xytoV_basic(median_monthly_u,median_monthly_v);

            %Finally we need to load the data into the outputs array. First
            %we determine the position we are at in this array:
            
            position_in_array = 12*(year_loop-first_year) + month_loop-first_month + 1;
            
            %Then at last we load the data into this array!
            
            %First column is the year
            monthly_averages{position_in_array,1} = year_loop;
            
            %Second column is the month
            monthly_averages{position_in_array,2} = month_loop;
            
            %Third column is the mean weighted velocity
            monthly_averages{position_in_array,3} = weighted_monthly_velocity;
            
            %Fourth column is the mean weighted flow direction
            monthly_averages{position_in_array,4} = weighted_monthly_fd;
            
            %Fifth column is the median velocity
            monthly_averages{position_in_array,5} = median_monthly_velocity;
            
            %Sixth column is the median flow direction
            monthly_averages{position_in_array,6} = median_monthly_fd;
            
            %Seventh column is the quality of data for this month, as
            %determined from the total monthly weight. This uses the
            %following formula:
            %Low Reliability data : total monthly weight <= 1
            %Moderate Reliability data : 1 < total monthly weight <= 2.5
            %High Reliability data : 2.5 < total monthly weight 
            if total_monthly_weight <= 1
               monthly_averages{position_in_array,7} = 'Low Reliability data';
            elseif 1 < total_monthly_weight <= 2.5
               monthly_averages{position_in_array,7} = 'Moderate Reliability data';
            elseif 2.5 < total_monthly_weight
               monthly_averages{position_in_array,7} = 'High Reliability data';
            end      
            
        end
    elseif year_loop == first_year && year_loop == last_year
        for month_loop = first_month:last_month
            
                 %First lets create a number string with the first and last day
            %of this month
            
            first_day_code = datenum(year_loop,month_loop,01);
            if month_loop ~= 12
            last_day_code = datenum(year_loop,month_loop+1,01)-1;
            elseif month_loop == 12
            last_day_code = datenum(year_loop+1,01,01)-1;    
            end
            
            %Now let's find which velocity maps are relevant to this month
            
            inner_parameter = 1;
            
            %Let's create a temporary array to store this and the 
            %velocities in. And a second for the flow direction.
                
            current_month_v = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            current_month_fd = NaN(1,inputs.sizevel(1)*inputs.sizevel(2) + 1);
            
            
            for inner_loop = 1:size(first_date,1)
                %This long formula is determining if the interval is in
                %range
                if ((first_day_code <= first_date(inner_loop,1) && first_date(inner_loop,1) <= last_day_code))...
                        | ((last_day_code >= last_date(inner_loop,1) && last_date(inner_loop,1)>= first_day_code))...
                        | ((first_date(inner_loop,1) <= first_day_code  && last_date(inner_loop,1) >= last_day_code))                       
                
                %Create weight parameter for this particular velocity map,
                %this will be equal to 1 if it is entirely within the
                %month, or equal to 'percentage of velocity map averaging
                %time period within this month' if not. For instance if the
                %velocity is averaged over 2 months from 1 March to 30
                %April, its weight will be 0.5 for March and April.
                
                if first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1)<= last_day_code
                    
                    %If both true, velocity map is entirely within this
                    %month.
                    weight = 1;
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) <= last_day_code
                    
                    %If it starts prior to the month relevant but finishes 
                    %prior to end of it.
                    weight = (last_date(inner_loop,1)-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                    
                elseif first_date(inner_loop,1) >= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it ends after the month relevant but begins within
                    %it.
                    weight = (last_day_code-first_date(inner_loop,1))/(last_date(inner_loop,1)-first_date(inner_loop,1));                    
                    
                elseif first_date(inner_loop,1) <= first_day_code && last_date(inner_loop,1) >= last_day_code
                    
                    %If it both begins before month in question and ends
                    %after it.
                    weight = (last_day_code-first_day_code)/(last_date(inner_loop,1)-first_date(inner_loop,1));
                end
                
                % We now have a weighting parameter. 
                
                %Add weighting parameter to the first column
                
                current_month_v(inner_parameter, 1) = weight;
                
                current_month_fd(inner_parameter, 1) = weight;


                %Add velocities to the remainder of the row
                
                %Make NANs 0
                
                %velocity
                
                temporary_row_v = images_stack{1,2}(inner_loop,:);
                
                temporary_row_v(isnan(temporary_row_v))=0;
                             
                temporary_row_v(isnan(mask_lin)) = NaN;
                
                current_month_v(inner_parameter, 2:end) = temporary_row_v;
                
                
                %flow direction
                
                
                temporary_row_fd = images_stack{2,2}(inner_loop,:);
                
                temporary_row_fd(isnan(temporary_row_fd))=0;
                             
                temporary_row_fd(isnan(mask_lin)) = NaN;
                
                current_month_fd(inner_parameter, 2:end) = temporary_row_fd;
                           
                inner_parameter = inner_parameter + 1;
                end
                  
            end
            
            %Calculate total weight for this month
            total_monthly_weight = sum(current_month_v(:, 1));
            
            %Decompose into x and y components
            [u,v] = Vtoxy(current_month_v(:,2:end),current_month_fd(:,2:end));
            
             %Calculate a weighted mean of u
            weighted_monthly_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                weighted_monthly_u = weighted_monthly_u + u(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
             %Calculate a weighted mean of v
            weighted_monthly_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                weighted_monthly_v = weighted_monthly_v + v(weighting_loop,1:end).*current_month_v(weighting_loop,1);
            end
            
            %Calculate unweighted median of u
            median_monthly_u = nanmedian(u,1);
            
            %Calculate unweighted median of v
            median_monthly_v = nanmedian(v,1);
            
            %Calculate local weighting to account for NaN values
            local_weight_u = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(u,1)
                portion = u(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_u = local_weight_u + portion;
            end
            
             local_weight_v = zeros(1,inputs.sizevel(1)*inputs.sizevel(2));
            for weighting_loop = 1:size(v,1)
                portion = v(weighting_loop,1:end);
                portion(isnan(portion)) = 0;
                portion(portion~=0)=current_month_v(weighting_loop,1);
                local_weight_v = local_weight_v + portion;
            end
            
            %Divide by weight. Wrap in if loop to avoid error if all NaN.
            if ~isnan(nanmean(local_weight_u,'all'))
                
                weighted_monthly_u = weighted_monthly_u./local_weight_u;
                
            end
            
            if ~isnan(nanmean(local_weight_v,'all'))
                
                weighted_monthly_v = weighted_monthly_v./local_weight_v;
                
            end
            
            %Infill isolated NaNs and do some slight smoothing
            weighted_monthly_u = nanfill(weighted_monthly_u, 4,3);
            weighted_monthly_v = nanfill(weighted_monthly_v, 4,3);
            
            median_monthly_u = nanfill(median_monthly_u, 4,3);
            median_monthly_v = nanfill(median_monthly_v, 4,3);
            
            %We now have a linear matrix with the weighted velocities, we
            %simply need to make it the right shape.
            weighted_monthly_u = (reshape(weighted_monthly_u,inputs.sizevel));
            weighted_monthly_v = (reshape(weighted_monthly_v,inputs.sizevel));
            
            median_monthly_u = (reshape(median_monthly_u,inputs.sizevel));
            median_monthly_v = (reshape(median_monthly_v,inputs.sizevel));
            
            %Convert to weighted velocity and flow direction stats
            [weighted_monthly_velocity,weighted_monthly_fd] = xytoV_basic(weighted_monthly_u,weighted_monthly_v);
            
            %Convert to median velocity and flow direction stats
            [median_monthly_velocity,median_monthly_fd] = xytoV_basic(median_monthly_u,median_monthly_v);

            %Finally we need to load the data into the outputs array. First
            %we determine the position we are at in this array:
            
            position_in_array = 12*(year_loop-first_year) + month_loop-first_month + 1;
            
            %Then at last we load the data into this array!
            
            %First column is the year
            monthly_averages{position_in_array,1} = year_loop;
            
            %Second column is the month
            monthly_averages{position_in_array,2} = month_loop;
            
            %Third column is the mean weighted velocity
            monthly_averages{position_in_array,3} = weighted_monthly_velocity;
            
            %Fourth column is the mean weighted flow direction
            monthly_averages{position_in_array,4} = weighted_monthly_fd;
            
            %Fifth column is the median velocity
            monthly_averages{position_in_array,5} = median_monthly_velocity;
            
            %Sixth column is the median flow direction
            monthly_averages{position_in_array,6} = median_monthly_fd;
            
            %Seventh column is the quality of data for this month, as
            %determined from the total monthly weight. This uses the
            %following formula:
            %Low Reliability data : total monthly weight <= 1
            %Moderate Reliability data : 1 < total monthly weight <= 2.5
            %High Reliability data : 2.5 < total monthly weight 
            if total_monthly_weight <= 1
               monthly_averages{position_in_array,7} = 'Low Reliability data';
            elseif 1 < total_monthly_weight <= 2.5
               monthly_averages{position_in_array,7} = 'Moderate Reliability data';
            elseif 2.5 < total_monthly_weight
               monthly_averages{position_in_array,7} = 'High Reliability data';
            end       
            
        end
    end
end





if inputs.nummonthiter > 0


% The first pass is now completed. We will now iterate for each image not
% fully located within a single month between 1) splitting it up into the
% constituant months by subtracting the averages calculated above and 2)
% recalculating the averages. This will be repeated a certain number of
% times until convergence is reached.


%%%%% Create matrix of percentage of each image within a given month.


%set the context
y_numel = size(monthly_averages,1)+1;

x_numel = size(images_stack{1,2},1)+2;

month_percent = num2cell(NaN(y_numel,x_numel));

for i = 2:size(month_percent,1)
month_percent{i,1} = monthly_averages{i-1,1};
month_percent{i,2} = monthly_averages{i-1,2};
end

for i = 3:size(month_percent,2)
month_percent{1,i} = i-2;
end
%

%Calculate the percentages

%Firstly work out the length of averaging interval for each matrix.

meta_dum = 0;

array_pos = 0;

emptycount_inner = 0;

emptycount_outer = 0;

number_in_range = 0;

number_with_values = (size(images,2)-6)/2;

for time_loop = 1:number_with_values
    dum1 = 6+time_loop*2;
 for inner_loop = 2:inputs.numimages-time_loop

    if ~isempty(images{inner_loop,dum1})
        
    number_in_range = number_in_range + 1;

    end
    
 end
end; 

full_time = NaN(1,size(images_stack{1,2},1));

  
for time_loop = 1:number_with_values
    dum1 = time_loop + 6 + array_pos;
    dum2 = time_loop + 7 + array_pos;
 for inner_loop = 2:inputs.numimages-time_loop

    if ~isempty(images{inner_loop,dum1})
        
    %calculate time interval
    
    time_gap = (images{inner_loop+time_loop,5}-images{inner_loop,5});
    
%     % Here calculates a median date for the interval that we will use
%     
%     date_current = round(images{inner_loop+time_loop,4}-(time_gap/2));
    
    full_time(1,inner_loop+meta_dum-1-emptycount_inner-emptycount_outer)= time_gap;
    full_time(2,inner_loop+meta_dum-1-emptycount_inner-emptycount_outer)= images{inner_loop,4};
    full_time(3,inner_loop+meta_dum-1-emptycount_inner-emptycount_outer)= images{inner_loop+time_loop,4};

    else
        emptycount_inner = emptycount_inner + 1;
    end
    
 end
emptycount_outer = emptycount_outer + emptycount_inner;
emptycount_inner = 0;
meta_dum = meta_dum + inputs.numimages-time_loop-1;
array_pos = array_pos + 1;
end


% For each velocity matrix, calculate which months it is located in, and
% fraction in each month

for velocity_matrix_loop = 1:size(images_stack{1,2},1)
    
    %work out percentage in each month
    
    if year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))...
            && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))
        % IF the matrix is ENTIRELY within one month.
        
        local_year = year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month = month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array = 12*(local_year-first_year) + local_month-first_month + 1;
        
        month_percent{position_in_array+1,velocity_matrix_loop+2} = 1;
        
    elseif (year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))...
            && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))+1== month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')))||...
           (year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))+1== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')) ...
           && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))-11 == month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')))
        %IF the matrix is entirely within TWO months. The OR is to account
        %for if the start and end are in two different years.
        
        local_year_first = year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_first = month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_first = 12*(local_year_first-first_year) + local_month_first-first_month + 1;
        
        local_year_last = year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_last = month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_last = 12*(local_year_last-first_year) + local_month_last-first_month + 1;
        
        start_last_month = datenum(local_year_last,local_month_last,01);
        
        percentage_last_month = (full_time(3,velocity_matrix_loop)-start_last_month+0.5)/full_time(1,velocity_matrix_loop);
        
        month_percent{position_in_array_first+1,velocity_matrix_loop+2} = 1-percentage_last_month;
        
        month_percent{position_in_array_last+1,velocity_matrix_loop+2} = percentage_last_month;
        
    else
        %If spans more than two months
        
        local_year_first = year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_first = month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_first = 12*(local_year_first-first_year) + local_month_first-first_month + 1;
        
        local_year_last = year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_last = month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_last = 12*(local_year_last-first_year) + local_month_last-first_month + 1;
        
        if local_month_first~=12
        end_first_month = datenum(local_year_first,local_month_first+1,01)-1;
        else
        end_first_month = datenum(local_year_first+1,1,01)-1;
        end
        
        start_last_month = datenum(local_year_last,local_month_last,01);
        
        percentage_first_month =(end_first_month - full_time(2,velocity_matrix_loop)+0.5)/full_time(1,velocity_matrix_loop);
        
        percentage_last_month = (full_time(3,velocity_matrix_loop)-start_last_month+0.5)/full_time(1,velocity_matrix_loop);
        
        month_percent{position_in_array_first+1,velocity_matrix_loop+2} = percentage_first_month;
        
        month_percent{position_in_array_last+1,velocity_matrix_loop+2} = percentage_last_month;
        
        for percentage_loop = position_in_array_first+1:position_in_array_last-1
            month_percent{percentage_loop+1,velocity_matrix_loop+2} = (1-percentage_first_month-percentage_last_month)/(position_in_array_last-position_in_array_first-1);
        end

    
    end %if loops end
    
    
end %end velocity matrix loop



global_standard_deviation_lin = reshape(images_stack{5,2},[1,inputs.sizevel(1)*inputs.sizevel(2)]);

%%%%% Outside iterative loop

for iterations = 1:inputs.nummonthiter
    
    %Create temporary matrix to read values into
    
    monthly_averages_temp = num2cell(NaN(size(monthly_averages)));
    
    %inner loop to loop between different months
    for month_loop  = 1:size(monthly_averages,1)
        
        %Create shell matrix to store data for this month
        
        %How many values overlap with this month?
        value_counter = 0;
        for i = 1:size(images_stack{1,2},1)
            if ~isnan(month_percent{month_loop+1,i+2})
            value_counter = value_counter+1;    
            end
        end
        
        one_month_v_temp = NaN(value_counter,inputs.sizevel(1)*inputs.sizevel(2));
        one_month_fd_temp = NaN(value_counter,inputs.sizevel(1)*inputs.sizevel(2));
        
        numbering_system_temp = 1;
        
        %Second tier of loop to loop through velocity matrices
        for velocity_matrix_loop = 1:size(images_stack{1,2},1)
            
            
            
            if ~isnan(month_percent{month_loop+1,velocity_matrix_loop+2})
            
                
                
                
             if year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))...
            && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))
        % IF the matrix is ENTIRELY within one month.
        
%         mask_lin = reshape(mask,[1,inputs.sizevel(1)*inputs.sizevel(2)]);

        one_month_v_temp(numbering_system_temp,:) = images_stack{1,2}(velocity_matrix_loop,:);
        one_month_fd_temp(numbering_system_temp,:) = images_stack{2,2}(velocity_matrix_loop,:);

%     numbering_system_temp = numbering_system_temp+1;
        
    elseif (year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'))...
            && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))+1== month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')))||...
           (year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))+1== year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')) ...
           && month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'))-11 == month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum')))
        %IF the matrix is entirely within TWO months. The OR is to account
        %for if the start and end are in two different years.
        
        local_year_first = year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_first = month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_first = 12*(local_year_first-first_year) + local_month_first-first_month + 1;
        
        local_year_last = year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_last = month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_last = position_in_array_first + 1;
        
        start_last_month = datenum(local_year_last,local_month_last,01);
        
        percentage_last_month = (full_time(3,velocity_matrix_loop)-start_last_month+0.5)/full_time(1,velocity_matrix_loop);
        
        month_percent{position_in_array_first+1,velocity_matrix_loop+2} = 1-percentage_last_month;
        
        month_percent{position_in_array_last+1,velocity_matrix_loop+2} = percentage_last_month;
        
        
        
        
        
        if month_loop == position_in_array_first
            
        temp_v_matrix = images_stack{1,2}(velocity_matrix_loop,:);
        
        temp_fd_matrix = images_stack{2,2}(velocity_matrix_loop,:);
        
        extra_v_matrix = reshape(monthly_averages{position_in_array_last,3},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
        
        extra_fd_matrix = reshape(monthly_averages{position_in_array_last,4},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
        
        %We have this month * this weight + other month * other weight =
        %total
        
        %So this month = (total - (other month * other weight)) / this weight
        
        %replace NaNs in other month
        
        for i = 1:inputs.sizevel(1)*inputs.sizevel(2)
            if isnan(extra_v_matrix(:,i)) && ~isnan(temp_v_matrix(:,i))
                extra_v_matrix(:,i) = temp_v_matrix(:,i);
                extra_fd_matrix(:,i) = temp_fd_matrix(:,i);
            elseif isnan(temp_v_matrix(:,i)) && ~isnan(extra_v_matrix(:,i))
                extra_v_matrix(:,i) = NaN;
                extra_fd_matrix(:,i) = NaN;
            end
        end
        
        one_month_v_temp(numbering_system_temp,:) = (temp_v_matrix - (extra_v_matrix * percentage_last_month))/(1-percentage_last_month);
        
        for i = 1:inputs.sizevel(1)*inputs.sizevel(2)
        if abs(extra_fd_matrix(:,i)-temp_fd_matrix(:,i))>270 || abs(temp_fd_matrix(:,i)-extra_fd_matrix(:,i))>270
            
            if extra_fd_matrix(:,i) > temp_fd_matrix(:,i)
                temp_fd_matrix(:,i) = temp_fd_matrix(:,i)+360;
            else
                extra_fd_matrix(:,i) = extra_fd_matrix(:,i) + 360;
            end
            
        one_month_fd_temp(numbering_system_temp,i) = (temp_fd_matrix(:,i) - (extra_fd_matrix(:,i) * percentage_last_month))/(1-percentage_last_month);
        if one_month_fd_temp(numbering_system_temp,i) > 360
           one_month_fd_temp(numbering_system_temp,i) = one_month_fd_temp(numbering_system_temp,i) - 360 ;
        end
        
        else
        one_month_fd_temp(numbering_system_temp,i) = (temp_fd_matrix(:,i) - (extra_fd_matrix(:,i) * percentage_last_month))/(1-percentage_last_month);
        end
        
        end
        
        elseif month_loop == position_in_array_last
        
        temp_v_matrix = images_stack{1,2}(velocity_matrix_loop,:);
        
        temp_fd_matrix = images_stack{2,2}(velocity_matrix_loop,:);
        
        extra_v_matrix = reshape(monthly_averages{position_in_array_first,3},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
        
        extra_fd_matrix = reshape(monthly_averages{position_in_array_first,4},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
        
        %We have this month * this weight + other month * other weight =
        %total
        
        %So this month = (total - (other month * other weight)) / this weight
        
        %replace NaNs in other month
        
        for i = 1:inputs.sizevel(1)*inputs.sizevel(2)
            if isnan(extra_v_matrix(:,i)) && ~isnan(temp_v_matrix(:,i))
                extra_v_matrix(:,i) = temp_v_matrix(:,i);
                extra_fd_matrix(:,i) = temp_fd_matrix(:,i);
            elseif isnan(temp_v_matrix(:,i)) && ~isnan(extra_v_matrix(:,i))
                extra_v_matrix(:,i) = NaN;
                extra_fd_matrix(:,i) = NaN;
            end
        end
        
        one_month_v_temp(numbering_system_temp,:) = (temp_v_matrix - (extra_v_matrix * (1-percentage_last_month)))/(percentage_last_month);
        
        for i = 1:inputs.sizevel(1)*inputs.sizevel(2)
        if abs(extra_fd_matrix(:,i)-temp_fd_matrix(:,i))>270 || abs(temp_fd_matrix(:,i)-extra_fd_matrix(:,i))>270
            
            if extra_fd_matrix(:,i) > temp_fd_matrix(:,i)
                temp_fd_matrix(:,i) = temp_fd_matrix(:,i)+360;
            else
                extra_fd_matrix(:,i) = extra_fd_matrix(:,i) + 360;
            end
            
        one_month_fd_temp(numbering_system_temp,i) = (temp_fd_matrix(:,i) - (extra_fd_matrix(:,i) * (1-percentage_last_month)))/(percentage_last_month);
        if one_month_fd_temp(numbering_system_temp,i) > 360
           one_month_fd_temp(numbering_system_temp,i) = one_month_fd_temp(numbering_system_temp,i) - 360 ;
        end
        
        else
        one_month_fd_temp(numbering_system_temp,i) = (temp_fd_matrix(:,i) - (extra_fd_matrix(:,i) * (1-percentage_last_month)))/(percentage_last_month);
        end
        
        end    
            
        end %end if month loop...
        
                %calculate mean of nearby months. std doesn't work with too few
        temp_mean(1,:) = temp_v_matrix; temp_mean(2,:) = extra_v_matrix;       
                
        mean_months = nanmean(temp_mean,1);
        
        
        
        %loop (I am sure there is a more computationally efficient method
        %here, revisit)
         for findoutlier = 1:inputs.sizevel(1)*inputs.sizevel(2)
             if ~isnan(one_month_v_temp(numbering_system_temp,findoutlier))
                 if one_month_v_temp(numbering_system_temp,findoutlier) < 0 ||...
                    one_month_v_temp(numbering_system_temp,findoutlier) < (mean_months(1,findoutlier) - 3 * global_standard_deviation_lin(1,findoutlier)) ||...
                    one_month_v_temp(numbering_system_temp,findoutlier) > (mean_months(1,findoutlier) + 3 * global_standard_deviation_lin(1,findoutlier))
                
                     one_month_v_temp(numbering_system_temp,findoutlier) = NaN;
                     one_month_fd_temp(numbering_system_temp,findoutlier) = NaN;
                     
                 end
                
             end
         end %end findoutlier loop
         
        one_month_v_temp(numbering_system_temp,:) = reshape(nanfill(reshape(nanmean(one_month_v_temp(numbering_system_temp,:),1)...
            ,inputs.sizevel),2,2),[1,inputs.sizevel(1)*inputs.sizevel(2)]); %fill some of the NaNs
        
%     numbering_system_temp = numbering_system_temp+1;    
        
    else
        %If spans more than two months
        
        local_year_first = year(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_first = month(datetime(full_time(2,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_first = 12*(local_year_first-first_year) + local_month_first-first_month + 1;
        
        local_year_last = year(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        local_month_last = month(datetime(full_time(3,velocity_matrix_loop),'ConvertFrom','datenum'));
        
        position_in_array_last = 12*(local_year_last-first_year) + local_month_last-first_month + 1;
        
        if local_month_first~=12
        end_first_month = datenum(local_year_first,local_month_first+1,01)-1;
        else
        end_first_month = datenum(local_year_first+1,1,01)-1;
        end
        
        start_last_month = datenum(local_year_last,local_month_last,01);
        
        percentage_first_month =(end_first_month - full_time(2,velocity_matrix_loop)+0.5)/full_time(1,velocity_matrix_loop);
        
        percentage_last_month = (full_time(3,velocity_matrix_loop)-start_last_month+0.5)/full_time(1,velocity_matrix_loop);
        
        month_percent{position_in_array_first+1,velocity_matrix_loop+2} = percentage_first_month;
        
        month_percent{position_in_array_last+1,velocity_matrix_loop+2} = percentage_last_month;
        
%         for percentage_loop = position_in_array_first+1:position_in_array_last-1
%             month_percent{percentage_loop+1,velocity_matrix_loop+2} = (1-percentage_first_month-percentage_last_month)/(position_in_array_last-position_in_array_first-1);
%         end



        %We have this month * this weight + other month * other weight + ... =
        %total
        
        %So this month = (total - (other month * other weight)-...) / this weight
        
        %replace NaNs in other month           
            
        temp_v_matrix = images_stack{1,2}(velocity_matrix_loop,:); %total
        
        temp_fd_matrix = images_stack{2,2}(velocity_matrix_loop,:); %total
        
        temp_v_matrix_partial = temp_v_matrix;
        
        temp_fd_matrix_partial = temp_fd_matrix;
        
        previous_iteration_averages_array_v = NaN((position_in_array_last-position_in_array_first)+1,inputs.sizevel(1)*inputs.sizevel(2));
        previous_iteration_averages_array_fd = NaN((position_in_array_last-position_in_array_first)+2,inputs.sizevel(1)*inputs.sizevel(2));
        
        for i = position_in_array_first:position_in_array_last
            if i ~= month_loop %not for current month
                previous_iteration_averages_array_v(i,:) = reshape(monthly_averages{i,3},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
                previous_iteration_averages_array_fd(i+1,:) = reshape(monthly_averages{i,4},[1,inputs.sizevel(1)*inputs.sizevel(2)]);
                
                
            for innerloop = 1:inputs.sizevel(1)*inputs.sizevel(2) %make NaNs same as temp matrix
              if isnan(previous_iteration_averages_array_v(i,innerloop)) && ~isnan(temp_v_matrix(1,innerloop))
                previous_iteration_averages_array_v(i,innerloop) = temp_v_matrix(1,innerloop);
                previous_iteration_averages_array_fd(i+1,innerloop) = temp_fd_matrix(1,innerloop);
               elseif isnan(temp_v_matrix(1,innerloop)) && ~isnan(previous_iteration_averages_array_v(i,innerloop))
                previous_iteration_averages_array_v(i,innerloop) = NaN;
                previous_iteration_averages_array_fd(i+1,innerloop) = NaN;
              end
            end
            
           
            temp_v_matrix_partial = temp_v_matrix_partial - (previous_iteration_averages_array_v(i,:)*month_percent{i+1,velocity_matrix_loop+2});
            %cant do quite this for fd, do it in new loop
            
            end
        end
        
        one_month_v_temp(numbering_system_temp,:) = temp_v_matrix_partial/month_percent{month_loop+1,velocity_matrix_loop+2};
              
        
        %Work it out for FLOW DIRECTION
        
        previous_iteration_averages_array_fd(1,:) = temp_fd_matrix_partial;
        
        for i = 1:inputs.sizevel(1)*inputs.sizevel(2)
        if (max(previous_iteration_averages_array_fd(:,i))- min(previous_iteration_averages_array_fd(:,i)))>270
        
        for inner_loop = 1:size(previous_iteration_averages_array_fd,1)
           if previous_iteration_averages_array_fd(inner_loop,i) < 90
              previous_iteration_averages_array_fd(inner_loop,i) =  previous_iteration_averages_array_fd(inner_loop,i) + 360;
           end
        end
        
        for inner_loop = 2:size(previous_iteration_averages_array_fd,1)
           
              previous_iteration_averages_array_fd(1,i) =  previous_iteration_averages_array_fd(1,i) -...
                  (previous_iteration_averages_array_fd(inner_loop,i)*month_percent{inner_loop,velocity_matrix_loop+2});
              
        end
        
        previous_iteration_averages_array_fd(1,i) = previous_iteration_averages_array_fd(1,i) / month_percent{month_loop+1,velocity_matrix_loop+2};
        
        if previous_iteration_averages_array_fd(1,i) > 360
           one_month_fd_temp(numbering_system_temp,i) = previous_iteration_averages_array_fd(1,i) - 360 ;    
        else
        one_month_fd_temp(numbering_system_temp,i) = previous_iteration_averages_array_fd(1,i);
        end
        
        end
        end

        % Find outliers
        
        %calculate mean of nearby months. std doesn't work with too few
        mean_months = nanmean(previous_iteration_averages_array_v,1);
        
        
        
        %loop (I am sure there is a more computationally efficient method
        %here, revisit)
         for findoutlier = 1:inputs.sizevel(1)*inputs.sizevel(2)
             if ~isnan(one_month_v_temp(numbering_system_temp,findoutlier))
                 if one_month_v_temp(numbering_system_temp,findoutlier) < 0 ||...
                    one_month_v_temp(numbering_system_temp,findoutlier) < (mean_months(1,findoutlier) - 3 * global_standard_deviation_lin(1,findoutlier)) ||...
                    one_month_v_temp(numbering_system_temp,findoutlier) > (mean_months(1,findoutlier) + 3 * global_standard_deviation_lin(1,findoutlier))
                
                     one_month_v_temp(numbering_system_temp,findoutlier) = NaN;
                     one_month_fd_temp(numbering_system_temp,findoutlier) = NaN;
                     
                 end
                
             end
         end %end findoutlier loop
         
        one_month_v_temp(numbering_system_temp,:) = reshape(nanfill(reshape(nanmean(one_month_v_temp(numbering_system_temp,:),1)...
            ,inputs.sizevel),2,2),[1,inputs.sizevel(1)*inputs.sizevel(2)]); %fill some of the NaNs
       
%        numbering_system_temp = numbering_system_temp+1; 
        
       end %if loops end    
    
    
        numbering_system_temp = numbering_system_temp+1;
    
        end %end of ~isnan if condition
        end %end of velocity matrix loop
        
       monthly_averages_temp{month_loop,3} = (reshape(nanmean(one_month_v_temp,1),inputs.sizevel)); %take mean and reshape to right size

       monthly_averages_temp{month_loop,4} = (reshape(nanmean(one_month_fd_temp,1),inputs.sizevel)); %take mean and reshape to right size
               
    end %end of month loop
    
    %replace old MONTHLY AVERAGES with new ones from this iteration[
    
    for i = 1:size(monthly_averages,1)
        monthly_averages{i,3} = monthly_averages_temp{i,3}; %replace velocities
        monthly_averages{i,4} = monthly_averages_temp{i,4}; %replace flow directions
    end
    
end % end of iterative loop


    for i = 1:size(monthly_averages,1) %Infill isolated NaNs and do some slight smoothing
        monthly_averages{i,3} = nanfill(monthly_averages{i,3}, 3,3);
        monthly_averages{i,4} = nanfill(monthly_averages{i,4}, 3,3);
    end


end














