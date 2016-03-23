function status = restoredefaultpath() %#ok<*MCAP>

% RESTOREDEFAULTPATH  provides a customize default path based on the built in version.

% warnings to disable
% warning('off','MATLAB:dispatcher:nameConflict');
% warning('off','MATLAB:dispatcher:pathWarning');

% run built-in version
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
        error('dstauffman:utils:RestorePathVersions', 'Unsupported MATLAB version, update to personal restoredefaultpath is needed.');
end

% add user customized paths
username = getenv('username');
temp_path = fullfile('C:','Users',username,'Documents','GitHub','matlab');
addpath(genpath(temp_path));
temp_path = fullfile('C:','Users',username,'Documents','MATLAB');
addpath(temp_path);

% output status
if nargout == 1
    status = RESTOREDEFAULTPATH_EXECUTED;
end

% display results
if RESTOREDEFAULTPATH_EXECUTED
    disp('MATLAB default paths restored.')
else
    error('dstauffman:utils:RestorePath', 'There was a problem restoring the default MATLAB paths.');
end