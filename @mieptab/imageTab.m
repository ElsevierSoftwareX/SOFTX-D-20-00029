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
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?

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

obj.uiHandles.imageAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.imageAxes.Color = obj.tabHandle.BackgroundColor;
imageDraw(1,1);

%draw image on first energy/channel

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
        
        try
            if ishandle(obj.uiHandles.imageSurf)
                obj.uiHandles.imageSurf.ZData = data;
            end
        catch
            ax = obj.uiHandles.imageAxes;

            xMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Min;
            xMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Max;
            xPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).PAxis.Points;
            
            yMin = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Min;
            yMax = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Max;
            yPoints = miepGUIObj.workData.header.Regions(miepGUIObj.workRegion).QAxis.Points;
            
            
            x = linspace(xMin, xMax, xPoints)-xMin;
            y = linspace(yMin, yMax, yPoints)-yMin;
            
            obj.uiHandles.imageSurf = surf(ax, x, y, data, 'edgecolor', 'none');
            
            view(ax, 2)
            
            ax.XLim = [min(x) max(x)];
            ax.YLim = [min(y) max(y)];
            
            ax.Box = 'on';
            ax.DataAspectRatio = [1 1 1];
            ax.TickDir = 'out';
            ax.Layer = 'top';
            
            ax.XLabel.String = '{\it x} [µm]';
            ax.YLabel.String = '{\it y} [µm]';
        end
    end


    function openinFigure(~, ~, ~)
        
        channel = obj.uiHandles.channelList.Value;
        if channel == 1
            figureName = 'APD Image';
        elseif channel == 2
            figureName = 'BBX Image';
        end
        newFigure = figure('Numbertitle', 'off', 'Name', figureName);
        newAxis = copyobj(obj.uiHandles.imageAxes, newFigure);
        set(newAxis,'Units','normalized','Position',[0.13 0.11 0.775 0.815])
    end

end











