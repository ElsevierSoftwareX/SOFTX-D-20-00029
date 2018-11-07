% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Image Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function kSpaceTab(obj, miepGUIObj)
%% intialize / draws the image tab
%determine drawing area
drawingArea = obj.tabHandle.Position;

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

%draw image axes and image
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height

xLabel = 'k_{x}';
xUnit = '1/µm';
xMin = miepGUIObj.workData.header.Regions.PAxis.Min;
xMax = miepGUIObj.workData.header.Regions.PAxis.Max;
xPoints = miepGUIObj.workData.header.Regions.PAxis.Points;

xres = abs(xMin-xMax) / xPoints;
kres = 1/xres;

xStep = kres/xPoints;
xMin = - kres/2;
xMax =   kres/2;
xTicks = 10;


yLabel = 'k_{y}';
yUnit = '1/µm';
yMin = 0;
yMax = miepGUIObj.workData.evalStore.FrequencySpectrum.Power(length(miepGUIObj.workData.evalStore.FrequencySpectrum.Power));
yPoints = length(miepGUIObj.workData.evalStore.FrequencySpectrum.Power);
yStep = (yMax - yMin) / yPoints;
yTicks = 10;

obj.uiHandles.imageAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
plot(miepGUIObj.workData.evalStore.FrequencySpectrum.Frequency(miepGUIObj.workData.evalStore.FrequencySpectrum.Frequency>0), miepGUIObj.workData.evalStore.FrequencySpectrum.Power(miepGUIObj.workData.evalStore.FrequencySpectrum.Frequency>0));
% obj.uiHandles.imageAxes.Color = obj.tabHandle.BackgroundColor;
% obj.uiHandles.imageAxes.Box = 'on';
% obj.uiHandles.imageAxes.XLim = [0 xPoints];
% obj.uiHandles.imageAxes.YLim = [0 yPoints];
% obj.uiHandles.imageAxes.TickDir = 'out';
% obj.uiHandles.imageAxes.XTick = 1:(xPoints-1)/xTicks:xPoints;
% obj.uiHandles.imageAxes.XTickLabel = {0:xPoints*xStep/xTicks:xPoints*xStep};
% obj.uiHandles.imageAxes.YTick = 1:(yPoints-1)/yTicks:yPoints;
% obj.uiHandles.imageAxes.YTickLabel = {0:yPoints*yStep/yTicks:yPoints*yStep};
obj.uiHandles.imageAxes.XLabel.String = [xLabel ' [' xUnit ']'];
obj.uiHandles.imageAxes.YLabel.String = [yLabel ' [' yUnit ']'];

% obj.uiHandles.image = image(obj.uiHandles.imageAxes);
% obj.uiHandles.image.CDataMapping = 'scaled';

%draw image on first energy/channel
imageDraw(1,1);
obj.tabData.workEnergy = 1; %use tabData to store current energy
obj.tabData.workChannel = 1; %use tabData to store current channel


%% support functions
    function imageDraw(energy, channel)
        region = miepGUIObj.workRegion;
        data = miepGUIObj.workData.data(channel, energy, region);
        obj.uiHandles.image.CData = data;
    end
end