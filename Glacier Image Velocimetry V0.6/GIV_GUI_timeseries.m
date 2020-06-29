function GIV_GUI_timeseries()
% This function opens up a user interface that is used to extract time
% series plots from previously calculated velocity maps. It may be run
% independantly at any point after the main function GIV_GUI_initialize has
% been completed.
% 
% 1 = array with different lat longs inputted by user
% 
% 2 = size of padding of averages 0 = no pad, 1 = 1 cell pad, etc.
% 
% 3 = Yes or no for calculate for raw data
% 
% 4 = Yes or no for calculate for monthly data
% 
% 5 = flow direction and velocity or just velocity


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



            % Create TimeseriesGUIFigure and hide until all components are created
            TimeseriesGUIFigure = uifigure('Visible', 'off');
            TimeseriesGUIFigure.Position = [100 100 630 561];
            TimeseriesGUIFigure.Name = 'GIV: EXTRACT TIME SERIES';

            % Create Image
            Image = uiimage(TimeseriesGUIFigure);
            Image.Position = [130 410 345 152];
            Image.ImageSource = 'logo.png';

            % Create Latitude1EditFieldLabel
            Latitude1EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude1EditFieldLabel.HorizontalAlignment = 'right';
            Latitude1EditFieldLabel.FontName = 'Cambria';
            Latitude1EditFieldLabel.Position = [31 294 57 22];
            Latitude1EditFieldLabel.Text = 'Latitude 1';

            % Create Latitude1EditField
            Latitude1EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude1EditField.FontName = 'Cambria';
            Latitude1EditField.Position = [103 294 67 22];
            Latitude1EditField.Value = 0;

            % Create Longitude1EditFieldLabel
            Longitude1EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude1EditFieldLabel.HorizontalAlignment = 'right';
            Longitude1EditFieldLabel.FontName = 'Cambria';
            Longitude1EditFieldLabel.Position = [187 294 67 22];
            Longitude1EditFieldLabel.Text = 'Longitude 1';

            % Create Longitude1EditField
            Longitude1EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude1EditField.FontName = 'Cambria';
            Longitude1EditField.Position = [269 294 67 22];
            Longitude1EditField.Value = 0;

            % Create Latitude2EditFieldLabel
            Latitude2EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude2EditFieldLabel.HorizontalAlignment = 'right';
            Latitude2EditFieldLabel.FontName = 'Cambria';
            Latitude2EditFieldLabel.Position = [31 262 57 22];
            Latitude2EditFieldLabel.Text = 'Latitude 2';
            

            % Create Latitude2EditField
            Latitude2EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude2EditField.FontName = 'Cambria';
            Latitude2EditField.Position = [103 262 67 22];
            Latitude2EditField.Value = 0;

            % Create Longitude2EditFieldLabel
            Longitude2EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude2EditFieldLabel.HorizontalAlignment = 'right';
            Longitude2EditFieldLabel.FontName = 'Cambria';
            Longitude2EditFieldLabel.Position = [187 262 67 22];
            Longitude2EditFieldLabel.Text = 'Longitude 2';

            % Create Longitude2EditField
            Longitude2EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude2EditField.FontName = 'Cambria';
            Longitude2EditField.Position = [269 262 67 22];
            Longitude2EditField.Value = 0;

            % Create Latitude3EditFieldLabel
            Latitude3EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude3EditFieldLabel.HorizontalAlignment = 'right';
            Latitude3EditFieldLabel.FontName = 'Cambria';
            Latitude3EditFieldLabel.Position = [31 232 57 22];
            Latitude3EditFieldLabel.Text = 'Latitude 3';

            % Create Latitude3EditField
            Latitude3EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude3EditField.FontName = 'Cambria';
            Latitude3EditField.Position = [103 232 67 22];
            Latitude3EditField.Value = 0;

            % Create Longitude3EditFieldLabel
            Longitude3EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude3EditFieldLabel.HorizontalAlignment = 'right';
            Longitude3EditFieldLabel.FontName = 'Cambria';
            Longitude3EditFieldLabel.Position = [187 232 67 22];
            Longitude3EditFieldLabel.Text = 'Longitude 3';

            % Create Longitude3EditField
            Longitude3EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude3EditField.FontName = 'Cambria';
            Longitude3EditField.Position = [269 232 67 22];
            Longitude3EditField.Value = 0;

            % Create Latitude4EditFieldLabel
            Latitude4EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude4EditFieldLabel.HorizontalAlignment = 'right';
            Latitude4EditFieldLabel.FontName = 'Cambria';
            Latitude4EditFieldLabel.Position = [31 200 57 22];
            Latitude4EditFieldLabel.Text = 'Latitude 4';

            % Create Latitude4EditField
            Latitude4EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude4EditField.FontName = 'Cambria';
            Latitude4EditField.Position = [103 200 67 22];
            Latitude4EditField.Value = 0;

            % Create Longitude4EditFieldLabel
            Longitude4EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude4EditFieldLabel.HorizontalAlignment = 'right';
            Longitude4EditFieldLabel.FontName = 'Cambria';
            Longitude4EditFieldLabel.Position = [187 200 67 22];
            Longitude4EditFieldLabel.Text = 'Longitude 4';

            % Create Longitude4EditField
            Longitude4EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude4EditField.FontName = 'Cambria';
            Longitude4EditField.Position = [269 200 67 22];
            Longitude4EditField.Value = 0;

            % Create Latitude5EditFieldLabel
            Latitude5EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude5EditFieldLabel.HorizontalAlignment = 'right';
            Latitude5EditFieldLabel.FontName = 'Cambria';
            Latitude5EditFieldLabel.Position = [31 170 57 22];
            Latitude5EditFieldLabel.Text = 'Latitude 5';

            % Create Latitude5EditField
            Latitude5EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude5EditField.FontName = 'Cambria';
            Latitude5EditField.Position = [103 170 67 22];
            Latitude5EditField.Value = 0;

            % Create Longitude5EditFieldLabel
            Longitude5EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude5EditFieldLabel.HorizontalAlignment = 'right';
            Longitude5EditFieldLabel.FontName = 'Cambria';
            Longitude5EditFieldLabel.Position = [187 170 67 22];
            Longitude5EditFieldLabel.Text = 'Longitude 5';

            % Create Longitude5EditField
            Longitude5EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude5EditField.FontName = 'Cambria';
            Longitude5EditField.Position = [269 170 67 22];
            Longitude5EditField.Value = 0;

            % Create Latitude6EditFieldLabel
            Latitude6EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Latitude6EditFieldLabel.HorizontalAlignment = 'right';
            Latitude6EditFieldLabel.FontName = 'Cambria';
            Latitude6EditFieldLabel.Position = [31 138 57 22];
            Latitude6EditFieldLabel.Text = 'Latitude 6';

            % Create Latitude6EditField
            Latitude6EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Latitude6EditField.FontName = 'Cambria';
            Latitude6EditField.Position = [103 138 67 22];
            Latitude6EditField.Value = 0;

            % Create Longitude6EditFieldLabel
            Longitude6EditFieldLabel = uilabel(TimeseriesGUIFigure);
            Longitude6EditFieldLabel.HorizontalAlignment = 'right';
            Longitude6EditFieldLabel.FontName = 'Cambria';
            Longitude6EditFieldLabel.Position = [187 138 67 22];
            Longitude6EditFieldLabel.Text = 'Longitude 6';

            % Create Longitude6EditField
            Longitude6EditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            Longitude6EditField.FontName = 'Cambria';
            Longitude6EditField.Position = [269 138 67 22];
            Longitude6EditField.Value = 0;

            % Create GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel = uilabel(TimeseriesGUIFigure);
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.FontName = 'Cambria';
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.FontAngle = 'italic';
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.Position = [119 35 412 22];
            GIVAGLACIERVELOCITYCALCULATIONTOOLBOXBYMAXVANWYKDEVRIESLabel.Text = 'GIV: A GLACIER VELOCITY CALCULATION TOOLBOX BY MAX VAN WYK DE VRIES';

            % Create WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel = uilabel(TimeseriesGUIFigure);
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontName = 'Cambria';
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontSize = 10;
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.FontAngle = 'italic';
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.Position = [178 9 295 22];
            WWWGIVGLACIERCOMCONTACTMEATVANWY048UMNEDULabel.Text = 'WWW.GIVGLACIER.COM --- CONTACT ME AT VANWY048@UMN.EDU ';

            % Create SizeofadditionalareaaveragedEditFieldLabel
            SizeofadditionalareaaveragedEditFieldLabel = uilabel(TimeseriesGUIFigure);
            SizeofadditionalareaaveragedEditFieldLabel.HorizontalAlignment = 'right';
            SizeofadditionalareaaveragedEditFieldLabel.FontName = 'Cambria';
            SizeofadditionalareaaveragedEditFieldLabel.Position = [360 338 167 22];
            SizeofadditionalareaaveragedEditFieldLabel.Text = 'Size of additional area averaged';

            % Create SizeofadditionalareaaveragedEditField
            SizeofadditionalareaaveragedEditField = uieditfield(TimeseriesGUIFigure, 'numeric');
            SizeofadditionalareaaveragedEditField.FontName = 'Cambria';
            SizeofadditionalareaaveragedEditField.Position = [542 338 67 22];
            SizeofadditionalareaaveragedEditField.Value = 3;

            % Create TimeseriesofrawdataSwitchLabel
            TimeseriesofrawdataSwitchLabel = uilabel(TimeseriesGUIFigure);
            TimeseriesofrawdataSwitchLabel.HorizontalAlignment = 'center';
            TimeseriesofrawdataSwitchLabel.FontName = 'Cambria';
            TimeseriesofrawdataSwitchLabel.Position = [411 270 131 22];
            TimeseriesofrawdataSwitchLabel.Text = 'Time-series of raw data?';

            % Create TimeseriesofrawdataSwitch
            TimeseriesofrawdataSwitch = uiswitch(TimeseriesGUIFigure, 'slider');
            TimeseriesofrawdataSwitch.Items = {'No', 'Yes'};
            TimeseriesofrawdataSwitch.FontName = 'Cambria';
            TimeseriesofrawdataSwitch.Position = [454 297 45 20];
            TimeseriesofrawdataSwitch.Value = 'Yes';

            % Create AlsosaveflowdirectionsSwitchLabel
            AlsosaveflowdirectionsSwitchLabel = uilabel(TimeseriesGUIFigure);
            AlsosaveflowdirectionsSwitchLabel.HorizontalAlignment = 'center';
            AlsosaveflowdirectionsSwitchLabel.FontName = 'Cambria';
            AlsosaveflowdirectionsSwitchLabel.Position = [408 117 137 22];
            AlsosaveflowdirectionsSwitchLabel.Text = 'Also save flow directions?';

            % Create AlsosaveflowdirectionsSwitch
            AlsosaveflowdirectionsSwitch = uiswitch(TimeseriesGUIFigure, 'slider');
            AlsosaveflowdirectionsSwitch.Items = {'No', 'Yes'};
            AlsosaveflowdirectionsSwitch.FontName = 'Cambria';
            AlsosaveflowdirectionsSwitch.Position = [454 149 45 20];
            AlsosaveflowdirectionsSwitch.Value = 'Yes';

            % Create TimeseriesofmonthlydataSwitchLabel
            TimeseriesofmonthlydataSwitchLabel = uilabel(TimeseriesGUIFigure);
            TimeseriesofmonthlydataSwitchLabel.HorizontalAlignment = 'center';
            TimeseriesofmonthlydataSwitchLabel.FontName = 'Cambria';
            TimeseriesofmonthlydataSwitchLabel.Position = [400 191 154 22];
            TimeseriesofmonthlydataSwitchLabel.Text = 'Time-series of monthly data?';

            % Create TimeseriesofmonthlydataSwitch
            TimeseriesofmonthlydataSwitch = uiswitch(TimeseriesGUIFigure, 'slider');
            TimeseriesofmonthlydataSwitch.Items = {'No', 'Yes'};
            TimeseriesofmonthlydataSwitch.FontName = 'Cambria';
            TimeseriesofmonthlydataSwitch.Position = [454 219 45 20];
            TimeseriesofmonthlydataSwitch.Value = 'Yes';

            % Create CalculateDataTimeseriesLabel
            CalculateDataTimeseriesLabel = uilabel(TimeseriesGUIFigure);
            CalculateDataTimeseriesLabel.FontName = 'Cambria';
            CalculateDataTimeseriesLabel.FontSize = 15;
            CalculateDataTimeseriesLabel.FontWeight = 'bold';
            CalculateDataTimeseriesLabel.Position = [233 389 184 22];
            CalculateDataTimeseriesLabel.Text = 'Calculate Data Timeseries';

            % Create LatitudeLongitudeinputLabel
            LatitudeLongitudeinputLabel = uilabel(TimeseriesGUIFigure);
            LatitudeLongitudeinputLabel.FontName = 'Cambria';
            LatitudeLongitudeinputLabel.FontWeight = 'bold';
            LatitudeLongitudeinputLabel.Position = [144 341 144 22];
            LatitudeLongitudeinputLabel.Text = 'Latitude-Longitude input';
            
            
            % Create ExtractTimeSeriesButton
            ExtractTimeSeriesButton = uibutton(TimeseriesGUIFigure, 'push');
            ExtractTimeSeriesButton.BackgroundColor = [0.302 0.7451 0.9333];
            ExtractTimeSeriesButton.FontName = 'Cambria';
            ExtractTimeSeriesButton.FontSize = 15;
            ExtractTimeSeriesButton.FontWeight = 'bold';
            ExtractTimeSeriesButton.Position = [215 68 221 27];
            ExtractTimeSeriesButton.Text = 'Extract Time Series';
            ExtractTimeSeriesButton.ButtonPushedFcn = @(btn,event) plotButtonPushed (btn);
            

            % Show the figure after all components are created
            TimeseriesGUIFigure.Visible = 'on';


            function [btn,event]= plotButtonPushed(btn)
                
            vtplotinputs= {};

            vtplotinputs{1,1} = 'array with different lat longs inputted by user';

            vtplotinputs{1,2} = [Latitude1EditField.Value,Longitude1EditField.Value;Latitude2EditField.Value,Longitude2EditField.Value;...
                Latitude3EditField.Value,Longitude3EditField.Value;Latitude4EditField.Value,Longitude4EditField.Value;...
                Latitude5EditField.Value,Longitude5EditField.Value;Latitude6EditField.Value,Longitude6EditField.Value];

            vtplotinputs{2,1} = 'size of padding';

            vtplotinputs{2,2} = SizeofadditionalareaaveragedEditField.Value;

            vtplotinputs{3,1} = 'Yes or no for calculate for raw data';

            vtplotinputs{3,2} = TimeseriesofrawdataSwitch.Value;

            vtplotinputs{4,1} = 'Yes or no for calculate for monthly data';

            vtplotinputs{4,2} = TimeseriesofmonthlydataSwitch.Value;

            vtplotinputs{5,1} = 'flow direction as well as velocity?';

            vtplotinputs{5,2} = AlsosaveflowdirectionsSwitch.Value;                

            velocitytimeplot(vtplotinputs);

            end
                        
            end
