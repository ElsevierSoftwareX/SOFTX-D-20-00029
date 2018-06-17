% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI                                               %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed) miepgui < handle
    %the miep gui class is sealed
    
    properties
        fig = []; %figure handle
        tBar = []; %toolbar handle
        fileList = []; %file listbox handle
        tabGroup = []; %result tab group handle
        tabs = struct(); %stores individual tab handles
        tabHandles = struct(); %stores handles on individual tabs
        regionList = []; %region list handle
        energyList = []; %energy list handle
        comment = []; %comment box handle
    end
    
    properties (Access = private)
        workFolder = []; %stores current work folder
        workFile = []; %stores current work file
        workData = []; %holds current sxmdata
    end
    
    %dependent properties and respective get/set methods
    properties (Dependent)
        settings; %settings are stored in settings.mat
        miepFile; %wrapper for XLSX list of measurements
    end
    methods
        function settings = get.settings(~)
            if(~exist('settings.mat','file'))
                settings = miepsettings;
                save('settings.mat', 'settings')
            else
                input = load('settings.mat', 'settings');
                settings = input.settings;
            end
        end
        function set.settings(~, settings)
            if isa(settings, 'miepsettings')
                save('settings.mat', 'settings')
            end
        end
        function miepFile = get.miepFile(obj)
            miepFile = miepfile(obj.settings.miepFile);
        end
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepgui
            %main function that generates the GUI
            
            %determine figure position from screen size
            screenSize = get(0, 'ScreenSize');
            screenRatio = 0.75; %screen filling ratio
            figPos(1) = (1-screenRatio)/2*screenSize(3); %position left
            figPos(2) = (1-screenRatio)/2*screenSize(4); %position bottom
            figPos(3) = screenRatio*screenSize(3); %width
            figPos(4) = screenRatio*screenSize(4); %height
            
            %open figure
            obj.fig = figure('Position', figPos, 'Resize', 'off', 'WindowStyle', 'normal', ...
                'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
                'NumberTitle', 'off', 'Name', 'MIEP');
            
            %add menubar to figure
            menuFile = uimenu(obj.fig, 'Text', 'File');
            uimenu(menuFile, 'Text', 'Settings', 'MenuSelectedFcn', @obj.showSettings);
            uimenu(menuFile, 'Text', 'Close', 'MenuSelectedFcn', @obj.guiFileClose, 'Accelerator', 'X');
            menuHelp = uimenu(obj.fig, 'Text', '?');
            uimenu(menuHelp, 'Text', 'Info', 'MenuSelectedFcn', @obj.guiHelpInfo);
            
            %add toolbar to figure
            obj.tBar = uitoolbar(obj.fig);
            
            %load folder icon and add to toolbar
            icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'file_open.png'), 'Background', obj.fig.Color);
            [img, map] = rgb2ind(icon, 65535);
            iconLoad = ind2rgb(img, map);
            uipushtool(obj.tBar, 'CData', iconLoad, 'TooltipString', 'Load Folder', 'ClickedCallback', @obj.guiLoadFolder);
            
            %load refresh icon and add to toolbar
            icon = imread(fullfile(matlabroot, 'toolbox', 'physmod', 'common', 'dataservices', 'resources', 'icons', 'refresh.png'), 'Background', obj.fig.Color);
            [img, map] = rgb2ind(icon, 65535);
            iconLoad = ind2rgb(img, map);
            uipushtool(obj.tBar, 'CData', iconLoad, 'TooltipString', 'Refresh Folder', 'ClickedCallback', @obj.guiRefreshFolder);
            
            %load help icon and add to toolbar
            icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'help_ex.png'), 'Background', obj.fig.Color);
            [img, map] = rgb2ind(icon, 65535);
            iconHelp = ind2rgb(img, map);
            uipushtool(obj.tBar, 'CData', iconHelp, 'TooltipString', 'Info', 'ClickedCallback', @obj.guiHelpInfo);
            
            %determine figure drawing area
            drawingArea = obj.fig.InnerPosition;
            
            %draw file selector list
            Pos(1) = 5; %position left
            Pos(2) = 5; % position bottom
            Pos(3) = drawingArea(3)*1/4 - 2*5; %width
            Pos(4) = drawingArea(4) - 2*5; %height
            obj.fileList = uicontrol(obj.fig, 'Style', 'listbox', 'Units', 'pixels', 'Position', Pos, 'Callback', @obj.guiLoadFile);
            
            %draw comment box
            Pos(1) = drawingArea(3)/4; %position left
            Pos(2) = 5; % position bottom
            Pos(3) = drawingArea(3)*3/4; %width
            Pos(4) = 60; %height
            obj.comment = uicontrol(obj.fig, 'Style', 'edit', 'Units', 'pixels', 'Position', Pos);
            obj.comment.HorizontalAlignment = 'left';
            obj.comment.Max = 3;
            
            %draw results display tabgroup
            Pos(1) = drawingArea(3)/4; %position left
            Pos(2) = 60 + 2*5; % position bottom
            Pos(3) = drawingArea(3)*3/4; %width
            Pos(4) = drawingArea(4) - 20 - 60 - 4*5; %height
            obj.tabGroup = uitabgroup(obj.fig, 'Units', 'pixels', 'Position', Pos);
            uitab(obj.tabGroup, 'Title', 'MIEP');
            
            %draw region selector list
            Pos(1) = drawingArea(3)/4; %position left
            Pos(2) = drawingArea(4) - 20 - 5; % position bottom
            Pos(3) = drawingArea(3)*3/8 - 1*5; %width
            Pos(4) = 20; %height
            obj.regionList = uicontrol(obj.fig, 'Style', 'popupmenu', 'Units', 'pixels', 'Position', Pos);
            obj.regionList.String = 'Select Region ...';
            
            %draw energy selector list
            Pos(1) = drawingArea(3)*5/8; %position left
            Pos(2) = drawingArea(4) - 20 - 5; % position bottom
            Pos(3) = drawingArea(3)*3/8 - 1*5; %width
            Pos(4) = 20; %height
            obj.energyList = uicontrol(obj.fig, 'Style', 'popupmenu', 'Units', 'pixels', 'Position', Pos);
            obj.energyList.String = 'Select Energy ...';
            
            %load work folder from settings
            obj.workFolder = obj.settings.inputFolder;
        end
        
        function saveFile(obj)
            %save current sxmdata file
            dataPath = fullfile(obj.settings.dataFolder, strcat(obj.workFile, '.miep'));
            data = obj.workData;
            save(dataPath, 'data')
        end
        
        function displayData(obj)
            %display data
            
            %clear current tabs
            delete(obj.tabGroup.Children)
            obj.tabs = struct();
            obj.tabHandles = struct();
            
            %determine if specturm or image
            if strcmp(obj.workData.header.Flags, 'Spectra')
                obj.tabs.spectrum = uitab(obj.tabGroup, 'Title', 'Spectrum');
                obj.tabHandles.spectrumAxes = axes(obj.tabs.spectrum, 'OuterPosition', obj.tabs.spectrum.InnerPosition);
                plot(obj.tabHandles.spectrumAxes, obj.workData.dataStore.Energy, obj.workData.data)
                obj.tabHandles.spectrumAxes.XLabel.String = 'Energy [eV]';
                obj.tabHandles.spectrumAxes.YLabel.String = 'Intensity [counts]';
                obj.tabHandles.spectrumAxes.TickDir = 'out';
            else
                obj.tabs.image = uitab(obj.tabGroup, 'Title', 'Image');
                obj.tabHandles.imageAxes = axes(obj.tabs.image, 'OuterPosition', obj.tabs.image.InnerPosition);
                imagesc(obj.tabHandles.imageAxes, obj.workData.data)
                obj.tabHandles.imageAxes.TickDir = 'out';
                xMin = obj.workData.header.Regions.PAxis.Min;
                xMax = obj.workData.header.Regions.PAxis.Max;
                yMin = obj.workData.header.Regions.QAxis.Min;
                yMax = obj.workData.header.Regions.QAxis.Max;
                obj.tabHandles.imageAxes.XTickLabel = {xMin:(xMax-xMin)/10:xMax};
                obj.tabHandles.imageAxes.YTickLabel = {yMin:(yMax-yMin)/10:yMax};
            end
        end
        
        showSettings(obj, ~, ~, ~) %show settings dialog
    end
    
    methods (Access = private)
        %private methods
        %GUI behaviour functions
        
        function guiHelpInfo(~, ~, ~)
            %help info function
            msgbox({'MIEP - MAXYMUS Image Evaluation Program','Max Planck Institute for Intelligent Systems','Joachim Gräfe, Nick-André Träger'}, ...
                'MIEP', 'help')
        end
        
        function guiFileClose(obj, ~, ~)
            %file close function
            delete(obj.fig)
        end
        
        function guiLoadFolder(obj, ~, ~)
            %determine current directory
            if isempty(obj.workFolder)
                curFolder = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'));
            else
                curFolder = obj.workFolder;
            end
            %ask for folder to load
            curFolder = uigetdir(curFolder, 'Open SXM Data Folder');
            %exit function if uigetdir dialog was canceld
            if curFolder == 0
                return
            end
            %write new folder to object
            obj.workFolder = curFolder;
            %actually load folder
            obj.loadFolder
            %load first file from list
            obj.fileList.Value = 1;
            obj.workFile = obj.fileList.String{1};
            obj.loadFile
        end
        
        function guiRefreshFolder(obj, ~, ~)
            %refresh folder
            obj.loadFolder
            obj.workFile = obj.fileList.String{obj.fileList.Value};
            obj.loadFile
        end
        
        function guiLoadFile(obj, ~, ~)
            %save previous file
            obj.saveFile
            %determine selected file
            obj.workFile = obj.fileList.String{obj.fileList.Value};
            obj.loadFile
            %focus back on gui list
            uicontrol(obj.fileList)
        end
    end
end