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

%% Turn off expected warnings
warning('off','MATLAB:dispatcher:nameConflict');
warning('off','MATLAB:dispatcher:pathWarning');

%% get directory information
is_LM = strcmp(getenv('COMPUTERNAME'), 'SVLWA80620RW') || strcmp(getenv('USERNAME'), 'e182918');
is_PCOR8 = strcmp(getenv('COMPUTERNAME'), 'PCOR8');
if ispc
    if is_LM
        root = 'C:'; % Don't use getenv('HOMEDRIVE') because LM maps it to a network location instead
        docs = 'C:\Users\e182918\Documents';
        mat_ = 'C:\Users\e182918\Documents\MATLAB';
    else
        if is_PCOR8
            root = 'D:\Dcstauff';
            docs = root;
            mat_ = 'C:\Users\dcstauff.CHPPCOR\Documents\MATLAB';
        else
            % Nominal case
            root = getenv('HOMEDRIVE');
            docs = fullfile([root, getenv('HOMEPATH')], 'Documents');
            mat_ = fullfile(docs, 'MATLAB');
        end
    end 
elseif isunix
    root = getenv('HOME');
    docs = fullfile(root, 'Documents');
    mat_ = fullfile(docs, 'MATLAB');
end
git_ = fullfile(docs, 'GitHub');
proj = fullfile(root, 'Workspaces', 'smallsat', 'CoreSimExternals', 'ProjectLoader');

%% run built-in version
built_in_restore = fullfile(matlabroot, 'toolbox', 'local', 'restoredefaultpath.m');
if exist(built_in_restore, 'file')
    disp('RESTORING default paths.');
    run(built_in_restore);
else
    error('dstauffman:utils:RestorePathLocation', ...
        'Unsupported MATLAB version, could not find built-in restoredefaultpath at "%s".', ...
        built_in_restore);
end

%% Add folders to path (ones added last have higher precidence)
addpath(mat_);
disp('PATHSET:')
disp(['    ''', mat_,'''']);
% DStauffman Matlab library
run(fullfile(git_, 'matlab', 'pathset.m'));
if is_LM
    % Add Project Loader
    addpath(proj);
    disp('PATHSET:')
    disp(['    ''', proj,'''']);
else
    % HESAT
    pathset(fullfile(git_, 'hesat', 'code'));
end

%% output status
if nargout == 1
    status = RESTOREDEFAULTPATH_EXECUTED;
end

%% display results
if RESTOREDEFAULTPATH_EXECUTED
    disp('MATLAB default paths restored.')
else
    error('dstauffman:utils:RestorePath', 'There was a problem restoring the default MATLAB paths.');
end