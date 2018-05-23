% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI                                               %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function miep
%main function that constructs the GUI an envelopes the nested function
%for GUI behaviour


%% generate and display GUI
%determine figure position from screen size
screenSize = get(0, 'ScreenSize');
screenRatio = 0.75; %screen filling ratio
figPos(1) = (1-screenRatio)/2*screenSize(3); %position left
figPos(2) = (1-screenRatio)/2*screenSize(4); %position bottom
figPos(3) = screenRatio*screenSize(3); %width
figPos(4) = screenRatio*screenSize(4); %height

%open figure
fig = figure('Position', figPos, 'Resize', 'off', 'WindowStyle', 'normal', ...
    'DockControls', 'off', 'MenuBar', 'none', 'ToolBar', 'none', ...
    'NumberTitle', 'off', 'Name', 'MIEP');

%add toolbar to figure
tBar = uitoolbar(fig);

%load help icon and add to toolbar
icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', ...
    'help_ex.png'), 'Background', fig.Color);
[img, map] = rgb2ind(icon, 65535);
iconHelp = ind2rgb(img, map);
uipushtool(tBar, 'CData', iconHelp, 'TooltipString', 'Info', 'ClickedCallback', @tBarInfo_push)


%% GUI callback functions

    function tBarInfo_push(~, ~, ~)
        %toolbar info button function
        msgbox({'MIEP','MAXYMUS Image Evaluation Program','Max Planck Institute for Intelligent Systems','Joachim Gräfe'}, ...
            'MIEP', 'help')
    end
end