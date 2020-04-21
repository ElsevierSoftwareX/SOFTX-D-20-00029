% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Cache Clearing Tool                               %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showCacheTool(obj, ~, ~, ~)
%cache clearing tool

%show dialog to select measurements
fileList = selectCacheData;
if isempty(fileList)
    return
end


%show waitbar
fileListLength = length(fileList);
wbString = ['Clearing Cache (0/' num2str(fileListLength) ') ...'];
wb = waitbar(0, wbString, 'Name', 'MIEP - Cache Tool');

%export file by file
for i=1:fileListLength
    try
        %update waitbar
        wbString  = ['Clearing Cache (' num2str(i) '/' num2str(fileListLength) ') ...'];
        waitbar((i-1)/fileListLength, wb, wbString)
        delete(fullfile(fileList(i).folder, fileList(i).name))
    catch errMIEP
        disp(errMIEP)
    end
end

%delete waitbar
delete(wb)

%% gui functions
    function fileList = selectCacheData
        %select cache from current file list
        fileList = [];
        cacheFiles = dir(fullfile(obj.settings.dataFolder, '*.miep'));
        fileNames = {cacheFiles.name};
        
        %determine position from screen size and open dialog
        listLength = length(fileNames) * 10 + 20 + 3*5;
        screenSize = get(0, 'ScreenSize');
        dSize = [300 min(listLength, screenSize(3)*0.8)]; %figure width height
        dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
        dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
        dPos(3) = dSize(1); %width
        dPos(4) = dSize(2); %height
        d = dialog('Position', dPos, 'Name', 'MIEP - Cache Tool');
        
        %next button
        butPos(3) = 50; %width
        butPos(4) = 20; %height
        butPos(1) = dPos(3)/2 - butPos(3)/2; %position left
        butPos(2) = 5; %position bottom
        uicontrol(d, 'Style', 'pushbutton', 'String', 'Clear', 'Position', butPos, 'Callback', @guiNext);
        
        %data selector
        curPos(1) = 5;
        curPos(2) = butPos(2) + butPos(4) + 5;
        curPos(3) = dSize(1) - 2*5;
        curPos(4) = dSize(2) - 20 - 3*5;
        select = uicontrol(d, 'Style', 'listbox', 'Position', curPos, 'Max', 2, 'String', fileNames);
        
        %wait for selection
        uiwait(d)
        
        function guiNext(~, ~, ~)
            %evaluate dialog input
            fileList = cacheFiles(select.Value);
            delete(d)
        end
    end
end