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
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?

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

%create axes to draw movie
obj.uiHandles.movieAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.movieAxes.Color = obj.tabHandle.BackgroundColor;

%draw runback controls
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = 30; %width
Pos(4) = 30; %height
iconPlay = imread(fullfile(matlabroot, 'toolbox', 'shared', 'controllib', 'general', 'resources', 'toolstrip_icons', 'Run_24.png'), 'Background', obj.tabHandle.BackgroundColor);
obj.uiHandles.run = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'CData', iconPlay, 'Units', 'pixels', 'Position', Pos, 'Callback', @movieRun);

%use tabData to store current slice
obj.tabData.workSlice = 1;
%draw image on first energy/channel
movieDraw(1,1,1,1);


obj.tabData.workMovie = 1; %use tabData to store current moive
obj.tabData.workFrequency = 1; %use tabData to store current frequency
obj.tabData.workOnes = ones(size(miepGUIObj.workData.data(1,1,1),1), size(miepGUIObj.workData.data(1,1,1),2));
obj.tabData.workCountInterp = 0; %use tabData to store current counter for FFT movie

%% interactive behaviour of tab / callbacks
    function movieSelect(~, ~, ~)
        
        try
            %update movie after selection
            frequency = obj.uiHandles.frequencyList.Value;
            channel = obj.uiHandles.movieList.Value;
            
            obj.tabData.workFrequency = frequency;
            obj.tabData.workChannel = channel;
            
            try
                movieDraw(1,1,1,channel);
            end
            
            %adjust timer channel and speed depending on which movie is chosen
            try
                obj.uiHandles.timer.TimerFcn =  {@movieDraw, 1, channel};
                
                %Changing the speed requires the timer to be on hold
                stop(obj.uiHandles.timer)
                
                %Change Speed
                normMoviePeriod = 0.1;
                speed = 50/length(obj.uiHandles.frequencyList.String);
                fftMoviePeriod = normMoviePeriod/speed;
                if (channel == 1 || channel == 3) && obj.uiHandles.timer.Period ~= normMoviePeriod
                    obj.uiHandles.timer.Period = normMoviePeriod;
                elseif channel == 2 && obj.uiHandles.timer.Period ~= fftMoviePeriod
                    obj.uiHandles.timer.Period = fftMoviePeriod;
                end
                
                %Restart
                start(obj.uiHandles.timer)
            end
            
        catch
            %revert to previous selection on error
            obj.uiHandles.movieList.Value = obj.tabData.workMovie;
            obj.uiHandles.frequencyList.Value = obj.tabData.workFrequency;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end
        
        
    end

    function movieRun(~,~,~)
        
        channel = obj.uiHandles.movieList.Value;
        
        %if timer object does not exist or is not a valid timer, creat one
        try
            if ~isvalid(obj.uiHandles.timer)
                t = timer('Period', 0.1, 'TasksToExecute', inf,'ExecutionMode', 'fixedSpacing');
                t.TimerFcn = {@movieDraw, 1, channel};
                obj.uiHandles.timer = t;
            end
        catch
            t = timer('Period', 0.1, 'TasksToExecute', inf,'ExecutionMode', 'fixedSpacing');
            t.TimerFcn = {@movieDraw, 1, channel};
            obj.uiHandles.timer = t;
        end
        
        %If timer is off turn it on and vice versa, also change the icon
        if strcmp(obj.uiHandles.timer.Running, 'off')
            start(obj.uiHandles.timer)
            iconPause = imread(fullfile(matlabroot, 'toolbox', 'shared', 'controllib', 'general', 'resources', 'toolstrip_icons', 'Pause_MATLAB_24.png'), 'Background', obj.tabHandle.BackgroundColor);
            obj.uiHandles.run.CData = iconPause;
            
        else
            stop(obj.uiHandles.timer)
            delete(obj.uiHandles.timer)
            iconPlay = imread(fullfile(matlabroot, 'toolbox', 'shared', 'controllib', 'general', 'resources', 'toolstrip_icons', 'Run_24.png'), 'Background', obj.tabHandle.BackgroundColor);
            obj.uiHandles.run.CData = iconPlay;
        end
        
    end

%% support functions
    function movieDraw(~,~,energy, channel)
        %get sample position data and calculate plot coordinates
        xMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Min;
        xMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Max;
        xPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Points;
        
        yMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Min;
        yMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Max;
        yPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Points;
        
        x = linspace(xMin, xMax, xPoints)-xMin;
        y = linspace(yMin, yMax, yPoints)-yMin;
        %reset the color map in case it was changed by the hsv plot
        colormap(obj.uiHandles.movieAxes, parula)
        try
            if ishandle(obj.uiHandles.imageSurf)
                surfDraw(true, energy, channel, x, y)
            end
        catch

            surfDraw(false, energy, channel, x ,y)
            
            %also add stuff like axes labels, data aspect ratio ect...
            view(obj.uiHandles.movieAxes, 2)
            obj.uiHandles.movieAxes.XLim = [min(x) max(x)];
            obj.uiHandles.movieAxes.YLim = [min(y) max(y)];
            %obj.uiHandles.movieAxes.ZLimMode = 'auto';
            obj.uiHandles.movieAxes.Layer = 'Top';
            obj.uiHandles.movieAxes.Box = 'on';
            obj.uiHandles.movieAxes.DataAspectRatio = [1 1 1];
            obj.uiHandles.movieAxes.TickDir = 'out';
            obj.uiHandles.movieAxes.XLabel.String = '{\it x} [µm]';
            obj.uiHandles.movieAxes.YLabel.String = '{\it y} [µm]';
            
        end
    end

    function surfDraw(surfaceExists, energy, channel, x, y)
        region = miepGUIObj.workRegion;
        freqVal = obj.uiHandles.frequencyList.Value;
        slice = obj.tabData.workSlice;
        switch channel
            %for every channel, get the data and plot it over x and y, also
            %enable/diable buttons and lists depending on the channel
            %If the surface plot already exists, just change the Z data,
            %otherwise, create the surface plot
            
            case 1
                channel = 'Movie';
                data = miepGUIObj.workData.data(channel, energy, region);
                if surfaceExists
                    obj.uiHandles.imageSurf.ZData = data(:,:,slice);
                else
                    obj.uiHandles.imageSurf = surf(obj.uiHandles.movieAxes, x, y, data(:,:,slice), 'edgecolor', 'none');
                end
                obj.uiHandles.frequencyList.Enable = 'off';
                obj.uiHandles.run.Enable = 'on';
                obj.tabData.workSlice = slice + 1;
                if obj.tabData.workSlice > size(data,3)
                    obj.tabData.workSlice = 1;
                end
            case 2
                channel = 'FFT';
                data = miepGUIObj.workData.eval(channel);
                workOnes = obj.tabData.workOnes;
                countInterp = obj.tabData.workCountInterp;
                surfData =  data.Amplitude(:,:,freqVal).*sin(countInterp./50.*workOnes.*2.*pi+data.Phase(:,:,freqVal));
                
                if surfaceExists
                    obj.uiHandles.imageSurf.ZData = surfData;
                else
                    obj.uiHandles.imageSurf = surf(obj.uiHandles.movieAxes, x, y, surfData, 'edgecolor', 'none');
                end
                obj.uiHandles.frequencyList.Enable = 'on';
                obj.uiHandles.run.Enable = 'on';
                obj.tabData.workCountInterp = countInterp + 1;
                if obj.tabData.workCountInterp > 49
                    obj.tabData.workCountInterp = 0;
                end
            case 3
                %hsv picture is a little tricky. First of all, stop the
                %timer
                try
                    if strcmp(obj.uiHandles.timer.Running, 'on')
                        movieRun
                    end
                end
                
                channel = 'FFT';
                data = miepGUIObj.workData.eval(channel);
                
                %calulate the hsv picture
                clear hsv
                hue = (data.Phase(:,:,freqVal)+(8/8)*pi)/2/pi;
                sat = ones(size(hue,1),size(hue,2));
                val = (data.Amplitude(:,:,freqVal))/max(max(data.Amplitude(:,:,freqVal)));
                hsv(:,:,1) = hue;
                hsv(:,:,2) = sat;
                hsv(:,:,3) = val;
                
                %and convert it to rgb
                imageData = hsv2rgb(hsv);
                
                %since a Matlab image has its pixel position in the middle
                %of the pixel, but a surface plot has its pixel position at
                %the lower left corner, we need to make the data surface
                %plot compatible
                %we do that by giving each pixel a unique value: 1, 2, 3...
                %the color is added by adjusting the color bar so that
                %every pixel has the correct color
                
                colbar = reshape(imageData, [], 3);
                colData = reshape(1:size(colbar,1), size(imageData,1), size(imageData,2));
                
                %now we plot the surface and add the colorbar
                if surfaceExists
                    obj.uiHandles.imageSurf.ZData = colData;
                else
                    
                    obj.uiHandles.imageSurf = surf(obj.uiHandles.movieAxes, x, y, colData, 'edgecolor', 'none');
                end
                colormap(obj.uiHandles.movieAxes, colbar)
                
                obj.uiHandles.frequencyList.Enable = 'on';
                obj.uiHandles.run.Enable = 'off';
            case 4
                channel = 'RawMovie';
                data = miepGUIObj.workData.data(channel, energy, region);
                
                if surfaceExists
                    obj.uiHandles.imageSurf.ZData = data(:,:,slice);
                else
                    obj.uiHandles.imageSurf = surf(obj.uiHandles.movieAxes, x, y, data(:,:,slice), 'edgecolor', 'none');
                end
                obj.uiHandles.frequencyList.Enable = 'off';
                obj.uiHandles.run.Enable = 'on';
                obj.tabData.workSlice = slice + 1;
                if obj.tabData.workSlice > size(data,3)
                    obj.tabData.workSlice = 1;
                end
        end
    end
end