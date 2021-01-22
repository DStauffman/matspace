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
%     matspace.utils.restoredefaultpath;
%     startup;
%
% See Also:
%     pathset
%
% Change Log:
%     1.  Written by David C. Stauffer circa 2006.
%     2.  Updated by David C. Stauffer in February 2019 to use environment variables for what
%         should always stay on the path.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Turn off expected warnings
warning('off', 'MATLAB:dispatcher:nameConflict');
warning('off', 'MATLAB:dispatcher:pathWarning');

%% Get some information from environment variables
dcs_always  = getenv('DCS_MATLAB_ALWAYS');

%% run built-in version
built_in_restore = fullfile(matlabroot, 'toolbox', 'local', 'restoredefaultpath.m');
if isfile(built_in_restore)
    disp('RESTORING default paths.');
    run(built_in_restore);
else
    error('matspace:utils:RestorePathLocation', ...
        'Unsupported MATLAB version, could not find built-in restoredefaultpath at "%s".', ...
        built_in_restore);
end

%% Add folders to path
if ~isempty(dcs_always)
    % folder to always have on my path
    addpath(dcs_always);
    disp('PATHSET:')
    disp(['    "',dcs_always,'"']);
end

%% output status
if nargout == 1
    status = RESTOREDEFAULTPATH_EXECUTED;
end

%% display results
if RESTOREDEFAULTPATH_EXECUTED
    disp('MATLAB default paths restored.')
else
    error('matspace:utils:RestorePath', 'There was a problem restoring the default MATLAB paths.');
end