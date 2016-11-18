function status = restoredefaultpath() %#ok<*MCAP>

% RESTOREDEFAULTPATH  provides a customize default path based on the built in version.

% warnings to disable
warning('off','MATLAB:dispatcher:nameConflict');
warning('off','MATLAB:dispatcher:pathWarning');

% run built-in version
switch version('-release')
    case '2015b'
        run('C:\Program Files\MATLAB\R2015b\toolbox\local\restoredefaultpath.m');
    case '2016a'
        run('C:\Program Files\MATLAB\R2016a\toolbox\local\restoredefaultpath.m');
    case '2016b'
        run('C:\Program Files\MATLAB\R2016b\toolbox\local\restoredefaultpath.m');
    otherwise
        error('dstauffman:utils:RestorePathVersions', ...
            'Unsupported MATLAB version, update to personal restoredefaultpath is needed.');
end

% get directory information
if ispc
    root = fullfile([getenv('homedrive'), getenv('homepath')], 'Documents');
elseif isunix
    root = fullfile(filesep, 'home', getenv('user'), 'Documents'); % TODO: update at home on Unix system
end

% add user customized paths
addpath(fullfile(root, 'MATLAB'));
disp('PATHSET:')
disp(['    ''', fullfile(root, 'MATLAB'),'''']);
% DStauffman Matlab library
run(fullfile(root, 'GitHub', 'matlab', 'pathset.m'));

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