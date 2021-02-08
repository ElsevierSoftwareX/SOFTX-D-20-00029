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
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepfile(inputfilename)
            %constructor, intitializes miep file
            %if miep file does not exist, creat it
            if ~exist(inputfilename, 'file')
                if ~exist(fileparts(inputfilename), 'dir')
                    mkdir(fileparts(inputfilename))
                end
                writetable(table(), inputfilename, 'UseExcel', 0)
            end
            obj.filename = inputfilename;
        end
        
        function miepTable = readDate(obj, miepDate)
            %import full table for measurement date
            if isnumeric(miepDate)
                miepDate = num2str(miepDate);
            end
            try
                data = readtable(obj.filename, 'Sheet', miepDate, 'UseExcel', 0);
                CommentVal = num2cell(data.Comment);
                try
                    CommentVal(cellfun(@isnan,CommentVal)) = {[]};
                    data.Comment = CommentVal;
                    miepTable = data;
                catch
                    miepTable = data;
                end
            catch
                miepTable = [];
            end
        end
        
        function writeDate(obj, miepDate, miepTable)
            %write full table for measurement date
            if isnumeric(miepDate)
                miepDate = num2str(miepDate);
            end
            writetable(miepTable, obj.filename, 'Sheet', miepDate, 'UseExcel', 0)
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
                    if isempty(miepEntry.MagicNumber)
                        miepTable(miepTable.Measurement == miepEntry.Measurement,:) = {miepEntry.Measurement, 0, miepEntry.Comment, miepEntry.HeaderFile};
                    else
                        miepTable(miepTable.Measurement == miepEntry.Measurement,:) = {miepEntry.Measurement, miepEntry.MagicNumber, miepEntry.Comment, miepEntry.HeaderFile};
                    end
                    %miepTable(miepTable.Measurement == miepEntry.Measurement,:) = struct2table(miepEntry);
                end
                %sort table for ascending measurement number
                miepTable = sortrows(miepTable, 1);
            end
            %write to file
            obj.writeDate(miepDate, miepTable);
        end
        
        function resetEntry(obj, miepDate, miepNumber)
            %reset magic number and comment in miep entry
            miepEntry = obj.readEntry(miepDate, miepNumber);
            miepEntry.MagicNumber = 0;
            miepEntry.Comment = {[]};
            obj.writeEntry(miepDate, miepEntry)
        end
    end
end