function writeMP4(obj, varargin)
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
MP4File = [outfolder '\' scannumber];

%export data
exportData(obj, MP4File, settings)

fclose('all');
end

function exportData(obj, MP4File, settings)
%function to call all the individual export functions for different
%categories (spectrum, image, raw movie, normalized movie, ect...)

%if image, get x and y axis
xMin = obj.header.Regions.PAxis.Min;
xMax = obj.header.Regions.PAxis.Max;
xPoints = obj.header.Regions.PAxis.Points;

yMin = obj.header.Regions.QAxis.Min;
yMax = obj.header.Regions.QAxis.Max;
yPoints = obj.header.Regions.QAxis.Points;

x = linspace(xMin, xMax, xPoints)-xMin;
y = linspace(yMin, yMax, yPoints)-yMin;

%Export all the different mieptab 
writeFFTMovie(x, y, obj.eval('FFT'), [MP4File '_' 'FFTMovie' '.mp4'], settings)
writeMovie(x, y, obj.data('Movie'), [MP4File '_' 'NormMovie' '.mp4'], settings)
writeMovie(x, y, obj.data('RawMovie'), [MP4File '_' 'RawMovie' '.mp4'], settings)

end


function writeMovie(x, y, data, MP4File, settings)
    %function to export normalized movie and raw movie
    fig = figure('visible', 'off');
    ax = axes(fig);
    
    v = VideoWriter(MP4File, 'MPEG-4');

    if ~strcmp(settings, 'standard')
        v.FrameRate = size(data,3)/(0.75 * (30/settings.frameRate));
    else    
        v.FrameRate = size(data,3)/0.75;
    end
        
    if size(data,3) > 30
        v.FrameRate = v.FrameRate/10;
    end
    open(v);
    
    for i = 1:size(data,3)
        surf(ax, x, y, data(:,:,i), 'edgecolor', 'none');

        ax.View = [0, 90];
        ax.XLim = [min(x) max(x)];
        ax.YLim = [min(y) max(y)];
        ax.Layer = 'Top';
        ax.Box = 'on';
        ax.DataAspectRatio = [1 1 1];
        ax.TickDir = 'out';
        ax.XLabel.String = '{\it x} [µm]';
        ax.YLabel.String = '{\it y} [µm]';
        
        %fix for axis stuttering
        zlim = max(abs(data(:)));
        ax.ZLim = [-zlim zlim];
        
        if ~strcmp(settings, 'standard')
            colormap(settings.colorMaps{settings.movieColorMap})
        end
        
        writeVideo(v,getframe(fig));
    end
    

    close(v);
    close(fig)
end
function writeFFTMovie(x, y, fft, MP4File, settings)
    %function to export fft movie including all frequencies
    fig = figure('visible', 'off');
    ax = axes(fig);
    
    freq = fft.Frequency;
    nFrames = 30;
    
    shift = linspace(0,2*pi,nFrames+1);
    shift(end) = [];
    data = NaN([size(fft.Amplitude) nFrames]);
    for i = 1:nFrames
        data(:,:,:,i) = fft.Amplitude.*sin(fft.Phase + shift(i));
    end
    
    exportNum = selectFreq(freq);
    
    for i = exportNum
        
        v = VideoWriter(insertBefore(MP4File,'.',['_' sprintf('%.2e',freq(i))]), 'MPEG-4');
        
        if ~strcmp(settings, 'standard')
            v.FrameRate = nFrames/(0.75 * (30/settings.frameRate));
        else    
            v.FrameRate = nFrames/0.75;
        end

        open(v);
        
        for j = 1:size(data,4)
            surf(ax, x, y, data(:,:,i,j), 'edgecolor', 'none');

            ax.View = [0, 90];
            ax.XLim = [min(x) max(x)];
            ax.YLim = [min(y) max(y)];
            ax.Layer = 'Top';
            ax.Box = 'on';
            ax.DataAspectRatio = [1 1 1];
            ax.TickDir = 'out';
            ax.XLabel.String = '{\it x} [µm]';
            ax.YLabel.String = '{\it y} [µm]';

            %fix for axis stuttering
            zlim = max(abs(data(:)));
            ax.ZLim = [-zlim zlim];

            if ~strcmp(settings, 'standard')
                colormap(settings.colorMaps{settings.movieColorMap})
            end
            
            writeVideo(v,getframe(fig));
        end
    close(v)
    end
    
    close(fig)
end

%% gui functions
function selection = selectFreq(freq)
    %determine position from screen size and open dialog
    screenSize = get(0, 'ScreenSize');
    dSize = [300 55]; %figure width height
    dPos(1) = screenSize(3)/2-dSize(1)/2; %position left
    dPos(2) = screenSize(4)/2-dSize(2)/2; %position bottom
    dPos(3) = dSize(1); %width
    dPos(4) = dSize(2); %height
    d = dialog('Position', dPos, 'Name', 'Select FFT Export Frequency');

    %next button
    butPos(3) = 50; %width
    butPos(4) = 20; %height
    butPos(1) = dPos(3)/2 - butPos(3)/2 - 30; %position left
    butPos(2) = 5; %position bottom
    uicontrol(d, 'Style', 'pushbutton', 'String', 'Select', 'Position', butPos, 'Callback', @guiSelect);
    
    %all button
    butPos(3) = 50; %width
    butPos(4) = 20; %height
    butPos(1) = dPos(3)/2 - butPos(3)/2 + 30; %position left
    butPos(2) = 5; %position bottom
    uicontrol(d, 'Style', 'pushbutton', 'String', 'All', 'Position', butPos, 'Callback', @guiAll);
    
    %second data selector
    curPos(1) = 5;
    curPos(2) = butPos(2) + butPos(4) + 5;
    curPos(3) = dSize(1) - 2*5;
    curPos(4) = 20;
    select = uicontrol(d, 'Style', 'popup', 'Position', curPos, 'String', sprintfc('%.2f GHz',freq/1e9),'Value',ceil(length(freq)/2+1));


    %wait for selection
    uiwait(d)

    if ~exist('selection', 'var')
        selection = [];
    end
    
    function guiSelect(~, ~, ~)
        %evaluate dialog input
        selection = select.Value;
        delete(d)
    end
    function guiAll(~, ~, ~)
        %evaluate dialog input
        selection = 1:length(freq);
        delete(d)
    end
end