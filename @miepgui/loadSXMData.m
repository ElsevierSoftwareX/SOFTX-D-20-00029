% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Load SXMData                                  %
% %                                                        %
% % Loads SXMData from disk or reads in hdr                %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = loadSXMData(obj, file)
%checks for sxm data file or loads
%check for sxm data file
dataPath = fullfile(obj.settings.dataFolder, strcat(file, '.miep'));
if exist(dataPath, 'file')
    %load existing sxmdata from file
    load(dataPath, '-mat', 'data');
else
    %create new sxmdata from measurement data
    %check single file
    hdrFile = fullfile(obj.workFolder, strcat(file, '.hdr'));
    if ~exist(hdrFile, 'file')
        %try multi energy folder
        hdrFile = fullfile(obj.workFolder, file, strcat(file, '.hdr'));
    end
    data = sxmdata(hdrFile);
end
end