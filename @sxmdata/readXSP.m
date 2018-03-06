% read STXM .xsp files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readXSP(obj)
    filename = fullfile(obj.basefile, '_0.xsp');
    data = dlmread(filename);
    obj.dataStore.Energy = data(:,1);
    for i=1:size(data,2)-1
        ChannelName = obj.header.Channels(i).Name;
        obj.dataStore.(ChannelName) = data(:,i+1);
    end
end