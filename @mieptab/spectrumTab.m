% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Spectrum Tab                                      %
% %                                                        %
% % Spectrum Tab Class Subset                              %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gr?fe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function spectrumTab(obj, miepGUIObj)
%% intialize / draws the sepctrum tab
%determine drawing area
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?

%draw channel selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.channelList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Channel ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @spectrumSelect);
channels = miepGUIObj.workData.channels;
obj.uiHandles.channelList.String = channels;
if max(size(channels)) == 1
    obj.uiHandles.channelList.Enable = 'off';
end

drawnow % fix for stuttering

%draw open figure
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = 90; %width
Pos(4) = 30; %height
obj.uiHandles.run = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', Pos, 'Callback', @openinFigure, 'String', 'Open in Figure');

%draw spectrum axes
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height
obj.uiHandles.spectrumAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);

%draw spectrum of first channel
spectrumDraw(1)
obj.tabData.workChannel = 1;

%% interactive behaviour of tab / callbacks
    function spectrumSelect(~, ~, ~)
        %update spectrum after selection
        try
            channel = obj.uiHandles.channelList. Value;
            spectrumDraw(channel)
            obj.tabData.workChannel = channel;
        catch
            %revert to previous selection on error
            obj.uiHandles.channelList.Value = obj.tabData.workChannel;
            uiwait(errordlg('Failed to load selected spectrum.', 'MIEP'))
        end  
    end

%% support functions
    function spectrumDraw(channel)
        region = miepGUIObj.workRegion;
        plot(obj.uiHandles.spectrumAxes, miepGUIObj.workData.data('Energy',1,region), miepGUIObj.workData.data(channel,1,region))
        obj.uiHandles.spectrumAxes.TickDir = 'out';
        xLabel = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Name;
        xUnit = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Unit;
        yLabel = 'Intensity';
        yUnit = miepGUIObj.workData.header.Channels(channel).Unit;
        obj.uiHandles.spectrumAxes.XLabel.String = [xLabel ' [' xUnit ']'];
        obj.uiHandles.spectrumAxes.YLabel.String = [yLabel ' [' yUnit ']'];
    end

    function openinFigure(~, ~, ~)
        newFigure = figure('Numbertitle', 'off', 'Name', 'Spektrum');
        newAxis = copyobj(obj.uiHandles.spectrumAxes, newFigure);
        set(newAxis,'Units','normalized','Position',[0.13 0.11 0.775 0.815])
    end

end