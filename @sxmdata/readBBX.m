% read STXM .bbx files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readBBX(obj)
%check provided input
switch size(varargin)
    case 1
        %only filename is provided
        filename = varargin{1};
        %ask for magic number
        magicn = inputdlg('Magic Number?');
        magicn = str2double(magicn{:});
    case 2
        %filename and magic number are provided
        filename = varargin{1};
        magicn = varargin{2};
end

%open file
filename = strcat(obj.basefile, '.bbx');
fid = fopen(filename, 'r');

%read header
nImages = fread(fid, 1, 'int', 'b');
width = fread(fid, 1, 'int', 'b');
height = fread(fid, 1, 'int', 'b');
images = zeros(height, width, nImages);

%read body
for i=1:nImages
    for j=1:width
        col = fread(fid, height, 'int', 'b');
        images(1:height,j,i) = flipud(col);
    end
end

%close file
fclose(fid);


%calculate image times and normalize
obj.dataStore(1).BBX = mean(images,3);
sortkey = mod((1:nImages)*magicn,nImages)+1;
obj.dataStore(1).RawMovie = zeros(height, width, nImages);
obj.dataStore(1).Movie = zeros(height, width, nImages);
for i=1:nImages
    obj.dataStore(1).RawMovie(:,:,sortkey(i)) = images(:,:,i);
    obj.dataStore(1).Movie = images(:,:,i)./obj.dataStore(1).BBX;
end

end