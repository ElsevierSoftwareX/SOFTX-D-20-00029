function writeJPG(obj, varargin)
%Function to export MIEP data to JPG/MP4

if isempty(varargin)
    %Get directory from user input
    outpath = uigetdir([getenv('USERPROFILE') '\documents\'], 'Select Output Folder');
    if outpath == 0
        return
    end
    try
        load('settings.mat', 'settings')
        if ~isobject(settings)
            settings = 'standard';
        end
    catch
        settings = 'standard';
    end
elseif length(varargin) == 1
    outpath = varargin{1}.outputFolder;
    settings = varargin{1};
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
JPGFile = [outfolder '\' scannumber];

%export data
exportData(obj, JPGFile, settings)

fclose('all');
end

function exportData(obj, JPGFile, settings)
%function to call all the individual export functions for different
%categories (spectrum, image, raw movie, normalized movie, ect...)
flag = obj.header.Flags;

%if spectrum export all channels, APD and VCO
if contains(flag, 'Spectra')
    energy = obj.data('Energy');
    for i = 1:length(obj.channels)
        for j = 1:length(obj.header.Regions)
            %define axis labels
            config.xLabel = obj.header.Regions(j).PAxis.Name;
            config.xUnit = obj.header.Regions(j).PAxis.Unit;
            config.yLabel = 'Intensity';
            config.yUnit = obj.header.Channels(i).Unit;
            %and data to plot
            dataMat = obj.data(obj.channels{i},1,j);
            
            %write to file
            writeImage(obj, energy, [], dataMat, config, [JPGFile '_' obj.channels{i} '_Region_' num2str(j) '.jpg'], settings)
        end
    end
    
elseif contains(flag, 'Image')
    %if image, get x and y axis
    xMin = obj.header.Regions.PAxis.Min;
    xMax = obj.header.Regions.PAxis.Max;
    xPoints = obj.header.Regions.PAxis.Points;

    yMin = obj.header.Regions.QAxis.Min;
    yMax = obj.header.Regions.QAxis.Max;
    yPoints = obj.header.Regions.QAxis.Points;

    x = linspace(xMin, xMax, xPoints)-xMin;
    y = linspace(yMin, yMax, yPoints)-yMin;
    
    %export BBX and APD
    for i = 1:length(obj.channels)
        for j = 1:length(obj.energies)
            dataMat = obj.data(obj.channels{i}, j);
            writeImage(obj, x, y, dataMat, [], [JPGFile '_' obj.channels{i} '_' obj.energies{j} '.jpg'], settings)
        end
    end
        
    
    if any(strcmp(obj.channels, 'BBX'))
        %Export all the different mieptab 
        writeHSV(x, y, obj.eval('FFT'), obj.eval('FrequencySpectrum').Frequency, [JPGFile '_' 'HSV' '.jpg'])
        writeFFT(obj.eval('FrequencySpectrum'), [JPGFile '_' 'FrequencySpectrum' '.jpg'])
        writekSpace(obj.eval('SpatialFFT'), obj.eval('FrequencySpectrum').Frequency, [JPGFile '_' 'kSpace' '.jpg'], settings)
 
    end

end

end


function writeImage(obj, x, y, dataMat, config, JPGFile, settings)
%Function to export the image tab as pictures
flag = obj.header.Flags;

fig = figure('visible', 'off');
ax = axes(fig);

if contains(flag, 'Spectra')
    plot(ax, x, dataMat)
    ax.TickDir = 'out';
    ax.XLabel.String = [config.xLabel ' [' config.xUnit ']'];
    ax.YLabel.String = [config.yLabel ' [' config.yUnit ']'];
    
elseif contains(flag, 'Image')
    surf(ax, x, y, dataMat, 'edgecolor', 'none');
    ax.View = [0, 90];
    ax.XLim = [min(x) max(x)];
    ax.YLim = [min(y) max(y)];

    ax.Box = 'on';
    ax.DataAspectRatio = [1 1 1];
    ax.TickDir = 'out';
    ax.Layer = 'top';

    ax.XLabel.String = '{\it x} [µm]';
    ax.YLabel.String = '{\it y} [µm]';
    
    if ~strcmp(settings, 'standard')
        colormap(settings.colorMaps{settings.imageColorMap})
    end
end

saveas(fig,JPGFile)
close(fig)
end
function writeHSV(x, y, data, freq, JPGFile)
    %function to export hsv picture
    fig = figure('visible', 'off');
    ax = axes(fig);
    
    for i = 1:length(freq)
        %calulate the hsv picture
        clear hsv
        hue = (data.Phase(:,:,i)+(8/8)*pi)/2/pi;
        sat = ones(size(hue,1),size(hue,2));
        val = (data.Amplitude(:,:,i))/max(max(data.Amplitude(:,:,i)));
        hsv(:,:,1) = hue;
        hsv(:,:,2) = sat;
        hsv(:,:,3) = val;

        %and convert it to rgb
        imageData = hsv2rgb(hsv);

        %since a Matlab image has its pixel position in the middle
        %of the pixel, but a surface plot has its pixel position at
        %the lower left corner, we need to make the data surface
        %plot compatible
        %we do that by giving each pixel a unique value: 1, 2, 3...
        %the color is added by adjusting the color bar so that
        %every pixel has the correct color

        colbar = reshape(imageData, [], 3);
        colData = reshape(1:size(colbar,1), size(imageData,1), size(imageData,2));

        %now we plot the surface and add the colorbar
        surf(ax, x, y, colData, 'edgecolor', 'none');
        colormap(ax, colbar)

        ax.View = [0, 90];
        ax.XLim = [min(x) max(x)];
        ax.YLim = [min(y) max(y)];
        ax.Layer = 'Top';
        ax.Box = 'on';
        ax.DataAspectRatio = [1 1 1];
        ax.TickDir = 'out';
        ax.XLabel.String = '{\it x} [µm]';
        ax.YLabel.String = '{\it y} [µm]';
        
        saveas(fig,insertBefore(JPGFile,'.',['_' sprintf('%.2e',freq(i))]))
    end
    close(fig)
end
function writekSpace(data, freq, JPGFile, settings)
%functoin to export all k-space frequencie pictures
kx = data.kxAxis;
ky = data.kyAxis;
kImages = data.kImages;
fig = figure('visible', 'off');
ax = axes(fig);

for i = 1:length(freq)
    surf(ax, kx, ky, abs(kImages(:,:,i)), 'edgecolor', 'none');
    ax.View = [0, 90];
    ax.PlotBoxAspectRatio = [1 1 1];
    ax.XLim = [min(kx) max(kx)];
    ax.YLim = [min(ky) max(ky)];

    colorbar(ax)


    %add ticks, labels, ect.
    ax.Box = 'on';
    ax.TickDir = 'out';
    ax.Layer = 'top';
    ax.XLabel.String = '{\it k_x} [1/µm]';
    ax.YLabel.String = '{\it k_y} [1/µm]';
    
    if ~strcmp(settings, 'standard')
        colormap(settings.colorMaps{settings.kSpaceColorMap})
    end
    
    saveas(fig,insertBefore(JPGFile,'.',['_' sprintf('%.2e',freq(i))]))
end

close(fig)
end
function writeFFT(data, JPGFile)
%function to export movie fft spectrum
f = data.Frequency;
power = data.Power;

power = power(f>0);
f = f(f>0);

fig = figure('visible', 'off');
ax = axes(fig);

plot(ax, f, power);

grid(ax, 'on')

ax.XLabel.String = '{\it f} [GHz]';
ax.YLabel.String = 'Spectral Density [a.u.]';

saveas(fig,JPGFile)
close(fig)
end