% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP GUI Load Folder                                   %
% %                                                        %
% % Loads Data Folder into GUI                             %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function loadFolder(obj)
    %get and sort header list
    hdrList = dir(strcat(obj.workFolder, '\**/*.hdr'));
    dispFileList = cell(0);
    
    %create waitbar
    wb = waitbar(0, '', 'Name', 'MIEP');
    wb.Children(1).Title.Interpreter = 'none';
    wb.Children(1).Title.String = ['Loading ', obj.workFolder, ' ...'];
    
    %create list to display and update MIEP file
    for i=1:size(hdrList,1)
        %update watibar
        waitbar(i/size(hdrList,1), wb);
        
        %determine header file path
        hdrFile = fullfile(hdrList(i).folder, hdrList(i).name);
        
        %load MIEP file
        miepDate = hdrList(i).name(end-12:end-7);
        miepNumber = str2double(hdrList(i).name(end-6:end-4));
        miepEntry = obj.miepFile.readEntry(miepDate, miepNumber);
        
        %update MIEP entry
        if isempty(miepEntry)
            %create new MIEP entry
            miepEntry = struct;
            miepEntry.Measurement = miepNumber;
            miepEntry.MagicNumber = 0;
            miepEntry.Comment = ' ';
            miepEntry.HeaderFile = hdrFile;
            obj.miepFile.writeEntry(miepDate, miepEntry);
        else
            %only update if header file is different
            if ~strcmp(miepEntry.HeaderFile, hdrFile)
                miepEntry.HeaderFile = hdrFile;
                obj.miepFile.writeEntry(miepDate, miepEntry);
            end
        end
        
        %put entry into display list
        fileName = strrep(hdrList(i).name, '.hdr', '');
        folderName = strrep(hdrList(i).folder, obj.workFolder, '');
        
        if ~isempty(folderName)
            dispFileList{i} = [folderName(2:end) '\' fileName];
        else
            dispFileList{i} = fileName;
        end
        
        %old version for only 1 Folder
        %dispFileList{i} = [strrep(hdrList(i).name, '.hdr', '')];

    end
    dispFileList = sort(dispFileList);
    
    %display file list and delete waitbar
    obj.fileList.String = dispFileList;
    delete(wb)
end