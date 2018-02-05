function status = restoredefaultpath() %#ok<*MCAP>

% RESTOREDEFAULTPATH  provides a customize default path based on the built in version.
%
% Input:
%     None
%
% Output:
%     status : (scalar) true/false flag for whether the restoration was completed [bool]
%
% Prototype:
%     restoredefaultpath;
%     startup;
%
% See Also:
%     pathset
%
% Change Log:
%     1.  Written by David C. Stauffer circa 2006.

% warnings to disable
warning('off','MATLAB:dispatcher:nameConflict');
warning('off','MATLAB:dispatcher:pathWarning');

% hard-coded exceptions for PCOR8
if ispc && strcmp(getenv('computername'), 'PCOR8')
    is_pcor = true;
    drive_letter = 'D:';
else
    is_pcor = false;
    drive_letter = getenv('homedrive');
end

% run built-in version
switch version('-release')
    case '2015b'
        run([drive_letter, '\Program Files\MATLAB\R2015b\toolbox\local\restoredefaultpath.m']);
    case '2016a'
        run([drive_letter, '\Program Files\MATLAB\R2016a\toolbox\local\restoredefaultpath.m']);
    case '2016b'
        run([drive_letter, '\Program Files\MATLAB\R2016b\toolbox\local\restoredefaultpath.m']);
    otherwise
        error('dstauffman:utils:RestorePathVersions', ...
            'Unsupported MATLAB version, update to personal restoredefaultpath is needed.');
end

% get directory information
if ispc
    root = fullfile([drive_letter, getenv('homepath')], 'Documents');
elseif isunix
    root = fullfile(filesep, 'home', getenv('user'), 'Documents'); % TODO: update at home on Unix system
end

% add user customized paths
addpath(fullfile(root, 'MATLAB'));
disp('PATHSET:')
disp(['    ''', fullfile(root, 'MATLAB'),'''']);
% DStauffman Matlab library
if is_pcor
    run('D:\Dcstauff\GitHub\matlab\pathset.m');
else
    run(fullfile(root, 'GitHub', 'matlab', 'pathset.m'));
end

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