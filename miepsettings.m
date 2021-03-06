% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Settings                                          %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gr?fe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miepsettings
    %stores settings for MIEP
    
    properties
        inputFolder = []; %data input folder
        miepFile = []; %measurement master list
        dataFolder = []; %sxmdata storage folder
        outputFolder = []; %data export folder
        imageColorMap = []; %color map for images
        movieColorMap = []; %color map for movies
        kSpaceColorMap = []; %color map for k-space
        frameRate = []; %frame rate for videos
    end
    
    properties (SetAccess = private)
        colorMaps = {'parula', 'jet', 'hsv', 'hot', 'cool', 'spring', 'summer', 'autumn', 'winter', 'gray', 'bone', 'copper', 'pink', 'lines'}; %available color maps
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
                try
                    mkdir(value)
                catch
                    value = [];
                end  
            end
            obj.dataFolder = value;
        end
        function obj = set.outputFolder(obj, value)
            if ~exist(value, 'dir') && ~isempty(value)
                try
                    mkdir(value)
                catch
                    value = [];
                end 
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