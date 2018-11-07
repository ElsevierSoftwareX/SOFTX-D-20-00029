% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP File Wrapper                                      %
% % provides interface to XLSX measurement list            %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe / Nick-André Träger                      %
% % graefe@is.mpg.de / traeger@is.mpg.de                   %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miepfile < handle
    
    properties
        filename = []; %stores MIEP file name
        importOptions = []; %stores import options
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepfile(inputfilename)
            %constructor, intitializes import options for miep file
            obj.filename = inputfilename;
            obj.importOptions = detectImportOptions(obj.filename);
        end
        
        function miepTable = readDate(obj, miepDate)
            %import full table for measurement date
            if isnumeric(miepDate)
                miepDate = num2str(miepDate);
            end
            try
                obj.importOptions.Sheet = miepDate;
                data = readtable(obj.filename, 'Sheet', obj.importOptions.Sheet, 'Basic', 1);  
                CommentVal = num2cell(data.Comment);
                try 
                    CommentVal(cellfun(@isnan,CommentVal)) = {[]};
                    data.Comment = CommentVal;
                    miepTable = data;
                catch
                    miepTable = data;
                end    
                
                %MATLAB 2017 Command% miepTable = readtable(obj.filename, obj.importOptions, 'Basic', 1);
                
            catch
                miepTable = [];
            end
        end
        
        function writeDate(obj, miepDate, miepTable)
            %write full table for measurement date
            if isnumeric(miepDate)
                miepDate = num2str(miepDate);
            end
            warning('off', 'MATLAB:xlswrite:AddSheet')
            outputData = [miepTable.Properties.VariableNames; table2cell(miepTable)];
            [~, ~] = xlswrite(obj.filename, outputData, miepDate);
        end
        
        function miepEntry = readEntry(obj, miepDate, miepNumber)
            %read inidividual entry from measurement table
            miepTable = obj.readDate(miepDate);
            if isempty(miepTable)
                miepEntry = [];
            else
                Measurement = miepTable.Measurement(miepTable.Measurement == miepNumber);
                MagicNumber = miepTable.MagicNumber(miepTable.Measurement == miepNumber);
                Comment = miepTable.Comment(miepTable.Measurement == miepNumber);   
                HeaderFile = miepTable.HeaderFile(miepTable.Measurement == miepNumber);
                if isempty(Measurement)
                    miepEntry = [];
                else
                    miepEntry = struct;
                    miepEntry.Measurement = Measurement;
                    miepEntry.MagicNumber = MagicNumber;
                    %miepEntry.Comment = Comment{1};
                    miepEntry.Comment = Comment;
                    miepEntry.HeaderFile = HeaderFile{1};
                end
            end
        end
        
        function writeEntry(obj, miepDate, miepEntry)
            %write individual entry to measurement table
            miepTable = obj.readDate(miepDate);
            %check if table already exists
            if isempty(miepTable)
                miepTable = table(miepEntry.Measurement, miepEntry.MagicNumber, {miepEntry.Comment}, {miepEntry.HeaderFile}, 'VariableNames', {'Measurement', 'MagicNumber', 'Comment', 'HeaderFile'});
            else
                %check if measurement is already present in table
                if isempty(obj.readEntry(miepDate, miepEntry.Measurement))
                    %append table
                    %miepTable(end+1,:) = {miepEntry.Measurement, miepEntry.MagicNumber, miepEntry.Comment, miepEntry.HeaderFile};
                    miepTable = [miepTable; struct2table(miepEntry)]; 
                else
                    %update table
                    miepTable(miepTable.Measurement == miepEntry.Measurement,:) = {miepEntry.Measurement, miepEntry.MagicNumber, miepEntry.Comment, miepEntry.HeaderFile};
                    %miepTable(miepTable.Measurement == miepEntry.Measurement,:) = struct2table(miepEntry);           
                end
                %sort table for ascending measurement number
                miepTable = sortrows(miepTable, 1);
            end
            %write to file
            obj.writeDate(miepDate, miepTable);
        end
    end
end