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
        menu = [] %menu handle
        fileList = []; %file listbox handle
        tabGroup = []; %tab group handle
        tabs = struct(); %stores individual miep tab handles
        regionList = []; %region list handle
        comment = []; %comment box handle
    end
    
    %read only properties and respective get/set methods
    properties (SetAccess = private)
        workFolder = []; %stores current work folder
        workFile = []; %stores current work file
        workData = []; %stores current sxmdata
        workRegion = []; %stores current region
        workTab = []; %stores selected tab
        miepFile = []; %wrapper for XLSX list of measurements
        miepIcons = []; %access to GUI icons
    end
    methods
        function miepFile = get.miepFile(obj)
            %check if miepfile has not been initialized get name from
            %settings
            if isempty(obj.miepFile)
                obj.miepFile = miepfile(obj.settings.miepFile);
            end
            miepFile = obj.miepFile;
        end
        
        function set.workTab(obj, tabType)
            obj.tabGroup.SelectedTab = obj.tabs.(tabType).tabHandle;
        end
    end
    
    %dependent properties and respective get/set methods
    properties (Dependent)
        settings; %settings are stored in settings.mat
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
                'NumberTitle', 'off', 'Name', 'MIEP', 'CloseRequestFcn', @obj.guiFileClose);
            
            %init icons
            obj.miepIcons = miepicons(obj.fig.Color);
            
            %add menubar to figure
            obj.menu = uimenu(obj.fig, 'Text', 'File');
            uimenu(obj.menu, 'Text', 'Settings', 'MenuSelectedFcn', @obj.showSettings);
            exportMenuFile = uimenu(obj.menu, 'Text', 'Export to...');
            uimenu(exportMenuFile, 'Text', 'POV-Ray', 'MenuSelectedFcn', @obj.export2pov, 'Accelerator', 'E', 'Enable', 'off');
            uimenu(exportMenuFile, 'Text', 'CSV', 'MenuSelectedFcn', @obj.writeCSV, 'Accelerator', 'D', 'Enable', 'off');
            
            uimenu(obj.menu, 'Text', 'Close', 'MenuSelectedFcn', @obj.guiFileClose, 'Accelerator', 'X');
            
            menuHelp = uimenu(obj.fig, 'Text', '?');
            uimenu(menuHelp, 'Text', 'Info', 'MenuSelectedFcn', @obj.guiHelpInfo);
            
            %add toolbar to figure
            obj.tBar = uitoolbar(obj.fig);
            
            %load folder icon and add to toolbar
            uipushtool(obj.tBar, 'CData', obj.miepIcons.file_open, 'TooltipString', 'Load Folder', 'ClickedCallback', @obj.guiLoadFolder);
            
            %load refresh icon and add to toolbar
            uipushtool(obj.tBar, 'CData', obj.miepIcons.refresh, 'TooltipString', 'Refresh Folder', 'ClickedCallback', @obj.guiRefreshFolder);
            
            %load help icon and add to toolbar
            uipushtool(obj.tBar, 'CData', obj.miepIcons.help_ex, 'TooltipString', 'Info', 'ClickedCallback', @obj.guiHelpInfo);
            
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
            obj.comment = uicontrol(obj.fig, 'Style', 'edit', 'Units', 'pixels', 'Position', Pos, 'Callback', @obj.guiSave);
            obj.comment.HorizontalAlignment = 'left';
            obj.comment.Max = 3; %multi line would be nice, but comment update doesn't work
            obj.comment.Max = 1;
            
            %draw results display tabgroup
            Pos(1) = drawingArea(3)/4; %position left
            Pos(2) = 60 + 2*5; % position bottom
            Pos(3) = drawingArea(3)*3/4; %width
            Pos(4) = drawingArea(4) - 20 - 60 - 4*5; %height
            obj.tabGroup = uitabgroup(obj.fig, 'Units', 'pixels', 'Position', Pos);
            mieptab(obj, 'miep');
            
            %draw region selector list
            Pos(1) = drawingArea(3)/4; %position left
            Pos(2) = drawingArea(4) - 20 - 5; % position bottom
            Pos(3) = drawingArea(3)*3/4 - 5; %width
            Pos(4) = 20; %height
            obj.regionList = uicontrol(obj.fig, 'Style', 'popupmenu', 'Units', 'pixels', 'Position', Pos, 'Callback', @obj.updateRegion);
            obj.regionList.String = 'Select Region ...';
            
            %load work folder from settings
            obj.workFolder = obj.settings.inputFolder;
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
            delete(obj)
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
            %close old tabs
            obj.closeTabs
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
            %If no File is loaded yet, return to avoid errors
            if isempty(obj.fileList.String)
                return
            end
            %close old tabs to avoid error in timer function
            obj.closeTabs
            %save previous file, comments and Magic Number
            obj.guiSave
            obj.saveFile
            %determine selected file
            obj.workFile = obj.fileList.String{obj.fileList.Value};
            obj.loadFile
            %focus back on gui list
            uicontrol(obj.fileList)
        end
        
        function guiSave(obj, ~, ~)
            %write comment to miep file after change
            miepDate = obj.workFile(5:10);
            miepNumber = str2double(obj.workFile(11:13));
            miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);
            miepEntry.Comment = obj.comment.String;
            miepEntry.MagicNumber = obj.workData.magicNumber;
            obj.miepFile.writeEntry(miepDate, miepEntry)
        end
        
        function export2pov(obj, ~, ~)
            %export fft movie to POV-Ray function
            export2pov(obj.workData, obj.tabs.movie.uiHandles.frequencyList.Value, obj.settings.outputFolder)
        end
        
        function writeCSV(obj, ~, ~)
            %export data to csv format
            writeCSV(obj.workData, obj.settings.outputFolder)
        end
        
        function updateRegion(obj, ~, ~)
            %get work region from selector and update tabs
            obj.workRegion = obj.regionList.Value;
            obj.displayTabs
        end
    end
    
    methods (Access = private)
        %private methods
        %GUI helper functions
        
        function displayData(obj)
            %close old tabs to avoid error in timer function
            obj.closeTabs
            
            if isempty(obj.workFile)
                %if no file is loaded show startup tab
                mieptab(obj, 'miep');
            else
                %display comment
                miepDate = obj.workFile(5:10);
                miepNumber = str2double(obj.workFile(11:13));
                miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);
                obj.comment.String = miepEntry.Comment;
                
                %display region list
                try
                    numRegions = size(obj.workData.header.Regions,2);
                catch
                    numRegions = 1;
                end
                if numRegions == 1
                    obj.regionList.String = 'Region 1';
                    obj.regionList.Enable = 'off';
                else
                    newList = cell(numRegions,1);
                    for i = 1:numRegions
                        newList{i} = ['Region ', num2str(i)];
                    end
                    obj.regionList.String = newList;
                    obj.regionList.Enable = 'on';
                end
                obj.workRegion = 1;
                
                %display Tabs and update export menu
                obj.displayTabs
                obj.updateExportMenu
            end
        end
        
        function closeTabs(obj)
            %clear current tabs
            curTabs = fields(obj.tabs);
            for i=1:size(curTabs, 1)
                delete(obj.tabs.(curTabs{i}))
            end
        end
        
        function displayTabs(obj)
            %display tabs
            %determine if specturm or image
            if ~isempty(strfind(obj.workData.header.Flags, 'Spectra'))
                mieptab(obj, 'spectrum');
                obj.workTab = 'spectrum';
            else
                mieptab(obj, 'image');
                obj.workTab = 'image';
                if strcmp(obj.workData.channels{end}, 'BBX')
                    mieptab(obj, 'movie');
                    mieptab(obj, 'fft');
                    mieptab(obj, 'kspace');
                    obj.workTab = 'movie';
                end
            end
        end
        
        function updateExportMenu(obj)
            %update available exports depending on settings
            %Turn off all export menues
            exportMenu = findobj(obj.menu.Children, 'Text', 'Export to...');
            exportOptions = exportMenu.Children;
            for i = 1:length(exportOptions)
                exportOptions(i).Enable = 'off';
            end
            
            %always on menus
            csvMenu = findobj(obj.menu.Children, 'Text', 'CSV');
            csvMenu.Enable = 'on';
            
            %determine if specturm or image
            if ~isempty(strfind(obj.workData.header.Flags, 'Spectra'))
            else
                %check for bbx
                if strcmp(obj.workData.channels{end}, 'BBX')
                    %enable POV-Ray export for Movie
                    povMenu = findobj(obj.menu.Children, 'Text', 'POV-Ray');
                    povMenu.Enable = 'on';
                end
            end
        end
        
        
    end
end