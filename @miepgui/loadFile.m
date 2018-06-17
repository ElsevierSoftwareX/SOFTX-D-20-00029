% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Load File                                     %
% %                                                        %
% % Loads File into GUI                                    %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loadFile(obj)
    %check for sxm data file
    dataPath = fullfile(obj.settings.dataFolder, strcat(obj.workFile, '.miep'));
    if exist(dataPath, 'file')
        %load existing sxmdata from file
        load(dataPath, '-mat', 'data');
        obj.workData = data;
    else
        %create new sxmdata
        hdrFile = fullfile(obj.workFolder, strcat(obj.workFile, '.hdr'));
        obj.workData = sxmdata(hdrFile);
    end
    
    %update display
    obj.displayData
end