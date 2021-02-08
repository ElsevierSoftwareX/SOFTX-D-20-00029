% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Export Tool                                       %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showExportTool(obj, ~, ~, ~)
%Export tool

%show dialog to select measurements
fileList = selectSXMData;
if isempty(fileList)
    return
end

%show dialog to select export types
[wCSV, wJPG, wMP4, wPOV] = selectExport;
if ~any([wCSV, wJPG, wMP4, wPOV])
    return
end

%show waitbar
fileListLength = length(fileList);
wbString = ['Exporting data (0/' num2str(fileListLength) ') ...'];
wb = waitbar(0, wbString, 'Name', 'MIEP - Export Tool');

%export file by file
for i=1:fileListLength
    try
        %update waitbar
        wbString  = ['Exporting ' fileList{i} ' (' num2str(i) '/' num2str(fileListLength) ') ...'];
        waitbar((i-1)/fileListLength, wb, wbString)
        %load data
        tempData = obj.loadSXMData(fileList{i});
        %export CSV
        if wCSV
            tempData.writeCSV(obj.settings.outputFolder)
            waitbar((i-0.75)/fileListLength, wb)
        end
        %export JPG
        if wJPG
            tempData.writeJPG(obj.settings)
            waitbar((i-0.5)/fileListLength, wb)
        end
        %check for BBX channel (video)
        if strcmp(obj.workData.channels{end}, 'BBX')
            %export MP4 video
            if wMP4
                tempData.writeMP4(obj.settings, true) %use silent mode
                waitbar((i-0.75)/fileListLength, wb)
            end
            %export POV-Ray
            if wPOV
                tempData.writePOV(round(length(tempData.eval('FFT').Frequency)/2)+1, obj.settings.outputFolder)
                waitbar(i/fileListLength, wb)
            end
        end
    catch errMIEP
        disp(errMIEP)
    end
end

%delete waitbar
delete(wb)

%% gui functions
    function fileList = selectSXMData
        %select sxmdata from current file list
        fileList = {};
        
        %determine position from screen size and open dialog
        listLength = length(obj.fileList.String) * 10 + 20 + 3*5;
        screenSize = get(0, 'ScreenSize');
        dSize = [300 max(min(listLength, screenSize(3)*0.5), 130)]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - Export Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Next', 'Position', butPos, 'Callback', @guiNext);
        
        %data selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = dSize(2) - 20 - 3*5;
        select = uicontrol(d, 'Style', 'listbox', 'Position', curPos, 'Max', 2, 'String', obj.fileList.String);
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            fileList = select.String(select.Value);
            delete(d)
        end
    end

    function [wCSV, wJPG, wMP4, wPOV] = selectExport
        %select export types
        wCSV = false;
        wJPG = false;
        wMP4 = false;
        wPOV = false;
        
        %determine position from screen size and open dialog
        screenSize = get(0, 'ScreenSize');
        dSize = [300 130]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - Export Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Next', 'Position', butPos, 'Callback', @guiNext);
        
        %POV-Ray export selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        cPOV = uicontrol(d, 'Style', 'checkbox', 'Position', curPos, 'String', 'Export to POV-Ray');
        
        %MP4 export selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        cMP4 = uicontrol(d, 'Style', 'checkbox', 'Position', curPos, 'String', 'Export to MP4 video');
        
        %JPG export selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        cJPG = uicontrol(d, 'Style', 'checkbox', 'Position', curPos, 'String', 'Export to JPG images');
        
        %CSV export selector
        curPos(1) = 5;
        curPos(2) = curPos(2) + curPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = 20;
        cCSV = uicontrol(d, 'Style', 'checkbox', 'Position', curPos, 'String', 'Export to CSV text files');
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            wCSV = cCSV.Value;
            wJPG = cJPG.Value;
            wMP4 = cMP4.Value;
            wPOV = cPOV.Value;
            delete(d)
        end
    end
end