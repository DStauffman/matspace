%% run on MATLAB startup
%#ok<*UNRCH,*MCAP,*MCCD>

%% set some formatting guides
format long g;
format compact;

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
work = fullfile(root, 'Workspaces', 'smallsat');

%% Set system properties
% system_dependent('DirChangeHandleWarn','Never');

%% Turn off expected warnings
% warning('off', 'MATLAB:UIW_DOSUNC');
% warning('off', 'MATLAB:dispatcher:nameConflict');
% warning('off', 'MATLAB:dispatcher:pathWarning');
% warning('off', 'MATLAB:ClassInstanceExists');

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

%% Go to a useful starting folder
try
    if is_LM
        cd(work);
    else
        cd(fullfile(git_, 'matlab'));
    end
catch exception
    % potentially could check for specific exceptions, just rethrow for now.
    rethrow(exception);
end

%% Open primary working script
if is_LM
    edit(fullfile(mat_, 'smallsat_script.m'));
end

%% Clear temporary variables
clear('is_LM', 'is_PCOR8', 'root', 'docs', 'mat_', 'git_', 'proj', 'work');