% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Image Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imageTab(obj, miepGUIObj)
%% intialize / draws the image tab
%determine drawing area
drawingArea = obj.tabHandle.Position;
drawingArea = drawingArea - [0 0 5 30]; %correct MATLAB madness?

%draw energy selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.energyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Energy ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
energies = miepGUIObj.workData.energies;
obj.uiHandles.energyList.String = energies;
if max(size(energies)) == 1
    obj.uiHandles.energyList.Enable = 'off';
end

%draw channel selector list
Pos(1) = drawingArea(3)/2 + 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.channelList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Channel ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
channels = miepGUIObj.workData.channels;
obj.uiHandles.channelList.String = channels;
if max(size(channels)) == 1
    obj.uiHandles.channelList.Enable = 'off';
end

%draw image axes and image
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height

xLabel = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Name;
xUnit = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Unit;
xMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Min;
xMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Max;
xPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Points;
xStep = (xMax - xMin) / xPoints;
xTicks = 10;
yLabel = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Name;
yUnit = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Unit;
yMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Min;
yMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Max;
yPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Points;
yStep = (yMax - yMin) / yPoints;
yTicks = 10;

obj.uiHandles.imageAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.imageAxes.Color = obj.tabHandle.BackgroundColor;
obj.uiHandles.imageAxes.Box = 'on';
obj.uiHandles.imageAxes.XLim = [0 xPoints+1];
obj.uiHandles.imageAxes.YLim = [0 yPoints+1];
obj.uiHandles.imageAxes.DataAspectRatio = [1 1 1];
obj.uiHandles.imageAxes.TickDir = 'out';
obj.uiHandles.imageAxes.XTick = 1:(xPoints-1)/xTicks:xPoints;
obj.uiHandles.imageAxes.XTickLabel = {0:xPoints*xStep/xTicks:xPoints*xStep};
obj.uiHandles.imageAxes.YTick = 1:(yPoints-1)/yTicks:yPoints;
obj.uiHandles.imageAxes.YTickLabel = {0:yPoints*yStep/yTicks:yPoints*yStep};
obj.uiHandles.imageAxes.XLabel.String = [xLabel ' [' xUnit ']'];
obj.uiHandles.imageAxes.YLabel.String = [yLabel ' [' yUnit ']'];

obj.uiHandles.image = image(obj.uiHandles.imageAxes);
obj.uiHandles.image.CDataMapping = 'scaled';

%draw image on first energy/channel
imageDraw(1,1);
obj.tabData.workEnergy = 1; %use tabData to store current energy
obj.tabData.workChannel = 1; %use tabData to store current channel

%% interactive behaviour of tab / callbacks
    function imageSelect(~, ~, ~)
        %update image after selection
        try
            energy = obj.uiHandles.energyList.Value;
            channel = obj.uiHandles.channelList. Value;
            imageDraw(energy, channel)
            obj.tabData.workEnergy = energy;
            obj.tabData.workChannel = channel;
        catch
            %revert to previous selection on error
            obj.uiHandles.energyList.Value = obj.tabData.workEnergy;
            obj.uiHandles.channelList.Value = obj.tabData.workChannel;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end  
    end

%% support functions
    function imageDraw(energy, channel)
        region = miepGUIObj.workRegion;
        data = miepGUIObj.workData.data(channel, energy, region);
        obj.uiHandles.image.CData = data;
    end
end