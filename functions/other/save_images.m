function [images] = save_images (images, inputs, images_stack, monthly_averages)
%
%This function saves the outputs into one file, named "Results" according
%to user determined parameters.
%

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


%Skip if nothing is to be saved.
if strcmpi(inputs.savearrays, 'Yes') | strcmpi(inputs.savekeyvel, 'Yes') | strcmpi(inputs.savegeotiff, 'Yes')  
    
    %Check if Results folder exists yet
    filename = strcat(inputs.folder,'/Results')
    if ~exist(filename)
        mkdir(filename)
    end

    %Create main folder
    mkdir(strcat(filename,'/',inputs.name))

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SAVE MATLAB ARRAYS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmpi(inputs.savearrays, 'Yes')
        %Create subfolder for matlab arrays
        mkdir(strcat(filename,'/',inputs.name,'/Matlab data files'))
        %Save images, Inputs, Images_stack and Monthly_averages in this folder
        save(strcat(filename,'/',inputs.name,'/Matlab data files/','Run Input Parameters'),'inputs');
        save(strcat(filename,'/',inputs.name,'/Matlab data files/',...
            'Raw Images array'),'images','-v7.3'); %v7.3 allows large files to be saved when they otherwise would fail.
        save(strcat(filename,'/',inputs.name,'/Matlab data files/',...
            'Stacked and averaged data array'),'images_stack','-v7.3');%v7.3 allows large files to be saved when they otherwise would fail.
        save(strcat(filename,'/',inputs.name,'/Matlab data files/','Monthly averages data array'),'monthly_averages');
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %SAVE PNG IMAGES OF DATA%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if strcmpi(inputs.savekeyvel, 'Yes')
        mkdir(strcat(filename,'/',inputs.name,'/Data Figures (Images)'))
        %First save flow direction and velocity statistics
        mkdir(strcat(filename,'/',inputs.name,'/Data Figures (Images)','/Mean, Standard Deviation and other statistics'))
        %Load background image for all datasets
        if ~exist(strcat(inputs.folder,'/save_image.png')) && ~exist(strcat(inputs.folder,'/save_image.jpg'))
            disp('You need to save one of your images (ideally the best one) in the same folder as the others, under the name "save_image".') 
            disp('Please do this and run this function again. Do not worry, your data has not been lost :)')
        end

        if exist(fullfile(fullfile(inputs.folder,'/save_image.png')))  > 0  
            save_image = flipud(imread(fullfile(inputs.folder,'/save_image.png')));
        elseif exist(fullfile(fullfile(inputs.folder,'/save_image.jpg'))) >0
            save_image = flipud(imread(fullfile(inputs.folder,'/save_image.jpg')));
        end

        %First velocities (different labels)
        for images_stack_loop = 3:2:size(images_stack,1)-2
            %Saving hidden figure
            h = figure;set(h, 'Visible', 'off');
    
            if strcmpi(inputs.isgeotiff,'No')
                m_proj('lambert','lon',[inputs.minlon inputs.maxlon],'lat',[inputs.minlat inputs.maxlat]); 
                m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],save_image);
                brighten(.5);
                alpha(0.7)
                hold on
                m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],images_stack{images_stack_loop,2});
            else
                m_proj('lambert','lon',[min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
                'lat',[min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)]); 
                m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
                [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],save_image);
                brighten(.5);
                alpha(0.7)
                hold on
                m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
                [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],images_stack{images_stack_loop,2});    
            end
        m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
        title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
        colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
        hold off
        col = colorbar;
        ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')
        set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
        saveas(h,strcat(filename,'/',inputs.name,'/Data Figures (Images)',...
        '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs.imageformat));
        end

        %Percentage error
        for images_stack_loop = 13
            %Saving hidden figure
            h = figure;set(h, 'Visible', 'off');
            if strcmpi(inputs.isgeotiff,'No')
            m_proj('lambert','lon',[inputs.minlon inputs.maxlon],'lat',[inputs.minlat inputs.maxlat]); 
            m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],save_image);
            brighten(.5);
            alpha(0.7)
            hold on
            m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],images_stack{images_stack_loop,2});
        else
            m_proj('lambert','lon',[min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            'lat',[min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)]); 
            m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],save_image);
            brighten(.5);
            alpha(0.7)
            hold on
            m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],images_stack{images_stack_loop,2});    
        end
        m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
        title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
        colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
        hold off
        col = colorbar;
        ylabel(col, 'Percentage variation in velocity','FontSize',15,'FontName', 'Times New Roman')
        set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
        saveas(h,strcat(filename,'/',inputs.name,'/Data Figures (Images)',...
         '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs.imageformat));
    end

    %Then flow directions(different labels)
    for images_stack_loop = 4:2:size(images_stack,1)-1
        %Saving hidden figure
        h = figure;set(h, 'Visible', 'off');
        if strcmpi(inputs.isgeotiff,'No')
            m_proj('lambert','lon',[inputs.minlon inputs.maxlon],'lat',[inputs.minlat inputs.maxlat]); 
            m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],save_image);
            brighten(.5);
            alpha(0.7)
            hold on
            m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],images_stack{images_stack_loop,2});
    else
        m_proj('lambert','lon',[min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
        'lat',[min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)]); 
        m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
        [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],save_image);
        brighten(.5);
        alpha(0.7)
        hold on
        m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],images_stack{images_stack_loop,2});    
    end
    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Greens', 50));cbrewer('seq', 'Blues', 50);flipud(cbrewer('seq', 'Purples', 50));cbrewer('seq', 'Reds', 50)]);
    hold off
    col = colorbar;
    ylabel(col, 'Flow direction (degrees)','FontSize',15,'FontName', 'Times New Roman')
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs.name,'/Data Figures (Images)',...
    '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs.imageformat));
end

%Next save average monthly values
mkdir(strcat(filename,'/',inputs.name,'/Data Figures (Images)','/Average monthly values'))

% Velocity
for images_stack_loop = 1:size(monthly_averages,1)
    %Saving hidden figure
    h = figure;set(h, 'Visible', 'off');
    if strcmpi(inputs.isgeotiff,'No')
        m_proj('lambert','lon',[inputs.minlon inputs.maxlon],'lat',[inputs.minlat inputs.maxlat]); 
        m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],save_image);
        brighten(.5);
        alpha(0.7)
        hold on
        m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],monthly_averages{images_stack_loop,3});
    else
        m_proj('lambert','lon',[min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
        'lat',[min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)]); 
        m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],save_image);
        brighten(.5);
        alpha(0.7)
        hold on
        m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],monthly_averages{images_stack_loop,3});    
    end
    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    labeltextv = ['Average velocity for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
    ' ',num2str(monthly_averages{images_stack_loop,1})];
    title(labeltextv,'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off
    col = colorbar;
    ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs.name,'/Data Figures (Images)',...
    '/Average monthly values/',labeltextv,'_(',monthly_averages{images_stack_loop,5},')','.',inputs.imageformat));
end


% Flow directions

for images_stack_loop = 1:size(monthly_averages,1)
    %Saving hidden figure
    h = figure;set(h, 'Visible', 'off');
    if strcmpi(inputs.isgeotiff,'No')
        m_proj('lambert','lon',[inputs.minlon inputs.maxlon],'lat',[inputs.minlat inputs.maxlat]); 
        m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],save_image);
        brighten(.5);
        alpha(0.7)
        hold on
        m_image([inputs.minlon inputs.maxlon],[inputs.minlat inputs.maxlat],monthly_averages{images_stack_loop,4});
    else
        m_proj('lambert','lon',[min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
        'lat',[min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)]); 
         m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],save_image);
        brighten(.5);
        alpha(0.7)
        hold on
        m_image([min(inputs.geotifflocationdata.CornerCoords.Lon) max(inputs.geotifflocationdata.CornerCoords.Lon)],...
            [min(inputs.geotifflocationdata.CornerCoords.Lat) max(inputs.geotifflocationdata.CornerCoords.Lat)],monthly_averages{images_stack_loop,4});    
    end
    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    labeltextfd = ['Average flow direction for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
    ' ',num2str(monthly_averages{images_stack_loop,1})];
    title(labeltextfd,'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off
    col = colorbar;
    ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs.name,'/Data Figures (Images)',...
    '/Average monthly values/',labeltextfd,'_(',monthly_averages{images_stack_loop,5},')','.',inputs.imageformat));
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE GEOREFERENCED VELOCITY DATA%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmpi(inputs.savegeotiff, 'Yes')
    mkdir(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data'))

    %Create location data that will be used for georeferencing all arrays
    if strcmpi(inputs.isgeotiff,'No')
        location_data = georasterref('RasterSize',size(images_stack{3, 2}),'LatitudeLimits',...
            [inputs.minlat  ,inputs.maxlat  ],'LongitudeLimits',[inputs.minlon  ,inputs.maxlon  ]);
        
        %First save flow direction and velocity statistics
        mkdir(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data','/Mean, Standard Deviation and other statistics'))
        
        for images_stack_loop = 3:size(images_stack,1)
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.tif')...
            ,images_stack{images_stack_loop,2},location_data)
        end

        %Next save average monthly values
        mkdir(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data','/Average monthly values'))

        for images_stack_loop = 1:size(monthly_averages,1)
            labeltextv = ['Average velocity for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
            ' ',num2str(monthly_averages{images_stack_loop,1})];
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Average monthly values/',labeltextv,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
            monthly_averages{images_stack_loop,3},location_data)
        end

        for images_stack_loop = 1:size(monthly_averages,1)
            labeltextfd = ['Average flow direction for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
            ' ',num2str(monthly_averages{images_stack_loop,1})];
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Average monthly values/',labeltextfd,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
            monthly_averages{images_stack_loop,4},location_data)
        end
    else
        %First save flow direction and velocity statistics
        mkdir(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data','/Mean, Standard Deviation and other statistics'))

        % Edit the mappostings portion
        inputs.geotiffreference = maprefpostings(inputs.geotiffreference.XWorldLimits,...
        inputs.geotiffreference.YWorldLimits,...
        [size(images_stack{3,2},1),size(images_stack{3,2},2)],...
        'ColumnsStartFrom',inputs.geotiffreference.ColumnsStartFrom,...
        'RowsStartFrom',inputs.geotiffreference.RowsStartFrom);

        for images_stack_loop = 3:size(images_stack,1)
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.tif')...
            ,flipud(images_stack{images_stack_loop,2}),inputs.geotiffreference,'GeoKeyDirectoryTag',inputs.geotifflocationdata.GeoTIFFTags.GeoKeyDirectoryTag)
        end

        %Next save average monthly values
        mkdir(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data','/Average monthly values'))

        for images_stack_loop = 1:size(monthly_averages,1)
            labeltextv = ['Average velocity for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
            ' ',num2str(monthly_averages{images_stack_loop,1})];
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Average monthly values/',labeltextv,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
            flipud(monthly_averages{images_stack_loop,3}),inputs.geotiffreference,'GeoKeyDirectoryTag',inputs.geotifflocationdata.GeoTIFFTags.GeoKeyDirectoryTag)
        end

        for images_stack_loop = 1:size(monthly_averages,1)  
            labeltextfd = ['Average flow direction for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
            ' ',num2str(monthly_averages{images_stack_loop,1})];
            geotiffwrite(strcat(filename,'/',inputs.name,'/Georeferenced Velocity Data',...
            '/Average monthly values/',labeltextfd,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
            flipud(monthly_averages{images_stack_loop,4}),inputs.geotiffreference,'GeoKeyDirectoryTag',inputs.geotifflocationdata.GeoTIFFTags.GeoKeyDirectoryTag)
        end    

    end

end

else 
    disp('You chose not to save any files. You may edit the inputs file, rerun loadinpus.mat and then rerun save_images.mat if you have decided to save')
end
