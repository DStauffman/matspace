function status = restoredefaultpath()

% RESTOREDEFAULTPATH  provides a customize default path based on the built in version.

% run built-in version
warning('off','MATLAB:dispatcher:nameConflict');
warning('off','MATLAB:dispatcher:pathWarning');
switch version('-release')
    case '2010b'
        run('C:\Program Files\MATLAB\R2010b\toolbox\local\restoredefaultpath.m');
    case '2011b'
        run('C:\Program Files\MATLAB\R2011b\toolbox\local\restoredefaultpath.m');
    case '2012b'
        run('C:\Program Files\MATLAB\R2012b\toolbox\local\restoredefaultpath.m');
    case '2013b'
        run('C:\Program Files\MATLAB\R2013b\toolbox\local\restoredefaultpath.m');
    case '2014b'
        run('C:\Program Files\MATLAB\R2014b\toolbox\local\restoredefaultpath.m');
    case '2015b'
        run('C:\Program Files\MATLAB\R2015b\toolbox\local\restoredefaultpath.m');
    otherwise
        error('Unsupported MATLAB version, update to personal restoredefaultpath is needed.');
end

% add user customized paths
addpath('C:\Users\DStauffman\Documents\GitHub\matlab\utils'); %#ok<MCAP>

% output status
if nargout == 1
    status = RESTOREDEFAULTPATH_EXECUTED;
end

% display results
if RESTOREDEFAULTPATH_EXECUTED
    disp('MATLAB default paths restored.')
else
    error('utils:RestorePath', 'There was a problem restoring the default MATLAB paths.');
end