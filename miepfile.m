% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP File Wrapper                                      %
% % provides interface to XSLX measurement list            %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miepfile < handle
    
    properties
        filename = []; %stores MIEP file name
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepfile(inputfilename)
            %constructor
            obj.filename = inputfilename;
        end
        
        function miepTable = readDate(obj, miepDate)
            %import full table for measurement date
            [~, ~, importData] = xlsread(obj.filename, miepDate);
            miepTable = cell2table(importData(2:end,:), 'VariableNames', importData(1,:));
        end
        
        function writeDate(obj, miepDate, miepTable)
            %write full table for measurement date
            outputData = [miepTable.Properties.VariableNames; table2cell(miepTable)];
            xlswrite(obj.filename, outputData, miepDate);
        end
        
        function miepEntry = readEntry(obj, miepDate, miepNumber)
            %write inidividual entry from measurement table
            miepTable = obj.readDate(miepDate);
            Measurement = miepTable.Measurement(miepTable.Measurement == miepNumber);
            MagicNumber = miepTable.MagicNumber(miepTable.Measurement == miepNumber);
            Comment = miepTable.Comment(miepTable.Measurement == miepNumber);
            HeaderFile = miepTable.HeaderFile(miepTable.Measurement == miepNumber);
            if ismepty(Measurement)
                miepEntry = [];
            else
                miepEntry = struct;
                miepEntry.Measurement = Measurement;
                miepEntry.MagicNumber = MagicNumber;
                miepEntry.Comment = Comment{1};
                miepEntry.HeaderFile = HeaderFile{1};
            end
        end
        
        function writeEntry(obj, miepDate, miepNumber, miepEntry)
            %write individual entry to measurement table
            oldMiepTable = obj.readDate(miepDate);
            oldMiepEntry = obj.readEntry(miepDate, miepNumber);
            if isempty(oldMiepEntry)
                %append table
            else
                %update table
            end
        end
    end
end