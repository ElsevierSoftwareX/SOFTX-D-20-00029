<<<<<<< HEAD
% read STXM .xim files
%
% Optional Input: Region, Detector
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readXIM(obj, varargin)

%number of regions from header
numRegions = size(obj.header.Regions,2);

%check for optional inputs
switch nargin
    case 1
        %no input: first region, frist channel
        region = 1;
        channel = 1;
    case 2
        if numRegions == 1
            %single region: input is channel
            channel = varargin{1};
        else
            %multi region: input is region
            region = varargin{1};
            channel = 1;
        end
    case 3
        region = varargin{1};
        if ischar(varargin{2})
            %determine channel number if name is provided
            for i = 1:size(obj.header.Channels,2)
                if strcmp(obj.header.Channels(i).Name,varargin{2})
                    channel = i;
                end
            end
        else
            channel = varargin{2};
        end
end

%create filename
channelCode = char(96+channel); %channel a,b,c with 97 = a
if numRegions == 1
    %single region doesn't need region code
    filename = strcat(obj.basefile, '_', channelCode, '.xim');
else
    %multi region scan with region code
    filename = strcat(obj.basefile, '_', channelCode, num2str(region-1), '.xim');
end

%readfile
obj.dataStore(region).(obj.header.Channels(channel).Name) = dlmread(filename);
=======
% read STXM .xim files
%
% Optional Input: Region, Energy, Detector
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readXIM(obj, varargin)

%determine number of regions and energies
numRegions = size(obj.header.Regions, 2);
numEnergies = obj.header.StackAxis.Points;

%check for optional inputs
switch nargin
    case 1
        %no input: first region, first energy, frist channel
        region = 1;
        energy = 1;
        channel = 1;
    case 2
        region = varargin{1};
        energy = 1;
        channel = 1;
    case 3
        region = varargin{1};
        energy = varargin{2};
        channel = 1;
    case 4
        region = varargin{1};
        energy = varargin{2};
        %determine channel number if name is provided
        if ischar(varargin{3})
            for i = 1:size(obj.header.Channels,2)
                if strcmp(obj.header.Channels(i).Name,varargin{3})
                    channel = i;
                end
            end
        else
            channel = varargin{3};
        end
end



%create filename
channelCode = char(96+channel); %channel a,b,c with 97 = a
energyCode = sprintf('%03d', energy-1);
switch numRegions
    case 1
        switch numEnergies
            case 1
                %single region, single energy
                filename = strcat(obj.basefile, '_', channelCode, '.xim');
            otherwise
                %multi region, single energy scan with region code
                filename = strcat(obj.basefile, '_', channelCode, energyCode, '.xim');
        end
    otherwise %more than one energy
        switch numEnergies
            case 1
                %single region, multi energy scan with energy code
                filename = strcat(obj.basefile, '_', channelCode, num2str(region-1), '.xim');
            otherwise
                %multi region, multi energy scan
                %implement later on
        end
end

%readfile
obj.dataStore(region,energy).(obj.header.Channels(channel).Name) = dlmread(filename);
>>>>>>> Data-Import
