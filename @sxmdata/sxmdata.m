<<<<<<< HEAD
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % sxmdata class                                          %
% %                                                        %
% % encapsulates SXM data with import & processing         %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed) sxmdata < dynamicprops
    %the sxm data class is sealed
    
    properties
        %General properties
        magicNumber = []; %stores magic number for BBX import
    end
    
    properties (SetAccess = private)
        %Read only properties
        header = []; %stores the .hdr information
        basefile = []; %stores the base filename
        dataStore = []; %stores the imported data
        evalStore = []; %stores evaluation data
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = sxmdata(varargin)
            %constructor
            %optional inputs: path to header file
            
            %check for additional arguments to intialize command class
            switch nargin
                case 0
                    %do nothing
                case 1
                    %try to load header from input string
                    obj.basefile = strrep(varargin{1}, '.hdr', '');
                    obj.readHDR
            end
        end
        
        function disp(obj)
            %dispaly function
            disp(['SXM ', obj.header.Type, ' from ', obj.header.Label])
        end
        
        function output = data(obj, varargin)
            %provide transparent read & process operations to dataStore
            %optional input: channel, region
            %note inverse order to low level functions
            
            %parse input
            switch nargin
                case 1
                    channel = 1;
                    region = 1;
                case 2
                    channel = varargin{1};
                    region = 1;
                case 3
                    channel = varargin{1};
                    region = varargin{2};
            end
            %get channel name
            if isnumeric(channel)
                channel = obj.header.Channels(channel).Name;
            end
            %check for data presence
            if isempty(obj.dataStore(region).(channel))
                if strcmp(obj.header.Flags, 'Spectra')
                    %read XSP file
                    obj.readXSP
                else
                    switch channel
                        %low level channels
                        case 'APD'
                            %Transmission
                            %read XIM file
                            obj.readXIM(region, channel)
                        case 'VCO'
                            %Total Electron Yield
                            %read XIM file
                            obj.readXIM(region, channel)
                            %Time Machine channels
                        case 'BBX'
                            %Total Image
                            %read BBX file
                            obj.readBBX
                        case 'RawMovie'
                            %Direct Movie
                            %read BBX file
                            obj.readBBX
                        case 'Movie'
                            %Normalized Movie
                            %read BBX file
                            obj.readBBX
                    end
                end
            end
            %return data
            output = obj.dataStore(region).(channel);
        end
        
        function output = eval(obj, type, varargin)
            %provide transparent read & process operations to evalStore
            %input type: type
            %optional input: channel
            
            %check for evaluation result presence
            if isempty(obj.evalStore(1).(type))
                switch type
                    case 'FFT'
                        obj.evalFFT
                    case 'FrequencySpectrum'
                        obj.evalFrequencySpectrum
                end
            end
            %return data
            output = obj.evalStore.(type);
        end
    end
    
    methods (Access = private)
        %private methods
        
        function initDataStore(obj)
            %initializes dataStore depending on header information
            if strcmp(obj.header.Flags, 'Spectra')
                %init for Spectra
                obj.dataStore = struct;
                obj.dataStore.Energy = [];
                for channel = {obj.header.Channels.Name}
                    obj.dataStore.(channel{1}) = [];
                end
            else
                %init for Images
                for region = 1:size(obj.header.Regions,2)
                    for channel = {obj.header.Channels.Name}
                        obj.dataStore(region).(channel{1}) = [];
                    end
                end
                %check for BBX file
                if exist(strcat(obj.basefile,'.bbx'),'file')
                    obj.dataStore(1).BBX = [];
                    obj.dataStore(1).RawMovie = [];
                    obj.dataStore(1).Movie = [];
                    obj.initEvalStore
                end
            end
        end
        
        function initEvalStore(obj)
            %initializes evalStore for potential eval results
            obj.evalStore(1).FFT = [];
            obj.evalStore(1).FrequencySpectrum = [];
        end
    end
    
=======
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % sxmdata class                                          %
% %                                                        %
% % encapsulates SXM data with import & processing         %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef (Sealed) sxmdata < dynamicprops
    %the sxm data class is sealed
    
    properties
        %General properties
        magicNumber = []; %stores magic number for BBX import
    end
    
    properties (SetAccess = private)
        %Read only properties
        header = []; %stores the .hdr information
        basefile = []; %stores the base filename
        dataStore = []; %stores the imported data
        evalStore = []; %stores evaluation data
    end
    
    methods (Access = public)
        %public methods including constructor and display
        
        function obj = sxmdata(varargin)
            %constructor
            %optional inputs: path to header file
            
            %check for additional arguments to intialize command class
            switch nargin
                case 0
                    %do nothing
                case 1
                    %try to load header from input string
                    obj.basefile = strrep(varargin{1}, '.hdr', '');
                    obj.readHDR
            end
        end
        
        function disp(obj)
            %dispaly function
            disp(['SXM ', obj.header.Type, ' from ', obj.header.Label])
        end
        
        function output = data(obj, varargin)
            %provide transparent read & process operations to dataStore
            %optional input: channel, region
            %note inverse order to low level functions
            
            %parse input
            switch nargin
                case 1
                    channel = 1;
                    region = 1;
                case 2
                    channel = varargin{1};
                    region = 1;
                case 3
                    channel = varargin{1};
                    region = varargin{2};
            end
            %get channel name
            if isnumeric(channel)
                channel = obj.header.Channels(channel).Name;
            end
            %check for data presence
            if isempty(obj.dataStore(region).(channel))
                if strcmp(obj.header.Flags, 'Spectra')
                    %read XSP file
                    obj.readXSP
                else
                    switch channel
                        %low level channels
                        case 'APD'
                            %Transmission
                            %read XIM file
                            obj.readXIM(region, channel)
                        case 'VCO'
                            %Total Electron Yield
                            %read XIM file
                            obj.readXIM(region, channel)
                            %Time Machine channels
                        case 'BBX'
                            %Total Image
                            %read BBX file
                            obj.readBBX
                        case 'RawMovie'
                            %Direct Movie
                            %read BBX file
                            obj.readBBX
                        case 'Movie'
                            %Normalized Movie
                            %read BBX file
                            obj.readBBX
                    end
                end
            end
            %return data
            output = obj.dataStore(region).(channel);
        end
        
        function output = eval(obj, type, varargin)
            %provide transparent read & process operations to evalStore
            %input type: type
            %optional input: channel
            
            %check for evaluation result presence
            if isempty(obj.evalStore(1).(type))
                switch type
                    case 'FFT'
                        obj.evalFFT
                    case 'FrequencySpectrum'
                        obj.evalFrequencySpectrum
                end
            end
            %return data
            output = obj.evalStore.(type);
        end
    end
    
    methods (Access = private)
        %private methods
        
        function initDataStore(obj)
            %initializes dataStore depending on header information
            if strcmp(obj.header.Flags, 'Spectra')
                %init for Spectra
                obj.dataStore = struct;
                obj.dataStore.Energy = [];
                for channel = {obj.header.Channels.Name}
                    obj.dataStore.(channel{1}) = [];
                end
            else
                %init for Images
                for region = 1:size(obj.header.Regions,2)
                    for channel = {obj.header.Channels.Name}
                        obj.dataStore(region).(channel{1}) = [];
                    end
                end
                %check for BBX file
                if exist(strcat(obj.basefile,'.bbx'),'file')
                    obj.dataStore(1).BBX = [];
                    obj.dataStore(1).RawMovie = [];
                    obj.dataStore(1).Movie = [];
                    obj.initEvalStore
                end
            end
        end
        
        function initEvalStore(obj)
            %initializes evalStore for potential eval results
            obj.evalStore(1).FFT = [];
            obj.evalStore(1).FrequencySpectrum = [];
        end
    end
    
>>>>>>> 6675fab2daf038d09990f6374318b264ad990189
end