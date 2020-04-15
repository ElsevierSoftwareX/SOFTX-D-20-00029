% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP XMCD Tool                                         %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showXMCDTool(obj, ~, ~, ~)
%XMCD tool

%show dialog to select spectra
[file1, file2] = selectSXMData;

%load data
if isempty(file1) || isempty(file2)
    return
else
    data1 = obj.loadSXMData(file1);
    data2 = obj.loadSXMData(file2);
end

%show dialog to select channel
[channel1, channel2] = selectChannel;
if isempty(channel1) || isempty(channel2)
    return
end
if ~strcmp(data1.header.Flags, data2.header.Flags)
    errordlg('Incomptabile data flags', 'MIEP - XMCD Tool')
    return
end

%get data from sxmdata
xas1 = data1.data(channel1);
xas2 = data2.data(channel2);

%image registration for images
if strcmp(data1.header.Flags, 'Image')
    [regType, regMode] = selectRegistration;
    if ~strcmp(regType, 'none')
        %register xas2 onto xas1
        lastwarn('');
        [optimizer, metric] = imregconfig(regMode);
        xas2 = imregister(xas2, xas1, regType, optimizer, metric);
        %check for warning, i.e. registration failure
        [warnMsg, ~] = lastwarn;
        if ~isempty(warnMsg)
            warndlg(warnMsg, 'MIEP - XMCD Tool')
        end
    end
end

%evaluate data
try
    xmcdSignal = (xas1 - xas2) ./ (xas1 + xas2);
catch
    errordlg('Incomptabile data size', 'MIEP - XMCD Tool')
    return
end

%show XMCD result
newFigure = figure;
newAxes = axes(newFigure);
switch data1.header.Flags
    case 'Image'
        xMin = data1.header.Regions(1).PAxis.Min;
        xMax = data1.header.Regions(1).PAxis.Max;
        xPoints = data1.header.Regions(1).PAxis.Points;
        yMin = data1.header.Regions(1).QAxis.Min;
        yMax = data1.header.Regions(1).QAxis.Max;
        yPoints = data1.header.Regions(1).QAxis.Points;
        x = linspace(xMin, xMax, xPoints)-xMin;
        y = linspace(yMin, yMax, yPoints)-yMin;
        
        surf(newAxes, x, y, xmcdSignal, 'edgecolor', 'none');
        view(newAxes, 2)
        newAxes.XLim = [min(x) max(x)];
        newAxes.YLim = [min(y) max(y)];
        newAxes.Box = 'on';
        newAxes.DataAspectRatio = [1 1 1];
        newAxes.TickDir = 'out';
        newAxes.Layer = 'top';
        newAxes.XLabel.String = '{\it x} [µm]';
        newAxes.YLabel.String = '{\it y} [µm]';
    case 'Spectra'
        xLabel = data1.header.Regions(1).PAxis.Name;
        xUnit = data1.header.Regions(1).PAxis.Unit;
        yLabel = 'XMCD';
        yUnit = 'a.u.';
        
        plot(newAxes, data1.data('Energy'), xmcdSignal)
        newAxes.TickDir = 'out';
        newAxes.XLabel.String = [xLabel ' [' xUnit ']'];
        newAxes.YLabel.String = [yLabel ' [' yUnit ']'];
    otherwise
        warndlg('Data flag not supported', 'MIEP - XMCD Tool')
end


%% gui functions
    function [file1, file2] = selectSXMData
        %select sxmdata from current file list
        file1 = [];
        file2 = [];
        
        %determine position from screen size and open dialog
        screenSize = get(0, 'ScreenSize');
        dSize = [300 80]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - XMCD Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Next', 'Position', butPos, 'Callback', @guiNext);
        
        %second data selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select2 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', obj.fileList.String);
        
        %first data selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select1 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', obj.fileList.String);
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            file1 = select1.String{select1.Value};
            file2 = select2.String{select2.Value};
            delete(d)
        end
    end

    function [channel1, channel2] = selectChannel
        %select channel from current sxmdata
        channel1 = [];
        channel2 = [];
        
        %determine position from screen size and open dialog
        screenSize = get(0, 'ScreenSize');
        dSize = [300 80]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - XMCD Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Next', 'Position', butPos, 'Callback', @guiNext);
        
        %second data selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select2 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', data2.channels);
        
        %first data selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select1 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', data1.channels);
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            channel1 = select1.String{select1.Value};
            channel2 = select2.String{select2.Value};
            delete(d)
        end
    end

    function [regType, regMode] = selectRegistration
        %select image registration mode
        regMode = 'none';
        
        %determine position from screen size and open dialog
        screenSize = get(0, 'ScreenSize');
        dSize = [300 80]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - XMCD Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Next', 'Position', butPos, 'Callback', @guiNext);
        
        %registration type selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select1 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', {'monomodal', 'multimodal'});
        select2 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', {'affine','similarity','rigid','translation','none'});
        
        %registration mode selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        select1 = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', {'monomodal', 'multimodal'});
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            regMode = select1.String{select1.Value};
            regType = select2.String{select2.Value};
            delete(d)
        end
    end
end