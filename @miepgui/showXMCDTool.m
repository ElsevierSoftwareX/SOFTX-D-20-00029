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
        
        sub1 = subplot(2,2,1);
        surf(sub1, x, y, xas1, 'edgecolor', 'none');
        sub1.Title.String = 'XAS 1';
        
        sub2 = subplot(2,2,3);
        surf(sub2, x, y, xas2, 'edgecolor', 'none');
        sub2.Title.String = 'XAS 2';
        
        sub3 = subplot(2,2,2);
        surf(sub3, x, y, xmcdSignal, 'edgecolor', 'none');
        sub3.Title.String = 'XMCD';
        
        sub3 = subplot(2,2,4);
        surf(sub3, x, y, xas1 + xas2, 'edgecolor', 'none');
        sub3.Title.String = 'XAS 1 + XAS 2';   
        
        for i = 1:length(newFigure.Children)
            newFigure.Children(i).View = [0 90];
            newFigure.Children(i).XLim = [min(x) max(x)];
            newFigure.Children(i).YLim = [min(y) max(y)];
            newFigure.Children(i).Box = 'on';
            newFigure.Children(i).DataAspectRatio = [1 1 1];
            newFigure.Children(i).TickDir = 'out';
            newFigure.Children(i).Layer = 'top';
            newFigure.Children(i).XLabel.String = '{\it x} [µm]';
            newFigure.Children(i).YLabel.String = '{\it y} [µm]';
            newFigure.Children(i).Colormap = eval(obj.settings.colorMaps{obj.settings.imageColorMap});
        end
        
    case 'Spectra'
        sub1 = subplot(2,1,1);
        xLabel = data1.header.Regions(1).PAxis.Name;
        xUnit = data1.header.Regions(1).PAxis.Unit;
        yLabel = 'XAS';
        yUnit = 'counts';
        
        plot(sub1, data1.data('Energy'), xas1)
        hold on
        plot(sub1, data1.data('Energy'), xas2)
        hold off
        sub1.TickDir = 'out';
        sub1.XLabel.String = [xLabel ' [' xUnit ']'];
        sub1.YLabel.String = [yLabel ' [' yUnit ']'];
        
        legend(data1.header.Label, data2.header.Label, 'interpreter', 'none')
        
        sub2 = subplot(2,1,2);
        xLabel = data1.header.Regions(1).PAxis.Name;
        xUnit = data1.header.Regions(1).PAxis.Unit;
        yLabel = 'XMCD';
        yUnit = 'a.u.';
        
        plot(sub2, data1.data('Energy'), xmcdSignal)
        sub2.TickDir = 'out';
        sub2.XLabel.String = [xLabel ' [' xUnit ']'];
        sub2.YLabel.String = [yLabel ' [' yUnit ']'];
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