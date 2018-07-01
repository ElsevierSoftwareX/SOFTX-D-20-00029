% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % MIEP Tab                                               %
% %                                                        %
% % Tab functionality for MIEP Tabs                        %
% % Master Class for specialized tabs                      %
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
    
    %dependnet properties to provide transparent tab handle
    properties (Dependent)
        OuterPosition
        InnerPosition
    end
    methods
        function OuterPosition = get.OuterPosition(obj)
            OuterPosition = obj.tabHandle.OuterPosition;
        end
        function set.OuterPosition(obj, OuterPosition)
            obj.tabHandle.OuterPosition = OuterPosition;
        end
        function InnerPosition = get.InnerPosition(obj)
            InnerPosition = obj.tabHandle.InnerPosition;
        end
        function set.InnerPosition(obj, InnerPosition)
            obj.tabHandle.InnerPosition = InnerPosition;
        end
    end 
    
    methods
        function obj = mieptab(miepGUIObj, tabTitle)
            %miep tab constructor greates tab on miep GUI
            %input: MIEP GUI Object, Tab Title
            obj.tabHandle = uitab(miepGUIObj.tabGroup, 'Title', tabTitle);
            miepGUIObj.tabs.(tabTitle) = obj;
        end
        
        function delete(obj)
            %miep tab destructor removes tab from miep GUI
            delete(obj.tabHandle)
        end
    end
end

