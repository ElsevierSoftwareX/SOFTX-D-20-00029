% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Movie Tab                                         %
% %                                                        %
% % Movie Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe / Nick-André Träger                      %
% % graefe@is.mpg.de / traeger@is.mpg.de                   %
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
obj.uiHandles.movieList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Movie ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @movieSelect);
obj.uiHandles.movieList.String = {'Normalized Movie', 'FFT Movie', 'HSV Image', 'Raw Movie'};

%draw frequency selector list
Pos(1) = drawingArea(3)/2 + 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.frequencyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Frequency ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @movieSelect);
spectrum = miepGUIObj.workData.eval('FrequencySpectrum');
numFrequencies = size(spectrum.Frequency, 2);
frequencies = cell(numFrequencies,1);
for i=1:numFrequencies
    frequencies{i} = [num2str(round(spectrum.Frequency(i)/10^9,2)) ' GHz'];
end
obj.uiHandles.frequencyList.String = frequencies;
maxPowerIndex = find(spectrum.Power == max(spectrum.Power));
obj.uiHandles.frequencyList.Value = maxPowerIndex;

if obj.uiHandles.movieList.Value == 1 || obj.uiHandles.movieList.Value == 3
    obj.uiHandles.frequencyList.Value = round(length(frequencies)/2)+1;
    obj.uiHandles.frequencyList.Enable = 'off';
end

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
iconPlay = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'help_gs.png'), 'Background', obj.tabHandle.BackgroundColor);
[img, map] = rgb2ind(iconPlay, 65535);
iconPlayLoad = ind2rgb(img, map);
obj.uiHandles.play = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'CData', iconPlay, 'Units', 'pixels', 'Position', Pos, 'Callback', @moviePlay);

Pos(1) = 29; %position left
Pos(2) = 5; % position bottom
Pos(3) = 20; %width
Pos(4) = 20; %height
iconStop = imread(fullfile(matlabroot, 'toolbox', 'matlab', 'icons', 'help_gs.png'), 'Background', obj.tabHandle.BackgroundColor);
[img, map] = rgb2ind(iconStop, 65535);
iconStopLoad = ind2rgb(img, map);
obj.uiHandles.stop = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'CData', iconStop, 'Units', 'pixels', 'Position', Pos, 'Callback', @movieStop);

%use tabData to store current slice
obj.tabData.workSlice = 1;
%draw image on first energy/channel
movieDraw(1,1,1,1); 

%define timer object
tNorm = timer('Period', 0.12, 'TasksToExecute', inf,'ExecutionMode', 'fixedSpacing');
tNorm.StopFcn = {@movieStop};     
tNorm.TimerFcn = {@movieDraw, 1, 1};    
obj.uiHandles.timerNorm = tNorm;

% tFFT = timer('Period', 0.04, 'TasksToExecute', inf,'ExecutionMode', 'fixedSpacing');
% tFFT.StopFcn = {@movieStop};     
% tFFT.TimerFcn = {@movieDraw, 1, 1};    
% obj.uiHandles.timerFFT = tFFT;

obj.tabData.workMovie = 1; %use tabData to store current moive
obj.tabData.workFrequency = 1; %use tabData to store current frequency
obj.tabData.workOnes = ones(size(miepGUIObj.workData.data(1,1,1),1), size(miepGUIObj.workData.data(1,1,1),2));
obj.tabData.workCountInterp = 0; %use tabData to store current counter for FFT movie

%% interactive behaviour of tab / callbacks
    function movieSelect(~, ~, ~)
        %update movie after selection
        try
            frequency = obj.uiHandles.frequencyList.Value;
            channel = obj.uiHandles.movieList.Value;     
            movieDraw(1,1,1,channel);
            obj.tabData.workFrequency = frequency;
            obj.tabData.workChannel = channel;
            if isvalid(obj.uiHandles.timerNorm)
                movieStop;                  
            end    
            
        catch
            %revert to previous selection on error
            obj.uiHandles.movieList.Value = obj.tabData.workMovie;
            obj.uiHandles.frequencyList.Value = obj.tabData.workFrequency;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end  
    end

    function moviePlay(~,~,~)
            channel = obj.uiHandles.movieList.Value;           
            try
                if isvalid(obj.uiHandles.timerNorm) %validation of timer input
                    obj.uiHandles.timerNorm.TimerFcn = {@movieDraw, 1, channel};
                    if channel == 2
                        obj.uiHandles.timerNorm.Period = 0.04;
                    end    
                    start(obj.uiHandles.timerNorm)
                else
                    %if timer object is empty, define valid input
                    tNorm = timer('Period', 0.1, 'TasksToExecute', inf,'ExecutionMode', 'fixedSpacing');
                    tNorm.StopFcn = {@movieStop};     
                    tNorm.TimerFcn = {@movieDraw, 1, channel};    
                    obj.uiHandles.timerNorm = tNorm; 
                    if channel == 2
                        obj.uiHandles.timerNorm.Period = 0.04;
                    end
                    start(obj.uiHandles.timerNorm)
                end    
            catch
            end    
    end 

    function movieStop(~,~,~)
        stop(obj.uiHandles.timerNorm)
        delete(obj.uiHandles.timerNorm)
    end

%% support functions
    function movieDraw(~,~,energy, channel)
        region = miepGUIObj.workRegion;
        freqVal = obj.uiHandles.frequencyList.Value;
        slice = obj.tabData.workSlice;
        switch channel
            case 1
                channel = 'Movie';    
                data = miepGUIObj.workData.data(channel, energy, region);
                obj.uiHandles.movie.CData = data(:,:,slice);
                obj.uiHandles.frequencyList.Enable = 'off';
                obj.uiHandles.play.Enable = 'on';
                obj.uiHandles.stop.Enable = 'on';
                obj.tabData.workSlice = slice + 1;
                if obj.tabData.workSlice > size(data,3)
                    obj.tabData.workSlice = 1;
                end
            case 2
                channel = 'FFT';    
                data = miepGUIObj.workData.eval(channel);
                workOnes = obj.tabData.workOnes;
                countInterp = obj.tabData.workCountInterp;
                obj.uiHandles.movie.CData = data.Amplitude(:,:,freqVal).*sin(countInterp./100.*workOnes.*2.*pi+data.Phase(:,:,freqVal));
                obj.uiHandles.frequencyList.Enable = 'on';
                obj.uiHandles.play.Enable = 'on';
                obj.uiHandles.stop.Enable = 'on';
                obj.tabData.workCountInterp = countInterp + 1;
                if obj.tabData.workCountInterp > 99
                    obj.tabData.workCountInterp = 0;
                end
            case 3
                channel = 'FFT';
                data = miepGUIObj.workData.eval(channel);      
                
                clear hsv
                hue = (data.Phase(:,:,freqVal)+(8/8)*pi)/2/pi;
                sat = ones(size(hue,1),size(hue,2));
                val = (data.Amplitude(:,:,freqVal))/max(max(data.Amplitude(:,:,freqVal)));
                hsv(:,:,1) = hue;
                hsv(:,:,2) = sat;
                hsv(:,:,3) = val;
                
                obj.uiHandles.movie.CData = hsv2rgb(hsv);
                obj.uiHandles.frequencyList.Enable = 'on';
                obj.uiHandles.play.Enable = 'off';
                obj.uiHandles.stop.Enable = 'off';
            case 4
                channel = 'RawMovie';   
                data = miepGUIObj.workData.data(channel, energy, region);
                obj.uiHandles.movie.CData = data(:,:,slice);
                obj.uiHandles.frequencyList.Enable = 'off';
                obj.uiHandles.play.Enable = 'on';
                obj.uiHandles.stop.Enable = 'on';
                obj.tabData.workSlice = slice + 1;
                if obj.tabData.workSlice > size(data,3)
                    obj.tabData.workSlice = 1;
                end
        end    
        
    end
   
end