function [images] = save_images (images, inputs, images_stack, monthly_averages)
%
%This function saves the outputs into one file, named "Results" according
%to user determined parameters.
%

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



if strcmpi(inputs{32,2}, 'Yes') | strcmpi(inputs{43,2}, 'Yes') | strcmpi(inputs{44,2}, 'Yes')

    
    
%Check if Results folder exists yet
filename = strcat(inputs{1,2},'/Results')
if ~exist(filename)
    mkdir(filename)
end

%Create main folder
mkdir(strcat(filename,'/',inputs{33,2}))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE MATLAB ARRAYS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(inputs{32,2}, 'Yes')
%Create subfolder for matlab arrays
mkdir(strcat(filename,'/',inputs{33,2},'/Matlab data files'))

%Save images, Inputs, Images_stack and Monthly_averages in this folder

save(strcat(filename,'/',inputs{33,2},'/Matlab data files/','Run Input Parameters'),'inputs');

save(strcat(filename,'/',inputs{33,2},'/Matlab data files/','Raw Images array'),'images','-v7.3'); %v7.3 allows large files to be saved when they otherwise would fail.

save(strcat(filename,'/',inputs{33,2},'/Matlab data files/','Stacked and averaged data array'),'images_stack','-v7.3');%v7.3 allows large files to be saved when they otherwise would fail.

save(strcat(filename,'/',inputs{33,2},'/Matlab data files/','Monthly averages data array'),'monthly_averages');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE PNG IMAGES OF DATA%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmpi(inputs{43,2}, 'Yes')
    
mkdir(strcat(filename,'/',inputs{33,2},'/Data Figures (Images)'))

%First save flow direction and velocity statistics
mkdir(strcat(filename,'/',inputs{33,2},'/Data Figures (Images)','/Mean, Standard Deviation and other statistics'))

%Load background image for all datasets
if ~exist(strcat(inputs{1,2},'/save_image.png')) && ~exist(strcat(inputs{1,2},'/save_image.jpg'))
    disp('You need to save one of your images (ideally the best one) in the same folder as the others, under the name "save_image".') 
    disp('Please do this and run this function again. Do not worry, your data has not been lost :)')
end


if exist(fullfile(fullfile(inputs{1,2},'/save_image.png')))  > 0  
    
save_image = flipud(imread(fullfile(inputs{1,2},'/save_image.png')));

elseif exist(fullfile(fullfile(inputs{1,2},'/save_image.jpg'))) >0
    
save_image = flipud(imread(fullfile(inputs{1,2},'/save_image.jpg')));

end


%First velocities (different labels)
for images_stack_loop = 3:2:size(images_stack,1)-2
    %Saving hidden figure
 h = figure;set(h, 'Visible', 'off');
    
    m_proj('lambert','lon',[inputs{16, 2} inputs{17, 2}],'lat',[inputs{14, 2} inputs{15, 2}]); 
        m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],save_image);
        brighten(.5);
        alpha(0.7)

    hold on
    m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],images_stack{images_stack_loop,2});

    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    
        title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off

col = colorbar;
ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')


set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs{33,2},'/Data Figures (Images)',...
    '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs{45,2}));
end

%Percentage error
for images_stack_loop = 13
    %Saving hidden figure
 h = figure;set(h, 'Visible', 'off');
    
    m_proj('lambert','lon',[inputs{16, 2} inputs{17, 2}],'lat',[inputs{14, 2} inputs{15, 2}]); 
        m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],save_image);
        brighten(.5);
        alpha(0.7)

    hold on
    m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],images_stack{images_stack_loop,2});

    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    
        title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off

col = colorbar;
ylabel(col, 'Percentage variation in velocity','FontSize',15,'FontName', 'Times New Roman')


set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs{33,2},'/Data Figures (Images)',...
    '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs{45,2}));
end

%Then flow directions(different labels)
for images_stack_loop = 4:2:size(images_stack,1)-1
    %Saving hidden figure
 h = figure;set(h, 'Visible', 'off');
    
    m_proj('lambert','lon',[inputs{16, 2} inputs{17, 2}],'lat',[inputs{14, 2} inputs{15, 2}]); 
        m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],save_image);
        brighten(.5);
        alpha(0.7)

    hold on
    m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],images_stack{images_stack_loop,2});

    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    
        title(images_stack{images_stack_loop,1},'FontSize',25,'FontName', 'Times New Roman');
    colormap([ flipud(cbrewer('seq', 'Greens', 50));cbrewer('seq', 'Blues', 50);flipud(cbrewer('seq', 'Purples', 50));cbrewer('seq', 'Reds', 50)]);
    hold off

col = colorbar;
ylabel(col, 'Flow direction (degrees)','FontSize',15,'FontName', 'Times New Roman')


set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs{33,2},'/Data Figures (Images)',...
    '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.',inputs{45,2}));
end

%Next save average monthly values
mkdir(strcat(filename,'/',inputs{33,2},'/Data Figures (Images)','/Average monthly values'))

% Velocity
for images_stack_loop = 1:size(monthly_averages,1)
    %Saving hidden figure
 h = figure;set(h, 'Visible', 'off');
    
    m_proj('lambert','lon',[inputs{16, 2} inputs{17, 2}],'lat',[inputs{14, 2} inputs{15, 2}]); 
        m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],save_image);
        brighten(.5);
        alpha(0.7)

    hold on
    m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],monthly_averages{images_stack_loop,3});

    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    
    labeltextv = ['Average velocity for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
    ' ',num2str(monthly_averages{images_stack_loop,1})];
    
        title(labeltextv,'FontSize',25,'FontName', 'Times New Roman');

    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off

col = colorbar;
ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')


set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs{33,2},'/Data Figures (Images)',...
    '/Average monthly values/',labeltextv,'_(',monthly_averages{images_stack_loop,5},')','.',inputs{45,2}));
end


% Flow directions

for images_stack_loop = 1:size(monthly_averages,1)
    %Saving hidden figure
 h = figure;set(h, 'Visible', 'off');
    
    m_proj('lambert','lon',[inputs{16, 2} inputs{17, 2}],'lat',[inputs{14, 2} inputs{15, 2}]); 
        m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],save_image);
        brighten(.5);
        alpha(0.7)

    hold on
    m_image([inputs{16, 2} inputs{17, 2}],[inputs{14, 2} inputs{15, 2}],monthly_averages{images_stack_loop,4});

    m_grid('xtick',10,'ytick',10,'box','fancy','tickdir','in')
    
    labeltextfd = ['Average flow direction for' ' ' num2str(monthly_averages{images_stack_loop,2}),...
    ' ',num2str(monthly_averages{images_stack_loop,1})];
    
        title(labeltextfd,'FontSize',25,'FontName', 'Times New Roman');

    colormap([ flipud(cbrewer('seq', 'Blues', 33));cbrewer('seq', 'Reds', 66);]);
    hold off

col = colorbar;
ylabel(col, 'Ice Velocity (m/year)','FontSize',15,'FontName', 'Times New Roman')


set(gcf, 'Units', 'Inches', 'Position', [0, 0, 17, 20], 'PaperUnits', 'Inches', 'PaperSize', [17, 20])
   saveas(h,strcat(filename,'/',inputs{33,2},'/Data Figures (Images)',...
    '/Average monthly values/',labeltextfd,'_(',monthly_averages{images_stack_loop,5},')','.',inputs{45,2}));
end


end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAVE GEOREFERENCED VELOCITY DATA%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmpi(inputs{44,2}, 'Yes')
    
mkdir(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data'))

%Create location data that will be used for georeferencing all arrays

location_data = georasterref('RasterSize',size(images_stack{3, 2}),'LatitudeLimits',...
    [inputs{14, 2}  ,inputs{15, 2}  ],'LongitudeLimits',[inputs{16, 2}  ,inputs{17, 2}  ]);

%First save flow direction and velocity statistics
mkdir(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data','/Mean, Standard Deviation and other statistics'))

for images_stack_loop = 3:size(images_stack,1)
geotiffwrite(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data',...
    '/Mean, Standard Deviation and other statistics/',images_stack{images_stack_loop,1},'.tif')...
    ,images_stack{images_stack_loop,2},location_data)
end

%Next save average monthly values
mkdir(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data','/Average monthly values'))

for images_stack_loop = 1:size(monthly_averages,1)
geotiffwrite(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data',...
    '/Average monthly values/',labeltextv,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
    monthly_averages{images_stack_loop,3},location_data)
end

for images_stack_loop = 1:size(monthly_averages,1)
geotiffwrite(strcat(filename,'/',inputs{33,2},'/Georeferenced Velocity Data',...
    '/Average monthly values/',labeltextfd,'_(',monthly_averages{images_stack_loop,5},')','.tif'),...
    monthly_averages{images_stack_loop,4},location_data)
end

end

else 
    disp('You chose not to save any files. You may edit the inputs file, rerun loadinpus.mat and then rerun save_images.mat if you have decided to save')
end
