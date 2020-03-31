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
        %create new sxmdata from measurement data
        %check single file
        hdrFile = fullfile(obj.workFolder, strcat(obj.workFile, '.hdr'));
        if ~exist(hdrFile, 'file')
            %try multi energy folder
            hdrFile = fullfile(obj.workFolder, obj.workFile, strcat(obj.workFile, '.hdr'));
        end
        obj.workData = sxmdata(hdrFile);
    end
    
    %load miep file entry
    miepDate = obj.workFile(5:10);
    miepNumber = str2double(obj.workFile(11:13));
    miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);
    %check magic number
    if isempty(obj.workData.magicNumber) && (miepEntry.MagicNumber ~= 0)
        %use magic number from miep file if not set in sxm data file
        obj.workData.magicNumber = miepEntry.MagicNumber;
    elseif ~isempty(obj.workData.magicNumber) && (miepEntry.MagicNumber == 0)
        %use magic number from sxm data file if not set in miep file
        miepEntry.MagicNumber = obj.workData.magicNumber;
        obj.miepFile.writeEntry(miepDate, miepEntry)
    elseif ~isempty(obj.workData.magicNumber) && (miepEntry.MagicNumber ~= 0) && (obj.workData.magicNumber ~= miepEntry.MagicNumber)
        %ask for magic number if there is a mismatch between sxm data file
        %and miep file
        newMagicNumber = str2double(inputdlg(['Magic Number for ', obj.workData.header.Label, '?'], '?', 1 , {num2str(obj.workData.magicNumber)}));
        if ~isempty(newMagicNumber)
            miepEntry.MagicNumber = newMagicNumber;
            obj.miepFile.writeEntry(miepDate, miepEntry)
            obj.workData.reset
            obj.workData.magicNumber = newMagicNumber;
        end
    end     
    
    %update display
    obj.displayData
end