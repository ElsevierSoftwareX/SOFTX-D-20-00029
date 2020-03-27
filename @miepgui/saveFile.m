% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Save File                                     %
% %                                                        %
% % Saves File from GUI                                    %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function saveFile(obj)
%load miep file entry
miepDate = obj.workFile(5:10);
miepNumber = str2double(obj.workFile(11:13));
miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);

%check magic number and save it
if ~isempty(obj.workData.magicNumber) && (miepEntry.MagicNumber == 0)
    %use magic number from sxm data file if not set in miep file
    miepEntry.MagicNumber = obj.workData.magicNumber;
    obj.miepFile.writeEntry(miepDate, miepEntry)
end

%save current sxmdata file
dataPath = fullfile(obj.settings.dataFolder, strcat(obj.workFile, '.miep'));
data = obj.workData;
save(dataPath, 'data')
delete(data)
end