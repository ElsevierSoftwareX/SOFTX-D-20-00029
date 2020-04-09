% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Settings Dialog                               %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showSettings(obj, ~, ~, ~)
%show settings dialog

%determine figure position from screen size
screenSize = get(0, 'ScreenSize');
figSize = [400 230]; %figure width height
figPos(1) = screenSize(3)/2-figSize(1)/2; %position left
figPos(2) = screenSize(4)/2-figSize(2)/2; %position bottom
figPos(3) = figSize(1); %width
figPos(4) = figSize(2); %height

%open figure
settingsDialog = dialog('Position', figPos, 'Resize', 'off', 'WindowStyle', 'modal', ...
    'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
    'NumberTitle', 'off', 'Name', 'MIEP - Settings');

%OK/Cancel buttons
butPos(3) = 50; %width
butPos(4) = 20; %height
butPos(1) = figSize(1)/2 - butPos(3) - 2.5; %position left
butPos(2) = 5; %position bottom
uicontrol('Style', 'pushbutton', 'String', 'OK', 'Position', butPos, 'Callback', @butOK);
butPos(1) = figSize(1)/2 + 2.5;
uicontrol('Style', 'pushbutton', 'String', 'Cancel', 'Position', butPos, 'Callback', @butCancel);

%load folder icon
icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'file_open.png'), 'Background', settingsDialog.Color);
[img, map] = rgb2ind(icon, 65535);
iconLoad = ind2rgb(img, map);

%output folder
curPos(1) = 5;
curPos(2) = butPos(2) + butPos(4) + 5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Export Folder:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 20 - 4*5;
outputFolder = uicontrol('Style', 'edit', 'String', obj.settings.outputFolder, 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = 20;
uicontrol('Style', 'pushbutton', 'Position', curPos, 'CData', iconLoad, 'Callback', @openOutputFolder);

%measurement master/miep file
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Measurement List File:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 20 - 4*5;
miepFile = uicontrol('Style', 'edit', 'String', obj.settings.miepFile, 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = 20;
uicontrol('Style', 'pushbutton', 'Position', curPos, 'CData', iconLoad, 'Callback', @openMiepFile);

%data folder
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Evaluation Data Folder:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 20 - 4*5;
dataFolder = uicontrol('Style', 'edit', 'String', obj.settings.dataFolder, 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = 20;
uicontrol('Style', 'pushbutton', 'Position', curPos, 'CData', iconLoad, 'Callback', @openDataFolder);

%input folder
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'SXM Data Folder:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 20 - 4*5;
inputFolder = uicontrol('Style', 'edit', 'String', obj.settings.inputFolder, 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = 20;
uicontrol('Style', 'pushbutton', 'Position', curPos, 'CData', iconLoad, 'Callback', @openInputFolder);

%k-space color map
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'k-Space Color Map:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 3*5;
kSpaceColorMap = uicontrol('Style', 'popupmenu', 'String', obj.settings.colorMaps, 'Value', obj.settings.kSpaceColorMap, 'Position', curPos);

%movie color map
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Movie Color Map:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 3*5;
movieColorMap = uicontrol('Style', 'popupmenu', 'String', obj.settings.colorMaps, 'Value', obj.settings.movieColorMap, 'Position', curPos);

%image color map
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Image Color Map:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 3*5;
imageColorMap = uicontrol('Style', 'popupmenu', 'String', obj.settings.colorMaps, 'Value', obj.settings.imageColorMap, 'Position', curPos);

%frame rate
curPos(1) = 5;
curPos(2) = curPos(2) + curPos(4) +5;
curPos(3) = 120;
curPos(4) = 20;
uicontrol('Style', 'text', 'String', 'Movie Frame Rate:', 'Position', curPos, 'HorizontalAlignment', 'left');
curPos(1) = curPos(1) + curPos(3) + 5;
curPos(3) = figSize(1) - 120 - 3*5;
frameRate = uicontrol('Style', 'slider', 'Min', 1, 'Max', 30, 'SliderStep', [1/29 1/29], 'Value', obj.settings.frameRate, 'Position', curPos);

%GUI Settings Dialog 'Callback'functions
    function butOK(~, ~, ~)
        %OK Button
        %save settings
        obj.settings.inputFolder = inputFolder.String;
        obj.settings.miepFile = miepFile.String;
        obj.settings.dataFolder = dataFolder.String;
        obj.settings.outputFolder = outputFolder.String;
        obj.settings.imageColorMap = imageColorMap.Value;
        obj.settings.movieColorMap = movieColorMap.Value;
        obj.settings.kSpaceColorMap = kSpaceColorMap.Value;
        obj.settings.frameRate = round(frameRate.Value);
        %close dialog
        delete(settingsDialog)
        %update display
        obj.displayData
    end
    function butCancel(~, ~, ~)
        %Cancel Button
        %close dialog
        delete(settingsDialog)
    end

    function openInputFolder(~, ~, ~)
        %open input folder
        if isempty(inputFolder.String)
            curFolder = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'));
        else
            curFolder = inputFolder.String;
        end
        curFolder = uigetdir(curFolder, 'Open SXM Data Folder');
        if curFolder ~= 0
            inputFolder.String = curFolder;
        end
    end
    function openDataFolder(~, ~, ~)
        %open data folder
        if isempty(dataFolder.String)
            curFolder = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'));
        else
            curFolder = dataFolder.String;
        end
        curFolder = uigetdir(curFolder, 'Open Evaluation Data Folder');
        if curFolder ~= 0
            dataFolder.String = curFolder;
        end
    end
    function openOutputFolder(~, ~, ~)
        %open output folder
        if isempty(outputFolder.String)
            curFolder = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'));
        else
            curFolder = outputFolder.String;
        end
        curFolder = uigetdir(curFolder, 'Open Export Folder');
        if curFolder ~= 0
            outputFolder.String = curFolder;
        end
    end
    function openMiepFile(~, ~, ~)
        %open miep file
        if isempty(miepFile.String)
            curFile = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'),'miep.xlsx');
        else
            curFile = miepFile.String;
        end
        [curFile, curFolder] = uiputfile('*.xlsx', 'Open Measurement List File', curFile);
        if curFile ~= 0
            miepFile.String = fullfile(curFolder, curFile);
        end
    end
end