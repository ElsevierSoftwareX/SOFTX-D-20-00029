% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Spectrum Tab                                      %
% %                                                        %
% % Draws a tab to show spectra                            %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showSpectrum(obj, miepGUIObj)

%determine drawing area
drawingArea = obj.tabHandle.Position;

%draw spectrum axes
Pos(1) = 5; %position left
Pos(2) = 5; % position bottom
Pos(3) = drawingArea(3) - 2*5; %width
Pos(4) = drawingArea(4) - 2*5; %height
obj.uiHandles.spectrumAxes = axes(obj.tabHandle, 'Units', 'pixels', 'OuterPosition', Pos);
obj.uiHandles.spectrumAxes.XLabel.String = 'Energy [eV]';
obj.uiHandles.spectrumAxes.YLabel.String = 'Intensity [counts]';
obj.uiHandles.spectrumAxes.TickDir = 'out';

%draw spectrum
plot(obj.uiHandles.spectrumAxes, miepGUIObj.workData.dataStore(1,1).Energy, miepGUIObj.workData.data)
end