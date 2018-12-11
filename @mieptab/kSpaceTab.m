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
spatialFFT = miepGUIObj.workData.eval('SpatialFFT');
if max(size(energies)) == 1
    obj.uiHandles.energyList.Enable = 'off';
end

%draw frequency selector list
Pos(1) = drawingArea(3)/2 + 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.frequencyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Frequency ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @kSelect);
spectrum = miepGUIObj.workData.eval('FrequencySpectrum');
numFrequencies = size(spectrum.Frequency, 2);
frequencies = cell(numFrequencies,1);
for i=1:numFrequencies
    frequencies{i} = [num2str(round(spectrum.Frequency(i)/10^9,2)) ' GHz'];
end
obj.uiHandles.frequencyList.String = frequencies;
maxPowerIndex = find(spectrum.Power == max(spectrum.Power));
obj.uiHandles.frequencyList.Value = maxPowerIndex;

%draw image axes and image
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height

%draw movie axes and movie
Pos(1) = 5; %position left
Pos(2) = 2*5 + 20; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 4*5 - 2*20; %height

xLabel = 'k_{x}';
xUnit = '1/µm';
xMin = spatialFFT.kxAxis(1);
xMax = spatialFFT.kxAxis(length(spatialFFT.kxAxis));
xPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Points;
xStep = (xMax - xMin) / xPoints;
xTicks = 10;
yLabel = 'k_{y}';
yUnit = '1/µm';
yMin = spatialFFT.kyAxis(1);
yMax = spatialFFT.kyAxis(length(spatialFFT.kyAxis));
yPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Points;
yStep = (yMax - yMin) / yPoints;
yTicks = 10;

obj.uiHandles.movieAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.movieAxes.Color = obj.tabHandle.BackgroundColor;
obj.uiHandles.movieAxes.Box = 'on';
obj.uiHandles.movieAxes.XLim = [0 xPoints+1];
obj.uiHandles.movieAxes.YLim = [0 yPoints+1];
%obj.uiHandles.movieAxes.DataAspectRatio = [1 1 1];
obj.uiHandles.movieAxes.TickDir = 'out';
%obj.uiHandles.movieAxes.XTickMode = 'auto';
obj.uiHandles.movieAxes.XTick = 1:(xPoints-1)/xTicks:xPoints;
obj.uiHandles.movieAxes.XTickLabel = {xMin:xPoints*xStep/xTicks:xPoints*xStep};
%obj.uiHandles.movieAxes.XTickLabel = {spatialFFT.kxAxis};
obj.uiHandles.movieAxes.YTick = 1:(yPoints-1)/yTicks:yPoints;
obj.uiHandles.movieAxes.YTickLabel = {yMin:yPoints*yStep/yTicks:yPoints*yStep};
obj.uiHandles.movieAxes.XLabel.String = [xLabel ' [' xUnit ']'];
obj.uiHandles.movieAxes.YLabel.String = [yLabel ' [' yUnit ']'];

obj.uiHandles.movie = image(obj.uiHandles.movieAxes);
obj.uiHandles.movie.CDataMapping = 'scaled';

% obj.uiHandles.image = image(obj.uiHandles.imageAxes);
% obj.uiHandles.image.CDataMapping = 'scaled';

%use tabData to store current slice
obj.uiHandles.frequencyList.Value = round(length(frequencies)/2)+1;
obj.tabData.workSlice = obj.uiHandles.frequencyList.Value;

%draw image on first energy/channel
movieDraw(1,1,1,1);
obj.tabData.workEnergy = 1; %use tabData to store current energy
obj.tabData.workChannel = 1; %use tabData to store current channel

%% interactive behaviour of tab / callbacks
    function kSelect(~, ~, ~)
        %update movie after selection
        try
            frequency = obj.uiHandles.frequencyList.Value;
            obj.tabData.workSlice = frequency;
            movieDraw(1,1,1,1);
            obj.tabData.workFrequency = frequency;         
        catch
            %revert to previous selection on error
            obj.uiHandles.movieList.Value = obj.tabData.workMovie;
            obj.uiHandles.frequencyList.Value = obj.tabData.workFrequency;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end  
    end

%% support functions
    function movieDraw(~,~,energy, channel)     
        slice = obj.tabData.workSlice;
        data = miepGUIObj.workData.evalStore.SpatialFFT.kImages;
        obj.uiHandles.movie.CData = abs(data(:,:,slice));
        colorbar 

    end

end