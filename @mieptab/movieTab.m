% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Movie Tab                                         %
% %                                                        %
% % Movie Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function movieTab(obj, miepGUIObj)
%% intialize / draws the movie tab
%determine drawing area
drawingArea = obj.tabHandle.Position;
drawingArea = drawingArea - [0 0 5 30]; %correct MATLAB madness?

%draw movie selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.movieList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Movie ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
obj.uiHandles.movieList.String = {'Normalized Movie', 'FFT Movie', 'HSV Image', 'Raw Movie'};

%draw frequency selector list
Pos(1) = drawingArea(3)/2 + 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.frequencyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Frequency ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
spectrum = miepGUIObj.workData.eval('FrequencySpectrum');
numFrequencies = size(spectrum.Frequency, 2);
frequencies = cell(numFrequencies,1);
for i=1:numFrequencies
    frequencies{i} = [num2str(round(spectrum.Frequency(i)/10^10,1)) ' GHz'];
end
obj.uiHandles.frequencyList.String = frequencies;
maxPowerIndex = find(spectrum.Power == max(spectrum.Power));
obj.uiHandles.frequencyList.Value = maxPowerIndex;

%draw movie axes and movie
Pos(1) = 5; %position left
Pos(2) = 2*5 + 20; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 4*5 - 2*20; %height

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

obj.uiHandles.movieAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.movieAxes.Color = obj.tabHandle.BackgroundColor;
obj.uiHandles.movieAxes.Box = 'on';
obj.uiHandles.movieAxes.XLim = [0 xPoints+1];
obj.uiHandles.movieAxes.YLim = [0 yPoints+1];
obj.uiHandles.movieAxes.DataAspectRatio = [1 1 1];
obj.uiHandles.movieAxes.TickDir = 'out';
obj.uiHandles.movieAxes.XTick = 1:(xPoints-1)/xTicks:xPoints;
obj.uiHandles.movieAxes.XTickLabel = {0:xPoints*xStep/xTicks:xPoints*xStep};
obj.uiHandles.movieAxes.YTick = 1:(yPoints-1)/yTicks:yPoints;
obj.uiHandles.movieAxes.YTickLabel = {0:yPoints*yStep/yTicks:yPoints*yStep};
obj.uiHandles.movieAxes.XLabel.String = [xLabel ' [' xUnit ']'];
obj.uiHandles.movieAxes.YLabel.String = [yLabel ' [' yUnit ']'];

obj.uiHandles.movie = image(obj.uiHandles.movieAxes);
obj.uiHandles.movie.CDataMapping = 'scaled';

%draw playback controls
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = 20; %width
Pos(4) = 20; %height
icon = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'help_gs.png'), 'Background', obj.tabHandle.BackgroundColor);
[img, map] = rgb2ind(icon, 65535);
iconLoad = ind2rgb(img, map);
obj.uiHandles.play = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'CData', icon, 'Units', 'pixels', 'Position', Pos)

%draw image on first energy/channel
movieDraw(1,1);
obj.tabData.workMovie = 1; %use tabData to store current moive
obj.tabData.workFrequency = 1; %use tabData to store current frequency

%% interactive behaviour of tab / callbacks
    function movieSelect(~, ~, ~)
        %update movie after selection
        try
            energy = obj.uiHandles.energyList.Value;
            channel = obj.uiHandles.channelList. Value;
            imageDraw(energy, channel)
            obj.tabData.workEnergy = energy;
            obj.tabData.workChannel = channel;
        catch
            %revert to previous selection on error
            obj.uiHandles.movieList.Value = obj.tabData.workMovie;
            obj.uiHandles.frequencyList.Value = obj.tabData.workFrequency;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end  
    end

%% support functions
    function movieDraw(energy, channel)
        region = miepGUIObj.workRegion;
        data = miepGUIObj.workData.data(channel, energy, region);
        obj.uiHandles.image.CData = data;
    end
end