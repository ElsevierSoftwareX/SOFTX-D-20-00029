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
obj.uiHandles.spectrumAxes = axes(obj.tabHandle, 'OuterPosition', obj.InnerPosition);
plot(obj.uiHandles.spectrumAxes, miepGUIObj.workData.dataStore(1,1).Energy, miepGUIObj.workData.data)
obj.uiHandles.spectrumAxes.XLabel.String = 'Energy [eV]';
obj.uiHandles.spectrumAxes.YLabel.String = 'Intensity [counts]';
obj.uiHandles.spectrumAxes.TickDir = 'out';
end