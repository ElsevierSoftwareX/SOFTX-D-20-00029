% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Image Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function welcomeTab(obj, miepGUIObj)
%% intialize / draws the image tab
%determine drawing area
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?


%draw image axes and image
Pos(1) = -150; %position left
Pos(2) = -85; % position bottom
Pos(3) = drawingArea(3) - 2*5 + 250; %width
Pos(4) = drawingArea(4) - 3*5 - 20 + 150; %height

obj.uiHandles.welcomeAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos, 'visible', 'off');
obj.uiHandles.welcomeAxes.Color = obj.tabHandle.BackgroundColor;

imagesc(obj.uiHandles.welcomeAxes, miepGUIObj.miepIcons.welcome);
obj.uiHandles.welcomeAxes.XTick = [];
obj.uiHandles.welcomeAxes.YTick = [];

obj.uiHandles.welcomeAxes.XColor = obj.tabHandle.BackgroundColor;
obj.uiHandles.welcomeAxes.YColor = obj.tabHandle.BackgroundColor;

end











