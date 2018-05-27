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
        regionList = []; %region list handle
        energyList = []; %energy list handle
        comment = []; %comment box handle
    end
    
    properties (Access = private)
        workFolder = []; %stores current work folder
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
            uimenu(menuFile, 'Text', 'Close', 'MenuSelectedFcn', @obj.guiFileClose, 'Accelerator', 'X');
            menuHelp = uimenu(obj.fig, 'Text', '?');
            uimenu(menuHelp, 'Text', 'Info', 'MenuSelectedFcn', @obj.guiHelpInfo);
            
            %add toolbar to figure
            obj.tBar = uitoolbar(obj.fig);
            
            %load folder icon and add to toolbar
            icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', ...
                'file_open.png'), 'Background', obj.fig.Color);
            [img, map] = rgb2ind(icon, 65535);
            iconLoad = ind2rgb(img, map);
            uipushtool(obj.tBar, 'CData', iconLoad, 'TooltipString', 'Load Folder', 'ClickedCallback', @obj.loadFolder);
            
            %load help icon and add to toolbar
            icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', ...
                'help_ex.png'), 'Background', obj.fig.Color);
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
            obj.fileList = uicontrol(obj.fig, 'Style', 'listbox', 'Units', 'pixels', 'Position', Pos);
            
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
            uitab(obj.tabGroup, 'Title', 'Dööfe');
            uitab(obj.tabGroup, 'Title', 'MegaDoof');
            
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
        end
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
        
        loadFolder(obj, ~, ~, ~) %load data folder
    end
end