<<<<<<< HEAD
% read STXM .bbx files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readBBX(obj)
%check if magic numbmer is set, otherwise ask
if isempty(obj.magicNumber)
    queryString = ['Magic Number for ', obj.header.Label, '?'];
    obj.magicNumber = str2double(inputdlg(queryString));
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
sortkey = mod((1:nImages)*obj.magicNumber,nImages)+1;
obj.dataStore(1).RawMovie = zeros(height, width, nImages);
obj.dataStore(1).Movie = zeros(height, width, nImages);
for i=1:nImages
    obj.dataStore(1).RawMovie(:,:,sortkey(i)) = images(:,:,i);
    obj.dataStore(1).Movie(:,:,sortkey(i)) = images(:,:,i)./obj.dataStore(1).BBX;
end

=======
% read STXM .bbx files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readBBX(obj)
%check if magic numbmer is set, otherwise ask
if isempty(obj.magicNumber)
    queryString = ['Magic Number for ', obj.header.Label, '?'];
    obj.magicNumber = str2double(inputdlg(queryString));
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
sortkey = mod((1:nImages)*obj.magicNumber,nImages)+1;
obj.dataStore(1).RawMovie = zeros(height, width, nImages);
obj.dataStore(1).Movie = zeros(height, width, nImages);
for i=1:nImages
    obj.dataStore(1).RawMovie(:,:,sortkey(i)) = images(:,:,i);
    obj.dataStore(1).Movie(:,:,sortkey(i)) = images(:,:,i)./obj.dataStore(1).BBX;
end

>>>>>>> 6675fab2daf038d09990f6374318b264ad990189
end