% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Icons                                             %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe (graefe@is.mpg.de)                       %
% % Felix Groß (fgross@is.mpg.de)                          %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef miepicons
    %stores settings for MIEP
    
    properties %(Access = private)
        iconDir = [];
        backgroundColor = [];
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = miepicons(backgroundColor)
            %find curent icon directory
            miepDir = split(which('miepgui.m'), '@');
            obj.iconDir = fullfile(miepDir{1}, '@miepicons');
            obj.backgroundColor = backgroundColor;
        end
    end
    
    properties (Dependent)
        %Dependent properties: icons that are read transparently
        file_open
        help_ex
        pause
        refresh
        run
        welcome
    end
    methods
        %methods that load files
        function icon = get.file_open(obj)
            icon = obj.readIcon('file_open.png');
        end
        function icon = get.help_ex(obj)
            icon = obj.readIcon('help_ex.png');
        end
        function icon = get.pause(obj)
            icon = obj.readIcon('pause.png');
        end
        function icon = get.refresh(obj)
            icon = obj.readIcon('refresh.png');
        end
        function icon = get.run(obj)
            icon = obj.readIcon('run.png');
        end
        function icon = get.welcome(obj)
            icon = obj.readIcon('welcome.png');
        end
    end
    
    methods (Access = private)
        %private support functions
        function icon = readIcon(obj, iconName)
            image = imread(fullfile(obj.iconDir, iconName), 'Background', obj.backgroundColor);
            [img, map] = rgb2ind(image, 65535);
            icon = ind2rgb(img, map);
        end
    end
end