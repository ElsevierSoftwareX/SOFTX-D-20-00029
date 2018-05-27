% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Load Folder                                   %
% %                                                        %
% % Loads Data Folder into GUI                             %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loadFolder(obj, ~, ~, ~)
    %determine current directory
    if isempty(obj.workFolder)
        curFolder = fullfile(getenv('HOMEDRIVE'),getenv('HOMEPATH'));
    else
        curFolder = obj.workFolder;
    end
    
    %ask for folder to load
    curFolder = uigetdir(curFolder, 'Open SXM Data Folder');
    
    %exit function if uigetdir dialog was canceld
    if curFolder == 0
        return
    end
    
    %write new folder to object
    obj.workFolder = curFolder;
    
    %get and sort header list
    hdrList = dir(strcat(obj.workFolder, '\**/*.hdr'));
    dispFileList = cell(0);
    for i=1:size(hdrList,1)
        dispFileList{i} = strrep(hdrList(i).name, '.hdr', '');
    end
    dispFileList = sort(dispFileList);
    
    %display file list
    obj.fileList.String = dispFileList;
end