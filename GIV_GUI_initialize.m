function GIV_GUI_initialize()
%
%
%This function starts off the main image velocity calculation code. It will
%open a graphical user interface where the different input values can be
%entered, and then run the functions to calcuate velocities for each image
%pair inputted. 
%
%
%Note this can take a long time (hours) for very large datasets, it is
%sometimes worth testing it with smaller datasets to begin with (and/or
%using low temporal oversampling values).
%
%Most of this very long file is simply setting the location of the boxes,
%etc. Portions were generated automatically using MATLAB's app builder. You
%can tweak it to improve layout if you like, but I would not recommend
%changing it very much. 





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



%% Make sure to add functions to matlab path so that they are accessible
if ~isdeployed
addpath(genpath(pwd));
end
%Create array to hold all the components in 

GUIinputs = [];


%% This portion of the code generated the GUI and input boxes. It is not very interesting.

% Create UIFigure and hide until all components are created
            GUIFigure = uifigure('Visible', 'off');
            GUIFigure.Position = [100 100 656 736];
            GUIFigure.Name = 'GLACIER IMAGE VELOCIMETRY';

            % Create TabGroup
            TabGroup = uitabgroup(GUIFigure);
            TabGroup.Position = [1 194 660 543];

            % Create REQUIREDINPUTSTab
            REQUIREDINPUTSTab = uitab(TabGroup);
            REQUIREDINPUTSTab.Title = '                                            REQUIRED INPUTS                                            ';

            % Create PathtoimagesfolderEditFieldLabel
            PathtoimagesfolderEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            PathtoimagesfolderEditFieldLabel.HorizontalAlignment = 'right';
            PathtoimagesfolderEditFieldLabel.FontName = 'Cambria';
            PathtoimagesfolderEditFieldLabel.Position = [209 305 113 22];
            PathtoimagesfolderEditFieldLabel.Text = 'Path to images folder';

            % Create PathtoimagesfolderEditField
            PathtoimagesfolderEditField = uieditfield(REQUIREDINPUTSTab, 'text');
            PathtoimagesfolderEditField.Position = [337 305 100 22];
            PathtoimagesfolderEditField.Value = 'C:/EXAMPLE/PATH/TO/IMAGES';
            
            % Create Image
            Image = uiimage(REQUIREDINPUTSTab);
            Image.Position = [146 355 347 154];
            Image.ImageSource = 'logo.png';

            % Create BASICINPUTSREQUIREDLabel
            BASICINPUTSREQUIREDLabel = uilabel(REQUIREDINPUTSTab);
            BASICINPUTSREQUIREDLabel.FontName = 'Cambria';
            BASICINPUTSREQUIREDLabel.FontSize = 15;
            BASICINPUTSREQUIREDLabel.FontWeight = 'bold';
            BASICINPUTSREQUIREDLabel.Position = [236 344 191 22];
            BASICINPUTSREQUIREDLabel.Text = 'BASIC INPUTS (REQUIRED)';
            

            % Create MinimumLatitudeLabel
            MinimumLatitudeLabel = uilabel(REQUIREDINPUTSTab);
            MinimumLatitudeLabel.HorizontalAlignment = 'right';
            MinimumLatitudeLabel.FontName = 'Cambria';
            MinimumLatitudeLabel.Position = [213 271 109 22];
            MinimumLatitudeLabel.Text = 'Minimum Latitude   ';

            % Create MinimumLatitudeEditField
            MinimumLatitudeEditField = uieditfield(REQUIREDINPUTSTab, 'numeric');
            MinimumLatitudeEditField.Position = [337 271 100 22];
            MinimumLatitudeEditField.Value = -50.9640;

            % Create MaximumLatitudeEditFieldLabel
            MaximumLatitudeEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            MaximumLatitudeEditFieldLabel.HorizontalAlignment = 'right';
            MaximumLatitudeEditFieldLabel.FontName = 'Cambria';
            MaximumLatitudeEditFieldLabel.Position = [212 237 110 22];
            MaximumLatitudeEditFieldLabel.Text = 'Maximum Latitude   ';

            % Create MaximumLatitudeEditField
            MaximumLatitudeEditField = uieditfield(REQUIREDINPUTSTab, 'numeric');
            MaximumLatitudeEditField.Position = [337 237 100 22];
            MaximumLatitudeEditField.Value = -50.8920;

            % Create MinimumLongitudeEditFieldLabel
            MinimumLongitudeEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            MinimumLongitudeEditFieldLabel.HorizontalAlignment = 'right';
            MinimumLongitudeEditFieldLabel.FontName = 'Cambria';
            MinimumLongitudeEditFieldLabel.Position = [207 205 115 22];
            MinimumLongitudeEditFieldLabel.Text = 'Minimum Longitude  ';

            % Create MinimumLongitudeEditField
            MinimumLongitudeEditField = uieditfield(REQUIREDINPUTSTab, 'numeric');
            MinimumLongitudeEditField.Position = [337 205 100 22];
            MinimumLongitudeEditField.Value = -73.7460;

            % Create MaximumLongitudeEditFieldLabel
            MaximumLongitudeEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            MaximumLongitudeEditFieldLabel.HorizontalAlignment = 'right';
            MaximumLongitudeEditFieldLabel.FontName = 'Cambria';
            MaximumLongitudeEditFieldLabel.Position = [208 170 114 22];
            MaximumLongitudeEditFieldLabel.Text = 'Maximum Longitude ';

            % Create MaximumLongitudeEditField
            MaximumLongitudeEditField = uieditfield(REQUIREDINPUTSTab, 'numeric');
            MaximumLongitudeEditField.Position = [337 170 100 22];
            MaximumLongitudeEditField.Value = -73.4730;
            
            
            % Create ParralelizeCodeLabel
            geotiffinputLabel = uilabel(REQUIREDINPUTSTab);
            geotiffinputLabel.FontName = 'Cambria';
            geotiffinputLabel.Position = [515 250 110 22];
            geotiffinputLabel.Text = 'geoTiff input?';
            
             % Create geotiffinput
            geotiffinputSwitch = uiswitch(REQUIREDINPUTSTab, 'slider');
            geotiffinputSwitch.Items = {'No', 'Yes'};
            geotiffinputSwitch.FontName = 'Cambria';
            geotiffinputSwitch.Position = [525 220 110 22];
            geotiffinputSwitch.Value = 'Yes';
            
            
            % Create TimeoversamplingfactorEditFieldLabel
            TimeoversamplingfactorEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            TimeoversamplingfactorEditFieldLabel.HorizontalAlignment = 'right';
            TimeoversamplingfactorEditFieldLabel.FontName = 'Cambria';
            TimeoversamplingfactorEditFieldLabel.Position = [185 134 137 22];
            TimeoversamplingfactorEditFieldLabel.Text = 'Time oversampling factor';

            % Create TimeoversamplingfactorEditField
            TimeoversamplingfactorEditField = uieditfield(REQUIREDINPUTSTab, 'numeric');
            TimeoversamplingfactorEditField.Position = [337 134 100 22];
            TimeoversamplingfactorEditField.Value = 1;
      
            % Create ParralelizecodeSwitch
            ParralelizecodeSwitch = uiswitch(REQUIREDINPUTSTab, 'slider');
            ParralelizecodeSwitch.Items = {'No', 'Yes'};
            ParralelizecodeSwitch.FontName = 'Cambria';
            ParralelizecodeSwitch.Position = [309 15 45 20];
            ParralelizecodeSwitch.Value = 'Yes';
            
          
            % Create FilenametosaveasEditFieldLabel
            FilenametosaveasEditFieldLabel = uilabel(REQUIREDINPUTSTab);
            FilenametosaveasEditFieldLabel.HorizontalAlignment = 'right';
            FilenametosaveasEditFieldLabel.FontName = 'Cambria';
            FilenametosaveasEditFieldLabel.Position = [215 99 107 22];
            FilenametosaveasEditFieldLabel.Text = 'File name to save as';

            % Create FilenametosaveasEditField
            FilenametosaveasEditField = uieditfield(REQUIREDINPUTSTab, 'text');
            FilenametosaveasEditField.Position = [337 99 100 22];
            FilenametosaveasEditField.Value = 'Glacier Velocities 1';
            
            
     
            % Create ParralelizeCodeLabel
            ParralelizeCodeLabel = uilabel(REQUIREDINPUTSTab);
            ParralelizeCodeLabel.Position = [282 48 101 22];
            ParralelizeCodeLabel.FontName = 'Cambria';
            ParralelizeCodeLabel.Text = 'Parralelize Code?';
          
            % Create SelectButton
            SelectButton = uibutton(REQUIREDINPUTSTab, 'push');
            SelectButton.BackgroundColor = [0.8 0.8 0.8];
            SelectButton.FontName = 'Cambria';
            SelectButton.FontWeight = 'bold';
            SelectButton.Position = [517 305 100 23];
            SelectButton.Text = 'Select';
            SelectButton.ButtonPushedFcn =  @(btn,event) plotButtonPushed1(btn,GUIinputs);
          
            
            % Create orLabel
            orLabel = uilabel(REQUIREDINPUTSTab);
            orLabel.FontName = 'Cambria';
            orLabel.Position = [468 305 25 22];
            orLabel.Text = 'or';

            % Create AdvancedInputsTab
            AdvancedInputsTab = uitab(TabGroup);
            AdvancedInputsTab.Title = '             Advanced Inputs            ';

            % Create Image_2
            Image_2 = uiimage(AdvancedInputsTab);
            Image_2.Position = [146 355 347 154];
            Image_2.ImageSource = 'logo.png';

            % Create TabGroup2
            TabGroup2 = uitabgroup(AdvancedInputsTab);
            TabGroup2.Position = [1 1 659 368];

            % Create TemplatematchingTab
            TemplatematchingTab = uitab(TabGroup2);
            TemplatematchingTab.Title = '        Template matching      ';

            % Create Switch
            Switch = uiswitch(TemplatematchingTab, 'slider');
            Switch.Items = {'Single Pass', 'Multipass'};
            Switch.FontName = 'Cambria';
            Switch.Position = [308 311 45 20];
            Switch.Value = 'Multipass';
            
                          

            % Create SignaltonoiseratioEditFieldLabel
            SignaltonoiseratioEditFieldLabel = uilabel(TemplatematchingTab);
            SignaltonoiseratioEditFieldLabel.HorizontalAlignment = 'right';
            SignaltonoiseratioEditFieldLabel.FontName = 'Cambria';
            SignaltonoiseratioEditFieldLabel.Position = [208 215 106 22];
            SignaltonoiseratioEditFieldLabel.Text = 'Signal to noise ratio';

            % Create SignaltonoiseratioEditField
            SignaltonoiseratioEditField = uieditfield(TemplatematchingTab, 'numeric');
            SignaltonoiseratioEditField.Position = [329 215 100 22];
            if strcmpi(Switch.Value,'Multipass')
            SignaltonoiseratioEditField.Value = 1.3;
            else
            SignaltonoiseratioEditField.Value = 5;    
            end 
            
            
            
                        

%             % Create MultipassoptionsLabel
%             MultipassoptionsLabel = uilabel(TemplatematchingTab);
%             MultipassoptionsLabel.FontName = 'Cambria';
%             MultipassoptionsLabel.Position = [447 259 97 22];
%             MultipassoptionsLabel.Text = 'Multipass options';
% 
%             % Create WindowmatchoverlapEditFieldLabel
%             WindowmatchoverlapEditFieldLabel = uilabel(TemplatematchingTab);
%             WindowmatchoverlapEditFieldLabel.HorizontalAlignment = 'right';
%             WindowmatchoverlapEditFieldLabel.FontName = 'Cambria';
%             WindowmatchoverlapEditFieldLabel.Position = [387 210 124 22];
%             WindowmatchoverlapEditFieldLabel.Text = 'Window match overlap';
% 
%             % Create WindowmatchoverlapEditField
%             WindowmatchoverlapEditField = uieditfield(TemplatematchingTab, 'numeric');
%             WindowmatchoverlapEditField.Position = [526 210 100 22];
%             WindowmatchoverlapEditField.Value = 0.5;
%         
%             % Create MatchwindowsizeEditFieldLabel
%             MatchwindowsizeEditFieldLabel = uilabel(TemplatematchingTab);
%             MatchwindowsizeEditFieldLabel.HorizontalAlignment = 'right';
%             MatchwindowsizeEditFieldLabel.FontName = 'Cambria';
%             MatchwindowsizeEditFieldLabel.Position = [408 170 103 22];
%             MatchwindowsizeEditFieldLabel.Text = 'Match window size';
% 
%             % Create MatchwindowsizeEditField
%             MatchwindowsizeEditField = uieditfield(TemplatematchingTab, 'numeric');
%             MatchwindowsizeEditField.FontName = 'Cambria';
%             MatchwindowsizeEditField.Position = [526 170 100 22];
%             MatchwindowsizeEditField.Value = 64;
%             
%     
%             
% 
%             % Create SinglepassoptionsLabel
%             SinglepassoptionsLabel = uilabel(TemplatematchingTab);
%             SinglepassoptionsLabel.FontName = 'Cambria';
%             SinglepassoptionsLabel.Position = [89 259 103 22];
%             SinglepassoptionsLabel.Text = 'Single pass options';

            % Create IdealresolutionofoutputdataEditFieldLabel
            IdealresolutionofoutputdataEditFieldLabel = uilabel(TemplatematchingTab);
            IdealresolutionofoutputdataEditFieldLabel.HorizontalAlignment = 'right';
            IdealresolutionofoutputdataEditFieldLabel.FontName = 'Cambria';
            IdealresolutionofoutputdataEditFieldLabel.Position = [152 259 161 22];
            IdealresolutionofoutputdataEditFieldLabel.Text = 'Ideal resolution of output data';

            % Create IdealresolutionofoutputdataEditField
            IdealresolutionofoutputdataEditField = uieditfield(TemplatematchingTab, 'numeric');
            IdealresolutionofoutputdataEditField.Position = [328 259 100 22];
            IdealresolutionofoutputdataEditField.Value = 50;
                        
        
%             % Create SearchwindowSizeEditFieldLabel
%             SearchwindowSizeEditFieldLabel = uilabel(TemplatematchingTab);
%             SearchwindowSizeEditFieldLabel.HorizontalAlignment = 'right';
%             SearchwindowSizeEditFieldLabel.FontName = 'Cambria';
%             SearchwindowSizeEditFieldLabel.Position = [77 170 107 22];
%             SearchwindowSizeEditFieldLabel.Text = 'Search window Size';
% 
%             % Create SearchwindowSizeEditField
%             SearchwindowSizeEditField = uieditfield(TemplatematchingTab, 'numeric');
%             SearchwindowSizeEditField.Position = [199 170 100 22];
%             SearchwindowSizeEditField.Value = 30;
%            
%             % Create MinimumsearchareaEditFieldLabel
%             MinimumsearchareaEditFieldLabel = uilabel(TemplatematchingTab);
%             MinimumsearchareaEditFieldLabel.HorizontalAlignment = 'right';
%             MinimumsearchareaEditFieldLabel.FontName = 'Cambria';
%             MinimumsearchareaEditFieldLabel.Position = [68 132 116 22];
%             MinimumsearchareaEditFieldLabel.Text = 'Minimum search area';
% 
%             % Create MinimumsearchareaEditField
%             MinimumsearchareaEditField = uieditfield(TemplatematchingTab, 'numeric');
%             MinimumsearchareaEditField.Position = [199 132 100 22];
%             MinimumsearchareaEditField.Value = 50;
            
        
            % Create DateoptionsTab
            DateoptionsTab = uitab(TabGroup2);
            DateoptionsTab.Title = '      Date options    ';

            % Create MinimumYearEditFieldLabel
            MinimumYearEditFieldLabel = uilabel(DateoptionsTab);
            MinimumYearEditFieldLabel.HorizontalAlignment = 'right';
            MinimumYearEditFieldLabel.FontName = 'Cambria';
            MinimumYearEditFieldLabel.Position = [245 288 85 22];
            MinimumYearEditFieldLabel.Text = 'Minimum Year  ';

            % Create MinimumYearEditField
            MinimumYearEditField = uieditfield(DateoptionsTab, 'numeric');
            MinimumYearEditField.Position = [345 288 100 22];
            MinimumYearEditField.Value = 1900;

            % Create MaximumYearEditFieldLabel
            MaximumYearEditFieldLabel = uilabel(DateoptionsTab);
            MaximumYearEditFieldLabel.HorizontalAlignment = 'right';
            MaximumYearEditFieldLabel.FontName = 'Cambria';
            MaximumYearEditFieldLabel.Position = [243 254 87 22];
            MaximumYearEditFieldLabel.Text = 'Maximum Year  ';

            % Create MaximumYearEditField
            MaximumYearEditField = uieditfield(DateoptionsTab, 'numeric');
            MaximumYearEditField.Position = [345 254 100 22];
            MaximumYearEditField.Value = 2050;
            
        
            % Create MinimumMonthEditFieldLabel
            MinimumMonthEditFieldLabel = uilabel(DateoptionsTab);
            MinimumMonthEditFieldLabel.HorizontalAlignment = 'right';
            MinimumMonthEditFieldLabel.FontName = 'Cambria';
            MinimumMonthEditFieldLabel.Position = [239 222 91 22];
            MinimumMonthEditFieldLabel.Text = 'Minimum Month';

            % Create MinimumMonthEditField
            MinimumMonthEditField = uieditfield(DateoptionsTab, 'numeric');
            MinimumMonthEditField.Position = [345 222 100 22];
            MinimumMonthEditField.Value = 1;

            % Create MaximumMonthEditFieldLabel
            MaximumMonthEditFieldLabel = uilabel(DateoptionsTab);
            MaximumMonthEditFieldLabel.HorizontalAlignment = 'right';
            MaximumMonthEditFieldLabel.FontName = 'Cambria';
            MaximumMonthEditFieldLabel.Position = [237 187 93 22];
            MaximumMonthEditFieldLabel.Text = 'Maximum Month';

            % Create MaximumMonthEditField
            MaximumMonthEditField = uieditfield(DateoptionsTab, 'numeric');
            MaximumMonthEditField.Position = [345 187 100 22];
            MaximumMonthEditField.Value = 12;
            
     

            % Create MinimumDayEditFieldLabel
            MinimumDayEditFieldLabel = uilabel(DateoptionsTab);
            MinimumDayEditFieldLabel.HorizontalAlignment = 'right';
            MinimumDayEditFieldLabel.FontName = 'Cambria';
            MinimumDayEditFieldLabel.Position = [253 152 77 22];
            MinimumDayEditFieldLabel.Text = 'Minimum Day';

            % Create MinimumDayEditField
            MinimumDayEditField = uieditfield(DateoptionsTab, 'numeric');
            MinimumDayEditField.Position = [345 152 100 22];
            MinimumDayEditField.Value = 1;

            % Create MaximumDayEditFieldLabel
            MaximumDayEditFieldLabel = uilabel(DateoptionsTab);
            MaximumDayEditFieldLabel.HorizontalAlignment = 'right';
            MaximumDayEditFieldLabel.FontName = 'Cambria';
            MaximumDayEditFieldLabel.Position = [251 117 79 22];
            MaximumDayEditFieldLabel.Text = 'Maximum Day';

            % Create MaximumDayEditField
            MaximumDayEditField = uieditfield(DateoptionsTab, 'numeric');
            MaximumDayEditField.Position = [345 117 100 22];
            MaximumDayEditField.Value = 31;
            

            % Create MinimumintervalforimagepairsEditFieldLabel
            MinimumintervalforimagepairsEditFieldLabel = uilabel(DateoptionsTab);
            MinimumintervalforimagepairsEditFieldLabel.HorizontalAlignment = 'right';
            MinimumintervalforimagepairsEditFieldLabel.FontName = 'Cambria';
            MinimumintervalforimagepairsEditFieldLabel.Position = [153 70 177 22];
            MinimumintervalforimagepairsEditFieldLabel.Text = 'Minimum interval for image pairs';

            % Create MinimumintervalforimagepairsEditField
            MinimumintervalforimagepairsEditField = uieditfield(DateoptionsTab, 'numeric');
            MinimumintervalforimagepairsEditField.Position = [345 70 100 22];
            MinimumintervalforimagepairsEditField.Value = 0.019;
            
 
            % Create MaximumintervalforimagepairsEditFieldLabel
            MaximumintervalforimagepairsEditFieldLabel = uilabel(DateoptionsTab);
            MaximumintervalforimagepairsEditFieldLabel.HorizontalAlignment = 'right';
            MaximumintervalforimagepairsEditFieldLabel.FontName = 'Cambria';
            MaximumintervalforimagepairsEditFieldLabel.Position = [151 35 179 22];
            MaximumintervalforimagepairsEditFieldLabel.Text = 'Maximum interval for image pairs';

            % Create MaximumintervalforimagepairsEditField
            MaximumintervalforimagepairsEditField = uieditfield(DateoptionsTab, 'numeric');
            MaximumintervalforimagepairsEditField.FontName = 'Cambria';
            MaximumintervalforimagepairsEditField.Position = [345 35 100 22];
            MaximumintervalforimagepairsEditField.Value = 0.75;
            

            % Create ImagefilteringTab
            ImagefilteringTab = uitab(TabGroup2);
            ImagefilteringTab.Title = '        Image filtering      ';

            % Create Switch_2
            Switch_2 = uiswitch(ImagefilteringTab, 'slider');
            Switch_2.Items = {'OFF', 'ON'};
            Switch_2.FontName = 'Cambria';
            Switch_2.Position = [200 293 45 20];
            Switch_2.Value = 'OFF';

            % Create ContrastLimitedHistogramEqualisationLabel
            ContrastLimitedHistogramEqualisationLabel = uilabel(ImagefilteringTab);
            ContrastLimitedHistogramEqualisationLabel.Position = [123 319 220 22];
            ContrastLimitedHistogramEqualisationLabel.Text = 'Contrast Limited Histogram Equalisation';

            % Create Switch_3
            Switch_3 = uiswitch(ImagefilteringTab, 'slider');
            Switch_3.Items = {'OFF', 'ON'};
            Switch_3.FontName = 'Cambria';
            Switch_3.Position = [201 240 45 20];
            Switch_3.Value = 'OFF';

            % Create HighpassFilterLabel
            HighpassFilterLabel = uilabel(ImagefilteringTab);
            HighpassFilterLabel.Position = [180 266 85 22];
            HighpassFilterLabel.Text = 'Highpass Filter';
            

            % Create Switch_4
            Switch_4 = uiswitch(ImagefilteringTab, 'slider');
            Switch_4.Items = {'OFF', 'ON'};
            Switch_4.FontName = 'Cambria';
            Switch_4.Position = [202 191 45 20];
            Switch_4.Value = 'OFF';

            % Create IntensityCapLabel
            IntensityCapLabel = uilabel(ImagefilteringTab);
            IntensityCapLabel.Position = [187 215 75 22];
            IntensityCapLabel.Text = 'Intensity Cap';
 

            % Create Switch_5
            Switch_5 = uiswitch(ImagefilteringTab, 'slider');
            Switch_5.Items = {'OFF', 'ON'};
            Switch_5.FontName = 'Cambria';
            Switch_5.Position = [201 130 45 20];
            Switch_5.Value = 'ON';

            % Create OrientationFilterLabel
            OrientationFilterLabel = uilabel(ImagefilteringTab);
            OrientationFilterLabel.Position = [178 154 94 22];
            OrientationFilterLabel.Text = 'Orientation Filter';
            


            % Create CLAHEsizeEditFieldLabel
            CLAHEsizeEditFieldLabel = uilabel(ImagefilteringTab);
            CLAHEsizeEditFieldLabel.HorizontalAlignment = 'right';
            CLAHEsizeEditFieldLabel.Position = [384 298 70 22];
            CLAHEsizeEditFieldLabel.Text = 'CLAHE size';

            % Create CLAHEsizeEditField
            CLAHEsizeEditField = uieditfield(ImagefilteringTab, 'numeric');
            CLAHEsizeEditField.Position = [469 298 100 22];
            CLAHEsizeEditField.Value = 10;
            
           


            % Create HighpasssizeEditFieldLabel
            HighpasssizeEditFieldLabel = uilabel(ImagefilteringTab);
            HighpasssizeEditFieldLabel.HorizontalAlignment = 'right';
            HighpasssizeEditFieldLabel.Position = [375 245 80 22];
            HighpasssizeEditFieldLabel.Text = 'Highpass size';

            % Create HighpasssizeEditField
            HighpasssizeEditField = uieditfield(ImagefilteringTab, 'numeric');
            HighpasssizeEditField.Position = [470 245 100 22];
            HighpasssizeEditField.Value = 10;
            
         

            % Create Switch_10
            Switch_10 = uiswitch(ImagefilteringTab, 'slider');
            Switch_10.Items = {'OFF', 'ON'};
            Switch_10.FontName = 'Cambria';
            Switch_10.Position = [202 70 45 20];
            Switch_10.Value = 'OFF';

            % Create Sobel Filter
            Sobel_Filter = uilabel(ImagefilteringTab);
            Sobel_Filter.Position = [187 94 75 22];
            Sobel_Filter.Text = 'Sobel Filter';


            % Create Switch_11
            Switch_11 = uiswitch(ImagefilteringTab, 'slider');
            Switch_11.Items = {'OFF', 'ON'};
            Switch_11.FontName = 'Cambria';
            Switch_11.Position = [201 9 45 20];
            Switch_11.Value = 'OFF';
            
              % Create OrientationFilterLabel_2
            Laplacian_filter = uilabel(ImagefilteringTab);
            Laplacian_filter.Position = [178 33 94 22];
            Laplacian_filter.Text = 'Laplacian filter';
            

            % Create SavingTab
            SavingTab = uitab(TabGroup2);
            SavingTab.Title = '       Saving      ';

            % Create Switch_6
            Switch_6 = uiswitch(SavingTab, 'slider');
            Switch_6.Items = {'OFF', 'ON'};
            Switch_6.FontName = 'Cambria';
            Switch_6.Position = [298 275 45 20];
            Switch_6.Value = 'ON';

            % Create SaveMATLABdataarraysLabel
            SaveMATLABdataarraysLabel = uilabel(SavingTab);
            SaveMATLABdataarraysLabel.Position = [254 302 153 22];
            SaveMATLABdataarraysLabel.Text = 'Save MATLAB data arrays?';


            % Create Switch_7
            Switch_7 = uiswitch(SavingTab, 'slider');
            Switch_7.Items = {'OFF', 'ON'};
            Switch_7.FontName = 'Cambria';
            Switch_7.Position = [298 198 45 20];
            Switch_7.Value = 'ON';

            % Create Switch_8
            Switch_8 = uiswitch(SavingTab, 'slider');
            Switch_8.Items = {'OFF', 'ON'};
            Switch_8.FontName = 'Cambria';
            Switch_8.Position = [299 19 45 20];
            Switch_8.Value = 'ON';

            % Create SavegeoreferencedtifimagesLabel
            SavegeoreferencedtifimagesLabel = uilabel(SavingTab);
            SavegeoreferencedtifimagesLabel.Position = [233 46 178 22];
            SavegeoreferencedtifimagesLabel.Text = 'Save georeferenced .tif images?';

            % Create SaveimagesofkeyvelocitiesLabel
            SaveimagesofkeyvelocitiesLabel = uilabel(SavingTab);
            SaveimagesofkeyvelocitiesLabel.Position = [237 229 169 22];
            SaveimagesofkeyvelocitiesLabel.Text = 'Save images of key velocities?';
            

            % Create FormatofimagestosaveEditFieldLabel
            FormatofimagestosaveEditFieldLabel = uilabel(SavingTab);
            FormatofimagestosaveEditFieldLabel.HorizontalAlignment = 'right';
            FormatofimagestosaveEditFieldLabel.Position = [147 119 141 22];
            FormatofimagestosaveEditFieldLabel.Text = 'Format of images to save';

            % Create FormatofimagestosaveEditField
            FormatofimagestosaveEditField = uieditfield(SavingTab, 'text');
            FormatofimagestosaveEditField.Position = [303 119 100 22];
            FormatofimagestosaveEditField.Value = 'png';


            % Create OtherTab
            OtherTab = uitab(TabGroup2);
            OtherTab.Title = '     Other     ';

            % Create MaximumVelocityEditFieldLabel
            MaximumVelocityEditFieldLabel = uilabel(OtherTab);
            MaximumVelocityEditFieldLabel.HorizontalAlignment = 'right';
            MaximumVelocityEditFieldLabel.FontName = 'Cambria';
            MaximumVelocityEditFieldLabel.Position = [222 300 100 22];
            MaximumVelocityEditFieldLabel.Text = 'Maximum Velocity';

            % Create MaximumVelocityEditField
            MaximumVelocityEditField = uieditfield(OtherTab, 'numeric');
            MaximumVelocityEditField.Position = [337 300 100 22];
            MaximumVelocityEditField.Value = 2500;
            
            % Create Excludedangle1minimumEditFieldLabel
            Excludedangle1minimumEditFieldLabel = uilabel(OtherTab);
            Excludedangle1minimumEditFieldLabel.HorizontalAlignment = 'right';
            Excludedangle1minimumEditFieldLabel.FontName = 'Cambria';
            Excludedangle1minimumEditFieldLabel.Position = [58 210 144 22];
            Excludedangle1minimumEditFieldLabel.Text = 'Excluded angle 1 minimum';

            % Create Excludedangle1minimumEditField
            Excludedangle1minimumEditField = uieditfield(OtherTab, 'numeric');
            Excludedangle1minimumEditField.Position = [217 210 100 22];

            % Create Excludedangle2minimumEditFieldLabel
            Excludedangle2minimumEditFieldLabel = uilabel(OtherTab);
            Excludedangle2minimumEditFieldLabel.HorizontalAlignment = 'right';
            Excludedangle2minimumEditFieldLabel.FontName = 'Cambria';
            Excludedangle2minimumEditFieldLabel.Position = [58 174 144 22];
            Excludedangle2minimumEditFieldLabel.Text = 'Excluded angle 2 minimum';

            % Create Excludedangle2minimumEditField
            Excludedangle2minimumEditField = uieditfield(OtherTab, 'numeric');
            Excludedangle2minimumEditField.Position = [217 174 100 22];
            Excludedangle2minimumEditField.Value = 360;
            
                        % Create Excludedangle2maximumEditFieldLabel
            Excludedangle2maximumEditFieldLabel = uilabel(OtherTab);
            Excludedangle2maximumEditFieldLabel.HorizontalAlignment = 'right';
            Excludedangle2maximumEditFieldLabel.FontName = 'Cambria';
            Excludedangle2maximumEditFieldLabel.Position = [353 174 146 22];
            Excludedangle2maximumEditFieldLabel.Text = 'Excluded angle 2 maximum';

            % Create Excludedangle2maximumEditField
            Excludedangle2maximumEditField = uieditfield(OtherTab, 'numeric');
            Excludedangle2maximumEditField.Position = [514 174 100 22];
            Excludedangle2maximumEditField.Value = 360;

            % Create Excludedangle1maximumEditFieldLabel
            Excludedangle1maximumEditFieldLabel = uilabel(OtherTab);
            Excludedangle1maximumEditFieldLabel.HorizontalAlignment = 'right';
            Excludedangle1maximumEditFieldLabel.FontName = 'Cambria';
            Excludedangle1maximumEditFieldLabel.Position = [353 210 146 22];
            Excludedangle1maximumEditFieldLabel.Text = 'Excluded angle 1 maximum';

            % Create Excludedangle1maximumEditField
            Excludedangle1maximumEditField = uieditfield(OtherTab, 'numeric');
            Excludedangle1maximumEditField.Position = [514 210 100 22];
            

% % %             % Create MinimumangleEditFieldLabel
% % %             MinimumangleEditFieldLabel = uilabel(OtherTab);
% % %             MinimumangleEditFieldLabel.HorizontalAlignment = 'right';
% % %             MinimumangleEditFieldLabel.FontName = 'Cambria';
% % %             MinimumangleEditFieldLabel.Position = [230 187 85 22];
% % %             MinimumangleEditFieldLabel.Text = 'Minimum angle';
% % % 
% % %             % Create MinimumangleEditField
% % %             MinimumangleEditField = uieditfield(OtherTab, 'numeric');
% % %             MinimumangleEditField.Position = [330 187 100 22];
% % %             MinimumangleEditField.Value = 0;
% % % 
% % %             
% % %             % Create MaximumAngleEditFieldLabel
% % %             MaximumAngleEditFieldLabel = uilabel(OtherTab);
% % %             MaximumAngleEditFieldLabel.HorizontalAlignment = 'right';
% % %             MaximumAngleEditFieldLabel.FontName = 'Cambria';
% % %             MaximumAngleEditFieldLabel.Position = [227 151 88 22];
% % %             MaximumAngleEditFieldLabel.Text = 'Maximum Angle';
% % % 
% % %             % Create MaximumAngleEditField
% % %             MaximumAngleEditField = uieditfield(OtherTab, 'numeric');
% % %             MaximumAngleEditField.Position = [330 151 100 22];
% % %             MaximumAngleEditField.Value = 360;

            % Create Switch_9
            Switch_9 = uiswitch(OtherTab, 'slider');
            Switch_9.Items = {'NO', 'YES'};
            Switch_9.FontName = 'Cambria';
            Switch_9.Position = [316 243 45 20];
            Switch_9.Value = 'NO';
            

            % Create FilterbasedonflowdirectionLabel
            FilterbasedonflowdirectionLabel = uilabel(OtherTab);
            FilterbasedonflowdirectionLabel.Position = [272 270 158 22];
            FilterbasedonflowdirectionLabel.Text = 'Filter based on flow direction';
            

            
            % Create SmoothingofcompositearrayofallvelocitiesDropDownLabel
            SmoothingofcompositearrayofallvelocitiesDropDownLabel = uilabel(OtherTab);
            SmoothingofcompositearrayofallvelocitiesDropDownLabel.HorizontalAlignment = 'right';
            SmoothingofcompositearrayofallvelocitiesDropDownLabel.Position = [103 18 248 22];
            SmoothingofcompositearrayofallvelocitiesDropDownLabel.Text = 'Smoothing of composite array of all velocities';

            % Create SmoothingofcompositearrayofallvelocitiesDropDown
            SmoothingofcompositearrayofallvelocitiesDropDown = uidropdown(OtherTab);
            SmoothingofcompositearrayofallvelocitiesDropDown.Items = {'No Smoothing', 'Smoothing in time', 'Smoothing in time and space'};
            SmoothingofcompositearrayofallvelocitiesDropDown.Position = [365 18 192 22];
            SmoothingofcompositearrayofallvelocitiesDropDown.Value = 'Smoothing in time and space';
            
                        % Create NumberofiterationsformonthlyvelocitiesEditFieldLabel
            NumberofiterationsformonthlyvelocitiesEditFieldLabel = uilabel(OtherTab);
            NumberofiterationsformonthlyvelocitiesEditFieldLabel.HorizontalAlignment = 'right';
            NumberofiterationsformonthlyvelocitiesEditFieldLabel.Position = [134 59 231 22];
            NumberofiterationsformonthlyvelocitiesEditFieldLabel.Text = 'Number of iterations for monthly velocities';

            % Create NumberofiterationsformonthlyvelocitiesEditField
            NumberofiterationsformonthlyvelocitiesEditField = uieditfield(OtherTab, 'numeric');
            NumberofiterationsformonthlyvelocitiesEditField.Position = [380 59 100 22];
            NumberofiterationsformonthlyvelocitiesEditField.Value = 0;
            
                        % Create Switch_12
            Switch_12 = uiswitch(OtherTab, 'slider');
            Switch_12.Items = {'NO', 'YES'};
            Switch_12.FontName = 'Cambria';
            Switch_12.Position = [321 102 45 20];
            Switch_12.Value = 'NO';

            % Create NormalizetovelocityofastableregionLabel
            NormalizetovelocityofastableregionLabel = uilabel(OtherTab);
            NormalizetovelocityofastableregionLabel.Position = [245 130 212 22];
            NormalizetovelocityofastableregionLabel.Text = 'Normalize to velocity of a stable region';


            % Create GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel = uilabel(GUIFigure);
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.FontName = 'Cambria';
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.FontAngle = 'italic';
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.Position = [116 26 447 22];
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.Text = 'GIV: A GLACIER VELOCITY CALCULATION TOOLBOX BY MAX VAN WYK DE VRIES ET AL.';

            % Create WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel = uilabel(GUIFigure);
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontName = 'Cambria';
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontSize = 10;
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontAngle = 'italic';
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.Position = [184 6 295 22];
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.Text = 'WWW.GIVGLACIER.COM --- CONTACT ME AT VANWY048@UMN.EDU ';

            % Create CALCULATEVELOCITIESButton
            CALCULATEVELOCITIESButton = uibutton(GUIFigure, 'push');
            CALCULATEVELOCITIESButton.BackgroundColor = [0.302 0.7451 0.9333];
            CALCULATEVELOCITIESButton.FontName = 'Cambria';
            CALCULATEVELOCITIESButton.FontSize = 25;
            CALCULATEVELOCITIESButton.FontWeight = 'bold';
            CALCULATEVELOCITIESButton.FontAngle = 'italic';
            CALCULATEVELOCITIESButton.FontColor = [0 0.149 1];
            CALCULATEVELOCITIESButton.Position = [186 59 310 71];
            CALCULATEVELOCITIESButton.Text = 'CALCULATE VELOCITIES';
            CALCULATEVELOCITIESButton.ButtonPushedFcn = @(btn,event) plotButtonPushed2 (btn);

            % Create LoadsetupButton
            LoadsetupButton = uibutton(GUIFigure, 'push');
            LoadsetupButton.FontName = 'Cambria';
            LoadsetupButton.FontWeight = 'bold';
            LoadsetupButton.Position = [26 77 100 34];
            LoadsetupButton.Text = 'Load setup';
            LoadsetupButton.ButtonPushedFcn =  @(btn,event) plotButtonPushed3(btn);
            
            % Create SavesetupButton
            SavesetupButton = uibutton(GUIFigure, 'push');
            SavesetupButton.BackgroundColor = [0.9412 0.9412 0.9412];
            SavesetupButton.FontName = 'Cambria';
            SavesetupButton.FontWeight = 'bold';
            SavesetupButton.Position = [536 77 100 34];
            SavesetupButton.Text = 'Save setup';
            SavesetupButton.ButtonPushedFcn = @(btn,event) plotButtonPushed4 (btn);
            
                        % Create AnalyseImagePairsButton
            AnalyseImagePairsButton = uibutton(GUIFigure, 'push');
            AnalyseImagePairsButton.BackgroundColor = [0.302 0.7451 0.9333];
            AnalyseImagePairsButton.FontName = 'Cambria';
            AnalyseImagePairsButton.FontSize = 18;
            AnalyseImagePairsButton.FontWeight = 'bold';
            AnalyseImagePairsButton.FontAngle = 'italic';
            AnalyseImagePairsButton.Position = [248 142 185 40];
            AnalyseImagePairsButton.Text = 'Analyse Image Pairs';
            AnalyseImagePairsButton.ButtonPushedFcn = @(btn,event) plotButtonPushed5 (btn);



            % Show the figure after all components are created
            GUIFigure.Visible = 'on';
                
            
         %% This portion makes the buttons call the relevant functions. 
         
         %For ease, functions are all wrapped in a single GIV_GUI_main,
         %which is called here.
         
        
        % This button press allows you to select the input folder.    
        function [btn,event,GUIinputs]= plotButtonPushed1(btn,GUIinputs)
            a = uigetdir('.');  
            PathtoimagesfolderEditField.Value = a;
            GUIinputs.folder = a;
            figure(GUIFigure)
        end
        
        %This button runs GIV
        function [btn,event]= plotButtonPushed2(btn,GUIinputs)
            
            %Display message to user
            logo = imread('GIV_LOGO_SMALL.png');
            msgbox({'RUNNING...YOU MAY CLOSE THE INPUTS BOX. IT MAY TAKE A FEW SECONDS TO CLOSE'},...
            'GIV is running','custom',logo);

            %Combine input into a MATLAB struct array. These are more human
            %readable than a simple array, and easier to modify in the
            %future.
            GUIinputs.folder = PathtoimagesfolderEditField.Value;   
            GUIinputs.isgeotiff = geotiffinputSwitch.Value;
            GUIinputs.minlat = MinimumLatitudeEditField.Value;
            GUIinputs.maxlat = MaximumLatitudeEditField.Value;
            GUIinputs.minlon = MinimumLongitudeEditField.Value;
            GUIinputs.maxlon = MaximumLongitudeEditField.Value;
            GUIinputs.temporaloversampling = TimeoversamplingfactorEditField.Value; 
            GUIinputs.parralelize = ParralelizecodeSwitch.Value;
            GUIinputs.name = FilenametosaveasEditField.Value; 
            
            if strcmpi(Switch.Value, 'Multipass')    
                GUIinputs.numpass = 'Multi'; 
            else
                GUIinputs.numpass = 'Single';     
            end
            
            GUIinputs.snr = SignaltonoiseratioEditField.Value;
            GUIinputs.windowoverlap = 0.5;
            GUIinputs.idealresolution = IdealresolutionofoutputdataEditField.Value;
            GUIinputs.searchwindowsize = 30;
            GUIinputs.minsearcharea = 50;
            GUIinputs.minyear = MinimumYearEditField.Value; 
            GUIinputs.maxyear = MaximumYearEditField.Value;
            GUIinputs.minmonth = MinimumMonthEditField.Value; 
            GUIinputs.maxmonth = MaximumMonthEditField.Value;
            GUIinputs.minday = MinimumDayEditField.Value; 
            GUIinputs.maxday = MaximumDayEditField.Value;
            GUIinputs.mininterval = MinimumintervalforimagepairsEditField.Value;
            GUIinputs.maxinterval = MaximumintervalforimagepairsEditField.Value;
            
            if strcmpi(Switch_2.Value, 'ON')
                GUIinputs.CLAHE = 1;
            else
                GUIinputs.CLAHE = 0;
            end
            
            if strcmpi(Switch_3.Value, 'ON')
                GUIinputs.hipass = 1;
            else
                GUIinputs.hipass = 0;
            end
            
            if strcmpi(Switch_4.Value, 'ON')
                GUIinputs.intenscap = 1;
            else
                GUIinputs.intenscap = 0;
            end
            
            if strcmpi(Switch_5.Value, 'ON')
             GUIinputs.NAOF = 1;
            else
                GUIinputs.NAOF = 0;
            end
            
            GUIinputs.CLAHEsize = CLAHEsizeEditField.Value;
            GUIinputs.hipasssize = HighpasssizeEditField.Value;
            
            if strcmpi(Switch_10.Value, 'ON')
             GUIinputs.sobel = 1;
            else
                GUIinputs.sobel = 0;
            end
            
            if strcmpi(Switch_11.Value, 'ON')
             GUIinputs.laplacian = 1;
            else
                GUIinputs.laplacian = 0;
            end
            
            if strcmpi(Switch_6.Value, 'ON')
                GUIinputs.savearrays = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savearrays = 'No';
            end
            
            if strcmpi(Switch_7.Value, 'ON')
                GUIinputs.savekeyvel = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savekeyvel = 'No';
            end
            
            if strcmpi(Switch_8.Value, 'ON')
                GUIinputs.savegeotiff = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savegeotiff = 'No';
            end
            
            GUIinputs.imageformat = FormatofimagestosaveEditField.Value;
            GUIinputs.maxvel = MaximumVelocityEditField.Value;
            GUIinputs.excudedangle1.min = Excludedangle1minimumEditField.Value;
            GUIinputs.excudedangle1.max = Excludedangle1maximumEditField.Value;
            GUIinputs.excudedangle2.min = Excludedangle2minimumEditField.Value;  
            GUIinputs.excudedangle2.max = Excludedangle2maximumEditField.Value;
            
            if strcmpi(Switch_12.Value, 'YES')
                GUIinputs.stable = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.stable = 'No';
            end
            
            if strcmpi(Switch_9.Value, 'YES')
                GUIinputs.excludeangle = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.excludeangle = 'No';
            end
            
            if strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time and space')
                GUIinputs.finalsmooth = 'Time and Space';
            elseif strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time')
                GUIinputs.finalsmooth = 'Time';
            else
                GUIinputs.finalsmooth = 'None';    
            end
            
            GUIinputs.nummonthiter = NumberofiterationsformonthlyvelocitiesEditField.Value; 
                    
            %Rename this array
            inputs = GUIinputs;
            
            %Call the main wrapper function
            GIV_GUI_main(inputs)
        end
        
        %Load a previously saved inputs file.
        function [btn,event]= plotButtonPushed3(btn)
            
            %Prompt user to select file
            load_file = uigetfile('input files', 'Select an input file you previously saved.')
            load(strcat(load_file,'/',file_name),'inputs');
            
            %Display message
            logo = imread('GIV_LOGO_SMALL.png');
            msgbox({'RUNNING...YOU MAY CLOSE THE INPUTS BOX. IT MAY TAKE A FEW SECONDS TO CLOSE'},...
           'GIV is running','custom',logo);
            
            %Call main wrapper function
            GIV_GUI_main(inputs)
        end
        
        %Save an input setup
        function [btn,event]= plotButtonPushed4(btn,GUIinputs)
  
            %Combine input into a MATLAB struct array. These are more human
            %readable than a simple array, and easier to modify in the
            %future.
            GUIinputs.folder = PathtoimagesfolderEditField.Value;   
            GUIinputs.isgeotiff = geotiffinputSwitch.Value;
            GUIinputs.minlat = MinimumLatitudeEditField.Value;
            GUIinputs.maxlat = MaximumLatitudeEditField.Value;
            GUIinputs.minlon = MinimumLongitudeEditField.Value;
            GUIinputs.maxlon = MaximumLongitudeEditField.Value;
            GUIinputs.temporaloversampling = TimeoversamplingfactorEditField.Value; 
            GUIinputs.parralelize = ParralelizecodeSwitch.Value;
            GUIinputs.name = FilenametosaveasEditField.Value; 
            
            if strcmpi(Switch.Value, 'Multipass')    
                GUIinputs.numpass = 'Multi'; 
            else
                GUIinputs.numpass = 'Single';     
            end
            
            GUIinputs.snr = SignaltonoiseratioEditField.Value;
            GUIinputs.windowoverlap = 0.5;
            GUIinputs.idealresolution = IdealresolutionofoutputdataEditField.Value;
            GUIinputs.searchwindowsize = 30;
            GUIinputs.minsearcharea = 50;
            GUIinputs.minyear = MinimumYearEditField.Value; 
            GUIinputs.maxyear = MaximumYearEditField.Value;
            GUIinputs.minmonth = MinimumMonthEditField.Value; 
            GUIinputs.maxmonth = MaximumMonthEditField.Value;
            GUIinputs.minday = MinimumDayEditField.Value; 
            GUIinputs.maxday = MaximumDayEditField.Value;
            GUIinputs.mininterval = MinimumintervalforimagepairsEditField.Value;
            GUIinputs.maxinterval = MaximumintervalforimagepairsEditField.Value;
            
            if strcmpi(Switch_2.Value, 'ON')
                GUIinputs.CLAHE = 1;
            else
                GUIinputs.CLAHE = 0;
            end
            
            if strcmpi(Switch_3.Value, 'ON')
                GUIinputs.hipass = 1;
            else
                GUIinputs.hipass = 0;
            end
            
            if strcmpi(Switch_4.Value, 'ON')
                GUIinputs.intenscap = 1;
            else
                GUIinputs.intenscap = 0;
            end
            
            if strcmpi(Switch_5.Value, 'ON')
             GUIinputs.NAOF = 1;
            else
                GUIinputs.NAOF = 0;
            end
            
            GUIinputs.CLAHEsize = CLAHEsizeEditField.Value;
            GUIinputs.hipasssize = HighpasssizeEditField.Value;
            
            if strcmpi(Switch_10.Value, 'ON')
             GUIinputs.sobel = 1;
            else
                GUIinputs.sobel = 0;
            end
            
            if strcmpi(Switch_11.Value, 'ON')
             GUIinputs.laplacian = 1;
            else
                GUIinputs.laplacian = 0;
            end
            
            if strcmpi(Switch_6.Value, 'ON')
                GUIinputs.savearrays = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savearrays = 'No';
            end
            
            if strcmpi(Switch_7.Value, 'ON')
                GUIinputs.savekeyvel = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savekeyvel = 'No';
            end
            
            if strcmpi(Switch_8.Value, 'ON')
                GUIinputs.savegeotiff = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savegeotiff = 'No';
            end
            
            GUIinputs.imageformat = FormatofimagestosaveEditField.Value;
            GUIinputs.maxvel = MaximumVelocityEditField.Value;
            GUIinputs.excudedangle1.min = Excludedangle1minimumEditField.Value;
            GUIinputs.excudedangle1.max = Excludedangle1maximumEditField.Value;
            GUIinputs.excudedangle2.min = Excludedangle2minimumEditField.Value;  
            GUIinputs.excudedangle2.max = Excludedangle2maximumEditField.Value;
            
            if strcmpi(Switch_12.Value, 'YES')
                GUIinputs.stable = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.stable = 'No';
            end
            
            if strcmpi(Switch_9.Value, 'YES')
                GUIinputs.excludeangle = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.excludeangle = 'No';
            end
            
            if strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time and space')
                GUIinputs.finalsmooth = 'Time and Space';
            elseif strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time')
                GUIinputs.finalsmooth = 'Time';
            else
                GUIinputs.finalsmooth = 'None';    
            end
            
            GUIinputs.nummonthiter = NumberofiterationsformonthlyvelocitiesEditField.Value; 
                    
            %Rename this array
            inputs = GUIinputs;
            
            %Save the file
            filename2 = strcat(inputs{1,2},'/input files');
            if ~exist(filename2)
                mkdir(filename2)
            end
            uisave('inputs',strcat(filename2,'/','savefile'));
            
        end
    
         %Calculate number of viable images for a given setup.   
         function [btn,event]= plotButtonPushed5(btn,GUIinputs)
            
            %Display message to user 
            logo = imread('GIV_LOGO_SMALL.png');
             msgbox({'CALCULATING NUMBER OF IMAGE PAIRS...YOU MAY CLOSE THE INPUTS BOX. IT MAY TAKE A FEW SECONDS TO CLOSE'},...
            'GIV is running','custom',logo);

            %Combine input into a MATLAB struct array. These are more human
            %readable than a simple array, and easier to modify in the
            %future.
            GUIinputs.folder = PathtoimagesfolderEditField.Value;   
            GUIinputs.isgeotiff = geotiffinputSwitch.Value;
            GUIinputs.minlat = MinimumLatitudeEditField.Value;
            GUIinputs.maxlat = MaximumLatitudeEditField.Value;
            GUIinputs.minlon = MinimumLongitudeEditField.Value;
            GUIinputs.maxlon = MaximumLongitudeEditField.Value;
            GUIinputs.temporaloversampling = TimeoversamplingfactorEditField.Value; 
            GUIinputs.parralelize = ParralelizecodeSwitch.Value;
            GUIinputs.name = FilenametosaveasEditField.Value; 
            
            if strcmpi(Switch.Value, 'Multipass')    
                GUIinputs.numpass = 'Multi'; 
            else
                GUIinputs.numpass = 'Single';     
            end
            
            GUIinputs.snr = SignaltonoiseratioEditField.Value;
            GUIinputs.windowoverlap = 0.5;
            GUIinputs.idealresolution = IdealresolutionofoutputdataEditField.Value;
            GUIinputs.searchwindowsize = 30;
            GUIinputs.minsearcharea = 50;
            GUIinputs.minyear = MinimumYearEditField.Value; 
            GUIinputs.maxyear = MaximumYearEditField.Value;
            GUIinputs.minmonth = MinimumMonthEditField.Value; 
            GUIinputs.maxmonth = MaximumMonthEditField.Value;
            GUIinputs.minday = MinimumDayEditField.Value; 
            GUIinputs.maxday = MaximumDayEditField.Value;
            GUIinputs.mininterval = MinimumintervalforimagepairsEditField.Value;
            GUIinputs.maxinterval = MaximumintervalforimagepairsEditField.Value;
            
            if strcmpi(Switch_2.Value, 'ON')
                GUIinputs.CLAHE = 1;
            else
                GUIinputs.CLAHE = 0;
            end
            
            if strcmpi(Switch_3.Value, 'ON')
                GUIinputs.hipass = 1;
            else
                GUIinputs.hipass = 0;
            end
            
            if strcmpi(Switch_4.Value, 'ON')
                GUIinputs.intenscap = 1;
            else
                GUIinputs.intenscap = 0;
            end
            
            if strcmpi(Switch_5.Value, 'ON')
             GUIinputs.NAOF = 1;
            else
                GUIinputs.NAOF = 0;
            end
            
            GUIinputs.CLAHEsize = CLAHEsizeEditField.Value;
            GUIinputs.hipasssize = HighpasssizeEditField.Value;
            
            if strcmpi(Switch_10.Value, 'ON')
             GUIinputs.sobel = 1;
            else
                GUIinputs.sobel = 0;
            end
            
            if strcmpi(Switch_11.Value, 'ON')
             GUIinputs.laplacian = 1;
            else
                GUIinputs.laplacian = 0;
            end
            
            if strcmpi(Switch_6.Value, 'ON')
                GUIinputs.savearrays = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savearrays = 'No';
            end
            
            if strcmpi(Switch_7.Value, 'ON')
                GUIinputs.savekeyvel = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savekeyvel = 'No';
            end
            
            if strcmpi(Switch_8.Value, 'ON')
                GUIinputs.savegeotiff = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.savegeotiff = 'No';
            end
            
            GUIinputs.imageformat = FormatofimagestosaveEditField.Value;
            GUIinputs.maxvel = MaximumVelocityEditField.Value;
            GUIinputs.excudedangle1.min = Excludedangle1minimumEditField.Value;
            GUIinputs.excudedangle1.max = Excludedangle1maximumEditField.Value;
            GUIinputs.excudedangle2.min = Excludedangle2minimumEditField.Value;  
            GUIinputs.excudedangle2.max = Excludedangle2maximumEditField.Value;
            
            if strcmpi(Switch_12.Value, 'YES')
                GUIinputs.stable = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.stable = 'No';
            end
            
            if strcmpi(Switch_9.Value, 'YES')
                GUIinputs.excludeangle = 'Yes'; %'Yes' or 'No'
            else 
                GUIinputs.excludeangle = 'No';
            end
            
            if strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time and space')
                GUIinputs.finalsmooth = 'Time and Space';
            elseif strcmpi(SmoothingofcompositearrayofallvelocitiesDropDown.Value, 'Smoothing in time')
                GUIinputs.finalsmooth = 'Time';
            else
                GUIinputs.finalsmooth = 'None';    
            end
            
            GUIinputs.nummonthiter = NumberofiterationsformonthlyvelocitiesEditField.Value; 
                    
            %Rename this array
            inputs = GUIinputs;
            
            %Call the viable image calculation script.
            GIVruntime(inputs);
        end   
    

end
        
