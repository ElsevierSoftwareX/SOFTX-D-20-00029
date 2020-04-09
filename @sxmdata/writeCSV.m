function writeCSV(obj, varargin)
%Function to export MIEP data to CSV

if isempty(varargin)
    %Get directory from user input
    outpath = uigetdir([getenv('USERPROFILE') '\documents\'], 'Select Output Folder');
    if outpath == 0
        return
    end
elseif length(varargin) == 1
    
    outpath = [varargin{1} '\Export'];
else
    errordlg('Please enter Output Path', 'Error')
    return
end

%get scan name MPI_ from obj
scanname = split(obj.header.Label, '.');
scannumber = scanname{1};
outfolder = fullfile(outpath,scannumber);
%Create the directory if it does not exist
if ~exist(outfolder, 'dir')
    mkdir(outfolder)
end

%prepare file name
CSVFile = [outfolder '\' scannumber];

%export data
exportData(obj, CSVFile, scannumber)

fclose('all');
end


function exportData(obj, CSVFile, scannumber)
flag = obj.header.Flags;
header{1} = [flag ' ' scannumber];

%if spectrum export all channels, APD and VCO
if strcmp(flag, 'Spectra') || strcmp(flag, 'Multi-Region Spectra')
    energy = obj.data('Energy');
    
    
    header{2} = 'Energy';
    dataMat = energy;
    
    for i = 1:length(obj.channels)
        for j = 1:length(obj.header.Regions)
            header{2} = [header{2} ',' obj.channels{i} ' Region ' num2str(j)];
            dataMat = [dataMat obj.data(obj.channels{i},1,j)];
        end
    end
    
    %write to file
    writeFile(header, dataMat, [CSVFile '.txt'])
    
elseif strcmp(flag, 'Image') || strcmp(flag, 'Image Stack') 
    %if image, export BBX and APD
    for i = 1:length(obj.channels)
        for j = 1:length(obj.energies)
            header{2} = [obj.channels{i} ' ' obj.energies{j} ', Pixel by Pixel'];
            dataMat = obj.data(obj.channels{i}, j);
            writeFile(header, dataMat, [CSVFile '_' obj.channels{i} '_' obj.energies{j} '.txt'])
        end
    end
    
    %If movie, also export RawMovie and Normalized Movie
    if any(strcmp(obj.channels, 'BBX'))
        %first movie and raw movie export
        
        %Define Header for export file
        headers = {'Raw BBX Frame, Pixel by Pixel', 'Normalized BBX Frame, Pixel by Pixel',...
            'FFT Power, Pixel by Pixel', 'FFT Amplitude, Pixel by Pixel',...
            'FFT Phase, Pixel by Pixel', 'FFT Frequency', 'FFT Power'...
            'k-Space', 'kx', 'ky'};
        %Define export data
        dataMats = {obj.data('RawMovie'), obj.data('Movie'),...
            obj.eval('FFT').Power, obj.eval('FFT').Amplitude,...
            obj.eval('FFT').Phase, obj.eval('FrequencySpectrum').Frequency, obj.eval('FrequencySpectrum').Power,...
            obj.eval('SpatialFFT').kImages, obj.eval('SpatialFFT').kxAxis, obj.eval('SpatialFFT').kyAxis};
        %define file ending
        fileEnding = {'RawMovie_t', 'Movie_t',...
            'Power_f', 'Amplitude_f',...
            'Phase_f', 'Frequency', 'Power',...
            'k_space_f', 'kx', 'ky'};
        %export each property
        for i = 1:length(headers)
            header{2} = headers{i};
            writeFile(header, dataMats{i}, [CSVFile '_' fileEnding{i} '.txt'])    
        end
    end
end

end

function writeFile(header, dataMat, CSVFile)
%export normal data
if size(dataMat,3) == 1
    writeHeader(header, CSVFile)
    writematrix(dataMat,CSVFile,'WriteMode','append')
else
    %export 3d data
    for i=1:size(dataMat,3)
        %insert Frame number to header
        numheader{1} = insertAfter(header{1},'Frame',[' ' num2str(i)]);
        numheader{2} = header{2};
        %insert Frame number into file name
        numCSVFile = insertBefore(CSVFile,'.',['_' num2str(i)]);
        
        %print header
        writeHeader(numheader, numCSVFile)

        %append Data
        writematrix(dataMat(:,:,i),numCSVFile,'WriteMode','append')
        
    end
    
end


end

function writeHeader(header, CSVFile)
fileID = fopen(CSVFile, 'w');
for i = 1:length(header)
    fprintf(fileID,'%%%s\r\n', header{i});
end
fprintf(fileID,'%%ENDOFHEADER\r\n\r\n');
fclose(fileID);
end



