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
miepDate = obj.workFile(end-8:end-3);
miepNumber = str2double(obj.workFile(end-2:end));
miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);

%check magic number and save it
if ~isempty(obj.workData.magicNumber) && (miepEntry.MagicNumber == 0)
    %use magic number from sxm data file if not set in miep file
    miepEntry.MagicNumber = obj.workData.magicNumber;
    obj.miepFile.writeEntry(miepDate, miepEntry)
end

%save current sxmdata file
workFilePath = strsplit(obj.workFile, '\');
dataPath = fullfile(obj.settings.dataFolder, strcat(workFilePath{end}, '.miep'));
data = obj.workData;

dataSize = checkSize(data);
if dataSize > 1e8
    wbar = waitbar(1,'...This might take some time depending on the scan size.','Name',...
        sprintf('Saving %0.1f Gigabytes of Data...',round(dataSize/1e9,1)));
    save(dataPath, 'data', '-nocompression')
    delete(wbar)
else
    save(dataPath, 'data', '-nocompression')
end

delete(data)
end


function dataSize = checkSize(dataObj) 
   props = properties(dataObj); 
   dataSize = 0; 
   
   for i=1:length(props) 
      currentProperty = dataObj.(props{i}); 
      s = whos('currentProperty'); 
      dataSize = dataSize + s.bytes; 
   end
  
end
