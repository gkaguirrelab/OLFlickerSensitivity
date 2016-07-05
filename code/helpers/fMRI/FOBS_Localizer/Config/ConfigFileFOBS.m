% CFObj = ConfigFile(fileName)
%
% Creates a ConfigFile object which represents a particular configuration
% file.
classdef ConfigFileFOBS
    properties (SetAccess = private)
        RawText;
        FileName;
        Params;
    end
    
    methods
        % Constructor
        function CFObj = ConfigFileFOBS(fileName)
            if nargin ~= 1
                error('Usage: cf = ConfigFile(fileName)');
            end
            
            % Make sure the file exists.
            if exist(fileName, 'file') == 0
                error('%s does not exist', fileName);
            end
            
            % Now try to open it.
            fid = fopen(fileName, 'r');
            if fid == -1
                error('Could not open %s', fileName);
            end
            
            % Get the contents of the file.
            fd = textscan(fid, '%s', 'delimiter', '\n');
            fd = fd{1};
            
            fclose(fid);
            
            % Store the raw text and metadata.
            CFObj.RawText = fd;
            CFObj.FileName = fileName;
            
            % Parse the file data and ignore empty lines and comment strings.
            index = 0;
            for i = 1:length(fd)
                if ~isempty(fd{i}) && isempty(regexp(fd{i}, '^\s*%', 'once'))
                    p = textscan(fd{i}, '%s', 'delimiter', ':');
                    p = p{1};
                    
                    % Make sure the parameter isn't malformed.
                    if length(p) < 4 || length(p) > 5
                        error('Malformed parameter');
                    end
                    
                    index = index + 1;
                    
                    % Check for duplicate params, but only after we have 1
                    % or more parameters already stored.
                    if index > 1
                        pl = {CFObj.Params.paramName};
                        if any(strcmp(p{1}, pl))
                            error('Multiple instances of %s in %s', p{1}, fileName);
                        end
                    end
                    
                    % Pointer back into the raw text where this parameter exists.
                    CFObj.Params(index).textIndex = i;
                    
                    % Extract the parameter information, removing whitespaces at the end.
                    CFObj.Params(index).paramClass = deblank(p{1});
                    CFObj.Params(index).paramName = deblank(p{2});
                    CFObj.Params(index).paramType = deblank(p{3});
                    CFObj.Params(index).paramValRaw = deblank(p{4});
                    
                    % Convert the parameter value into its specified type.  When params
                    % are read in from the file, they are in string format.
                    switch CFObj.Params(index).paramType
                        case 'd' % double
                            [CFObj.Params(index).paramVal, ok] = str2num(CFObj.Params(index).paramValRaw); %#ok<ST2NM>
                            
                            if ok == 0
                                error('Could not convert %s to a double value', CFObj.Params(index).paramValRaw);
                            end
                        case 's' % string
                            CFObj.Params(index).paramVal = CFObj.Params(index).paramValRaw;
                        case 'b' % boolean
                            if any(strcmp(CFObj.Params(index).paramValRaw, {'true', '1'}))
                                CFObj.Params(index).paramVal = true;
                            elseif any(strcmp(CFObj.Params(index).paramValRaw, {'false', '0'}))
                                CFObj.Params(index).paramVal = false;
                            else
                                error('Invalid boolean value %s', CFObj.Params(index).paramValRaw);
                            end
                        otherwise
                            error('Invalid parameter type %s', CFObj.Params(index).paramType);
                    end
                    
                    % Stick in an empty description string if one wasn't
                    % specified in the config file.
                    if length(p) == 5
                        CFObj.Params(index).paramDescription = deblank(p{5});
                    else
                        CFObj.Params(index).paramDescription = '';
                    end
                end
            end % loop
        end % function
        
        % Public Functions
        cfStruct = convertToStruct(CFObj)
    end % methods
end % classdef ConfigFile
