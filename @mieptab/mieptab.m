% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Tab                                               %
% %                                                        %
% % Tab functionality for MIEP Tabs                        %
% %                                                        %
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef mieptab < handle
    %miep tab is a handle
    
    properties
        tabHandle = []; %stores uitab handle
        uiHandles = struct(); %stores ui handles for tab
        tabData = struct(); %variable tab data store
    end
    
    properties (Access = private)
        miepGUIObj = []; %stores MIEP GUI handle
    end
    
    methods
        function obj = mieptab(miepGUIObj, tabType)
            %miep tab constructor greates tab on miep GUI
            %input: MIEP GUI Object, Tab Type
            
            obj.miepGUIObj = miepGUIObj;
            
            %create tab
            obj.tabHandle = uitab(miepGUIObj.tabGroup, 'Title', tabType, 'Units', 'pixels');
            
            % clear current tabs here instead of in function displayData(obj) of gui to avoid stuttering?
            waitfor(obj.tabHandle, 'Position') % Fix Matlab Madness
            
            miepGUIObj.tabs.(tabType) = obj;
            
            
            %decide which type of tab to draw
            switch tabType
                case 'MIEP'
                    %empty welcome tab
                case 'Image'
                    obj.imageTab(miepGUIObj)
                case 'Spectrum'
                    obj.spectrumTab(miepGUIObj)
                case 'PhaseAmplitude'
                    obj.phaseAmpTab(miepGUIObj)
                case 'kSpace'
                    obj.kSpaceTab(miepGUIObj)
                case 'Filter'
                    obj.filterTab(miepGUIObj)
                case 'CWT'
                    obj.CWTTab(miepGUIObj)
            end
        end
        
        function delete(obj)
            %miep tab destructor removes tab from miep GUI
            delete(obj.tabHandle)
        end
    end
end

