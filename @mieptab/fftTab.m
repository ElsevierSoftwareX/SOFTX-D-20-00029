% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP FreqSpectrum Tab                                  %
% %                                                        %
% % Image Tab Class Subset                                 %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Nick-André Träger                                      %
% % traeger@is.mpg.de                                      %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function fftTab(obj, miepGUIObj)
%% intialize / draws the image tab
%determine drawing area
drawingArea = obj.tabHandle.Position - [-2 -3 5 30]; %correct MATLAB madness?

%draw energy selector list
Pos(1) = 5; %position left
Pos(2) = drawingArea(4) - 20 - 5; % position bottom
Pos(3) = drawingArea(3)/2 - 2*5; %width
Pos(4) = 20; %height
obj.uiHandles.energyList = uicontrol(obj.tabHandle, 'Style', 'popupmenu', 'String', 'Select Energy ...', 'Units', 'pixels', 'Position', Pos, 'Callback', @imageSelect);
energies = miepGUIObj.workData.energies;
obj.uiHandles.energyList.String = energies;
if max(size(energies)) == 1
    obj.uiHandles.energyList.Enable = 'off';
end

%draw open figure
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = 90; %width
Pos(4) = 30; %height
obj.uiHandles.run = uicontrol(obj.tabHandle, 'Style', 'pushbutton', 'Units', 'pixels', 'Position', Pos, 'Callback', @openinFigure, 'String', 'Open in Figure');

drawnow % fix for stuttering

%draw image axes and image
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 3*5 - 20; %height

obj.uiHandles.imageAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);

fftDraw;

    function fftDraw(varargin)
        f = miepGUIObj.workData.eval('FrequencySpectrum').Frequency/1e9;
        amplitude = miepGUIObj.workData.eval('FrequencySpectrum').Power;
        amplitude = amplitude(f>0);
        f = f(f>0);
        
        try
            if ishandle(obj.uiHandles.imagePlot)
                obj.uiHandles.imagePlot.YData = amplitude;
                obj.uiHandles.imagePlot.XData = f;
            end
        catch
            ax = obj.uiHandles.imageAxes;
            
            
            obj.uiHandles.imagePlot = plot(ax, f, amplitude);
            
            grid(ax, 'on')
            
            ax.XLabel.String = '{\it f} [GHz]';
            ax.YLabel.String = 'Spectral Density [a.u.]';
            
        end
    end

    function openinFigure(~, ~, ~)
        
        newFigure = figure('Numbertitle', 'off', 'Name', 'FFT Amplitude');
        newAxis = copyobj(obj.uiHandles.imageAxes, newFigure);
        set(newAxis,'Units','normalized','Position',[0.13 0.11 0.775 0.815])
        
    end

end





