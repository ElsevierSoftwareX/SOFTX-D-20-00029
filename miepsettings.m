% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Settings                                          %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miepsettings
    %stores settings for MIEP
    
    properties
        inputFolder = []; %data input folder
        miepFile = []; %measurement master list
        dataFolder = []; %sxmdata storage folder
        outputFolder = []; %data export folder
    end
    
    methods
        %property set functions
        
        %check for folders to exist or create them
        function obj = set.inputFolder(obj, value)
            if exist(value, 'dir') && ~isempty(value)
                obj.inputFolder = value;
            end
        end
        function obj = set.dataFolder(obj, value)
            if ~exist(value, 'dir') && ~isempty(value)
                mkdir(value)
            end
            obj.dataFolder = value;
        end
        function obj = set.outputFolder(obj, value)
            if ~exist(value, 'dir') && ~isempty(value)
                mkdir(value)
            end
            obj.outputFolder = value;
        end
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepsettings
            %so far there is nothing to do in the constructor
        end
    end
end