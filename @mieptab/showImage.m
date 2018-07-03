% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Image Tab                                         %
% %                                                        %
% % Draws a tab to show images                             %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function showImage(obj, miepGUIObj)
obj.uiHandles.imageAxes = axes(obj.tabHandle, 'OuterPosition', obj.InnerPosition);
imagesc(obj.uiHandles.imageAxes, miepGUIObj.workData.data)
obj.uiHandles.imageAxes.TickDir = 'out';
xMin = miepGUIObj.workData.header.Regions.PAxis.Min;
xMax = miepGUIObj.workData.header.Regions.PAxis.Max;
yMin = miepGUIObj.workData.header.Regions.QAxis.Min;
yMax = miepGUIObj.workData.header.Regions.QAxis.Max;
obj.uiHandles.imageAxes.XTickLabel = {xMin:(xMax-xMin)/10:xMax};
obj.uiHandles.imageAxes.YTickLabel = {yMin:(yMax-yMin)/10:yMax};
end