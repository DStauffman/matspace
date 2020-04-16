% convenience script for cleaning up the matlab workspace
% (typically copied into a user's MATLAB folder so that it is always on the path)

try
    dbquit('all');
catch exception
    if ~strcmp(exception.identifier,'MATLAB:dbOnlyInDebugMode')
        throw(exception)
    end
end

close('all');
fclose('all');
clear('classes'); %#ok<CLCLS>
dbclear('all');
clc;