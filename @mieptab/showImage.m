% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Draws a tab to show images                             %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showImage(obj, miepGUIObj)

%determine drawing area
drawingArea = obj.tabHandle.Position;
drawingArea = drawingArea - [0 0 5 30]; %correct MATLAB madness?

%draw energy selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.energyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Energy ...', 'Units', 'pixels', 'Position', Pos);
numEnergies = miepGUIObj.workData.header.StackAxis.Points;
energies = cell(numEnergies, 1);
for i=1:numEnergies
    energies{i} = [num2str(miepGUIObj.workData.header.StackAxis.Axis(i)), ' ', miepGUIObj.workData.header.StackAxis.Unit];
end
obj.uiHandles.energyList.String = energies;
if numEnergies == 1
    obj.uiHandles.energyList.Enable = 'off';
end

%draw channel selector list
Pos(1) = drawingArea(3)/2 + 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.channelList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Channel ...', 'Units', 'pixels', 'Position', Pos);
channels = miepGUIObj.workData.channels;
obj.uiHandles.channelList.String = channels;
if max(size(channels)) == 1
    obj.uiHandles.channelList.Enable = 'off';
end


%draw image axes
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height
obj.uiHandles.imageAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.imageAxes.TickDir = 'out';
xMin = miepGUIObj.workData.header.Regions.PAxis.Min;
xMax = miepGUIObj.workData.header.Regions.PAxis.Max;
yMin = miepGUIObj.workData.header.Regions.QAxis.Min;
yMax = miepGUIObj.workData.header.Regions.QAxis.Max;
obj.uiHandles.imageAxes.XTickLabel = {xMin:(xMax-xMin)/10:xMax};
obj.uiHandles.imageAxes.YTickLabel = {yMin:(yMax-yMin)/10:yMax};

%draw image
imagesc(obj.uiHandles.imageAxes, miepGUIObj.workData.data)
end