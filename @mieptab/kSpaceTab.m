% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Image Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function kspaceTab(obj, miepGUIObj)
%% intialize / draws the image tab
%determine drawing area
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?

%draw energy selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.energyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Energy ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
energies = miepGUIObj.workData.energies;
obj.uiHandles.energyList.String = energies;
miepGUIObj.workData.eval('SpatialFFT');
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

%draw open figure
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = 90; %width
Pos(4) = 30; %height
obj.uiHandles.run = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', Pos, 'Callback', @openinFigure, 'String', 'Open in Figure');


%draw image axes and image
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height

%create axis
obj.uiHandles.fftAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);

%chose first frequency to plot
obj.uiHandles.frequencyList.Value = round(length(frequencies)/2)+1;
obj.tabData.workSlice = obj.uiHandles.frequencyList.Value;

%draw image on first energy/channel
fftDraw;


obj.tabData.workEnergy = 1; %use tabData to store current energy
obj.tabData.workChannel = 1; %use tabData to store current channel


%% interactive behaviour of tab / callbacks
    function kSelect(~, ~, ~)
        %update movie after selection
        try
            frequency = obj.uiHandles.frequencyList.Value;
            obj.tabData.workSlice = frequency;
            cla(obj.uiHandles.fftAxes);
            fftDraw;
            obj.tabData.workFrequency = frequency;
        catch
            %revert to previous selection on error
            obj.uiHandles.movieList.Value = obj.tabData.workMovie;
            obj.uiHandles.frequencyList.Value = obj.tabData.workFrequency;
            uiwait(errordlg('Failed to load selected image.', 'MIEP'))
        end
    end

%% support functions
    function fftDraw(varargin)
        if length(varargin) == 1
            ax = varargin{1};
        else
            ax = obj.uiHandles.fftAxes;
        end
        
        data = miepGUIObj.workData.evalStore.SpatialFFT.kImages;
        slice = obj.tabData.workSlice;
        fftData = abs(data(:,:,slice));
        
        kx = obj.miepGUIObj.workData.evalStore.SpatialFFT.kxAxis;
        ky = obj.miepGUIObj.workData.evalStore.SpatialFFT.kyAxis;
        surf(ax, kx, ky, fftData, 'edgecolor', 'none')
        view(ax,2)
        ax.PlotBoxAspectRatio = [1 1 1];
        xlim(ax, [min(kx) max(kx)])
        ylim(ax, [min(ky) max(ky)])
        
        colorbar(ax)
        
        %add ticks, labels, ect.
        ax.Color = obj.tabHandle.BackgroundColor;
        ax.Box = 'on';
        ax.TickDir = 'out';
        ax.Layer = 'top';
        ax.XLabel.String = '{\it k_x} [1/µm]';
        ax.YLabel.String = '{\it k_y} [1/µm]';
        obj.uiHandles.movie.CDataMapping = 'scaled';
        
    end

    function openinFigure(~, ~, ~)
        titleFreq = obj.uiHandles.frequencyList.String{obj.uiHandles.frequencyList.Value};
        figure('Numbertitle', 'off', 'Name', ['k-Space - ' titleFreq])
        ax = axes;
        fftDraw(ax);
    end
end