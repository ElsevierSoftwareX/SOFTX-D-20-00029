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
            %miep tab constructor creates tab on miep GUI
            %input: MIEP GUI Object, Tab Type
            
            obj.miepGUIObj = miepGUIObj;
            
            %create tab
            obj.tabHandle = uitab(miepGUIObj.tabGroup, 'Units', 'pixels');
            %drawnow%fix matlab madness
            
            miepGUIObj.tabs.(tabType) = obj;
            
            %decide which type of tab to draw
            switch tabType
                case 'miep'
                    obj.tabHandle.Title = 'MIEP';
                    obj.welcomeTab(miepGUIObj)
                case 'image'
                    obj.tabHandle.Title = 'Image';
                    obj.imageTab(miepGUIObj)
                case 'spectrum'
                    obj.tabHandle.Title = 'Spectrum';
                    obj.spectrumTab(miepGUIObj)
                case 'fft'
                    obj.tabHandle.Title = 'FFT';
                    obj.fftTab(miepGUIObj)
                case 'kspace'
                    obj.tabHandle.Title = 'k-Space';
                    obj.kspaceTab(miepGUIObj)
                case 'movie'
                    obj.tabHandle.Title = 'Movie';
                    obj.movieTab(miepGUIObj)
            end
        end
        
        function delete(obj)
            %miep tab destructor removes tab from miep GUI
            
            %stop previous timer and delete if existent to avoid timer
            %errors and multiple timers

            if ~isempty(timerfind)
                stop(timerfind)
                delete(timerfind)
            end

            delete(obj.tabHandle)
        end
    end
end

