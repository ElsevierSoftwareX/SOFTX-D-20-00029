% read STXM .hdr files
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Max Planck Institute for Intelligent Systems           %
% % Joachim Gräfe                                          %
% % graefe@is.mpg.de                                       %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function readHDR(obj, varargin)

%check for varargin
switch nargin
    case 2
        %try to load header from input string
        obj.basefile = strrep(varargin{1}, '.hdr', '');
end

obj.header = struct;
filename = strcat(obj.basefile, '.hdr');

%open file
fid = fopen(filename);

%start reading
while ~feof(fid)
    line = strtrim(fgetl(fid));
    
    %evaluate line
    parts = strtrim(split(line, ' '));
    switch parts{1}
        
        case 'ScanDefinition'
            %parse ScanDefinition
            data = split(line, '{');
            properties = strtrim(split(data{2}, ';'));
            for i=1:size(properties,1)
                property = strtrim(split(properties{i}, '='));
                switch property{1}
                    case 'Label'
                        obj.header.Label = strrep(property{2}, '"', '');
                    case 'Type'
                        obj.header.Type = strrep(property{2}, '"', '');
                    case 'Flags'
                        obj.header.Flags = strrep(property{2}, '"', '');
                    case 'ScanType'
                        obj.header.ScanType = strrep(property{2}, '"', '');
                    case 'Dwell'
                        obj.header.Dwell = str2double(property{2});
                end
            end
            
        case 'Regions'
            %parse Regions
            obj.header.Regions = struct;
            curRegion = 0;
            %read more lines until Regions end indicator is reached
            while ~strcmp(line, '});')
                line = fgetl(fid);
                %detect Region start
                if strcmp(line, '{')
                    %enter next Region
                    curRegion = curRegion + 1;
                    %read first Axis
                    line = fgetl(fid);
                    obj.header.Regions(curRegion).PAxis = struct;
                    obj.header.Regions(curRegion).PAxis = parseAxis(line);
                    %read points
                    line = fgetl(fid);
                    [obj.header.Regions(curRegion).PAxis.Points, obj.header.Regions(curRegion).PAxis.Axis] = parsePoints(line);
                    %check for second Axis
                    line = fgetl(fid);
                    if strcmp(line, '};') %Axis end indicator
                        %second Axis is preceeded by empty line
                        line = fgetl(fid);
                        if strcmp(line, '')
                            %read second Axis
                            line = fgetl(fid);
                            obj.header.Regions(curRegion).QAxis = struct;
                            obj.header.Regions(curRegion).QAxis = parseAxis(line);
                            %read points
                            line = fgetl(fid);
                            [obj.header.Regions(curRegion).QAxis.Points, obj.header.Regions(curRegion).QAxis.Axis] = parsePoints(line);
                        end
                    else
                        %while conditions should detect next Region and
                        %Regions end --> do nothring
                    end
                end
            end
            
        case 'StackAxis'
            %parse StackAxis
            obj.header.StackAxis = parseAxis(line);
            %read points
            line = fgetl(fid);
            [obj.header.StackAxis.Points, obj.header.StackAxis.Axis] = parsePoints(line);
            
        case 'Channels'
            %parse Channels
            if ~isfield(obj.header, 'Channels')
                obj.header.Channels = struct;
            end
            curChannel = 0;
            %read more lines until Channels end indicator is reached
            while ~strcmp(line(end-3:end), ';});')
                line = fgetl(fid);
                curChannel = curChannel + 1;
                data = regexprep(line, '[{}),]', ''); %trim line of {}),
                properties = strtrim(split(data, ';'));
                for i=1:size(properties,1)
                    property = strtrim(split(properties{i}, '='));
                    switch property{1}
                        case 'Name'
                            obj.header.Channels(curChannel).Name = strrep(property{2}, '"', '');
                        case 'Unit'
                            obj.header.Channels(curChannel).Unit = strrep(property{2}, '"', '');
                        case 'ID'
                            obj.header.Channels(curChannel).ID = str2double(property{2});
                        case 'Type'
                            obj.header.Channels(curChannel).Type = str2double(property{2});
                        case 'Controller'
                            obj.header.Channels(curChannel).Controller = str2double(property{2});
                        case 'DeviceNumber'
                            obj.header.Channels(curChannel).DeviceNumber = str2double(property{2});
                        case 'UnitName'
                            obj.header.Channels(curChannel).UnitName = strrep(property{2}, '"', '');
                        case 'LinearCoefficient'
                            obj.header.Channels(curChannel).LinearCoefficient = str2double(property{2});
                        case 'ConstantCoefficient'
                            obj.header.Channels(curChannel).ConstantCoefficient = str2double(property{2});
                        case 'ProcessString'
                            obj.header.Channels(curChannel).ProcessString = strrep(property{2}, '"', '');
                    end
                end
            end
            
        case 'Time'
            %parse Time
            properties = strtrim(split(line, ';'));
            for i=1:size(properties,1)
                property = strtrim(split(properties{i}, '='));
                switch property{1}
                    case 'Time'
                        obj.header.Time = strrep(property{2}, '"', '');
                    case 'BeamFeedback'
                        obj.header.BeamFeedback = property{2};
                    case 'ShutterAutomatic'
                        obj.header.ShutterAutomatic = property{2};
                end
            end
            
        otherwise
            %try parsing single information lines
            if size(line,2)>3
                if strcmp(line(end-2:end), ';};')
                    stage = parts{1};
                    obj.header.(stage) = struct;
                    data = split(line, '{');
                    properties = strtrim(split(data{2}, ';'));
                    for i=1:size(properties,1)
                        property = strtrim(split(properties{i}, '='));
                        if size(property,1) == 2
                            if ~isfield(obj.header, stage)
                                obj.header.(stage) = struct;
                            end
                            %try detecting string or double
                            if size(strfind(property{2}, '"'),2)
                                obj.header.(stage).(property{1}) = strrep(property{2}, '"', '');
                            else
                                obj.header.(stage).(property{1}) = str2double(property{2});
                            end
                        end
                    end
                end
            end
            
    end
end

%initialize dataStore after parsing header
obj.initDataStore

    function axisOutput = parseAxis(line)
        %parse Axis definition
        %Input: raw line data
        %Output: struct array
        data = split(line, '{');
        properties = strtrim(split(data{2}, ';'));
        for j=1:size(properties,1)
            property = strtrim(split(properties{j}, '='));
            switch property{1}
                case 'Name'
                    axisOutput.Name = strrep(property{2}, '"', '');
                case 'Unit'
                    axisOutput.Unit = strrep(property{2}, '"', '');
                case 'Min'
                    axisOutput.Min = str2double(property{2});
                case 'Max'
                    axisOutput.Max = str2double(property{2});
                case 'Dir'
                    axisOutput.Dir = str2double(property{2});
            end
        end
    end

    function [outputPoints, outputAxis] = parsePoints(line)
        %read Points list
        %Input: raw line data
        %Output: struct array
        
        %clip data
        line = strtrim(line);
        line = line(11:end-3);
        data = str2double(strtrim(split(line, ',')));
        outputPoints = data(1);
        outputAxis = data(2:end);
    end

end