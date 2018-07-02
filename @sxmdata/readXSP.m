% read STXM .xsp files
%
% Optional Input: Region
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readXSP(obj, varargin)

%parse input
switch nargin
    case 1
        region = 0;
    case 2
        region = varargin{1} - 1;
end

%read data
filename = strcat(obj.basefile, '_', num2str(region), '.xsp');
data = dlmread(filename);
obj.dataStore.Energy = data(:,1);
for i=1:size(data,2)-1
    ChannelName = obj.header.Channels(i).Name;
    obj.dataStore(region+1).(ChannelName) = data(:,i+1);
end

end