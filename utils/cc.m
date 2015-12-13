% convenience script for cleaning up the matlab workspace

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