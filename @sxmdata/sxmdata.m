% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % sxmdata class                                          %
% %                                                        %
% % encapsulates SXM data with import & processing         %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gr�fe                                          %
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
        dataStore = []; %stores the imported data (region,energy)
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
            %optional input: channel, energy, region
            %note inverse order to low level functions
            
            %parse input
            switch nargin
                case 1
                    channel = 1;
                    energy = 1;
                    region = 1;
                case 2
                    channel = varargin{1};
                    energy = 1;
                    region = 1;
                case 3
                    channel = varargin{1};
                    energy = varargin{2};
                    region = 1;
                case 4
                    channel = varargin{1};
                    energy = varargin{2};
                    region = varargin{3};
            end
            %get channel name
            if isnumeric(channel)
                channel = obj.header.Channels(channel).Name;
            end
            %check for data presence
            if isempty(obj.dataStore(region,energy).(channel))
                if strcmp(obj.header.Flags, 'Spectra')
                    %read XSP file
                    obj.readXSP(region)
                else
                    switch channel
                        %low level channels
                        case 'APD'
                            %Transmission
                            %read XIM file
                            obj.readXIM(region, energy, channel)
                        case 'VCO'
                            %Total Electron Yield
                            %read XIM file
                            obj.readXIM(region, energy, channel)
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
            if isempty(obj.evalStore(1,1).(type))
                switch type
                    case 'FFT'
                        obj.evalFFT
                    case 'FrequencySpectrum'
                        obj.evalFrequencySpectrum
                end
            end
            %return data
            output = obj.evalStore(1,1).(type);
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
                for region = 1:size(obj.header.Regions,2)
                    for channel = {obj.header.Channels.Name}
                        obj.dataStore(region).(channel{1}) = [];
                    end
                end
            else
                %init for Images
                for region = 1:size(obj.header.Regions,2)
                    for energy = 1:obj.header.StackAxis.Points
                        for channel = {obj.header.Channels.Name}
                            obj.dataStore(region,energy).(channel{1}) = [];
                        end
                    end
                end
                %check for BBX file
                if exist(strcat(obj.basefile,'.bbx'),'file')
                    obj.dataStore(1,1).BBX = [];
                    obj.dataStore(1,1).RawMovie = [];
                    obj.dataStore(1,1).Movie = [];
                    obj.initEvalStore
                end
            end
        end
        
        function initEvalStore(obj)
            %initializes evalStore for potential eval results
            %current time machine only runs on single region/energy
            obj.evalStore(1,1).FFT = [];
            obj.evalStore(1,1).FrequencySpectrum = [];
        end
    end
    
end