%% run on MATLAB startup
%#ok<*UNRCH,*MCAP,*MCCD>

% set some formatting guides
format long g;
format compact;

% get directory information
if ispc
    root = fullfile([getenv('homedrive'), getenv('homepath')], 'Documents');
elseif isunix
    root = fullfile(filesep, 'home', getenv('user'), 'Documents'); % TODO: update at home on Unix system
end
root_matlab = root;
% hard-coded PCOR 8 exception
if ispc && strcmp(getenv('computername'), 'PCOR8')
    root = 'D:\Dcstauff';
end

%% Set system properties
% system_dependent('DirChangeHandleWarn','Never');

%% Turn off expected warnings
% warning('off','MATLAB:UIW_DOSUNC');
% warning('off','MATLAB:dispatcher:nameConflict');
% warning('off','MATLAB:dispatcher:pathWarning');

%% Add folders to path (ones added last have higher precidence)
addpath(fullfile(root_matlab, 'MATLAB'));
disp('PATHSET:')
disp(['    ''', fullfile(root_matlab, 'MATLAB'),'''']);
% DStauffman Matlab library
run(fullfile(root, 'GitHub', 'matlab', 'pathset.m'));
% HESAT
if true
    pathset(fullfile(root, 'GitHub', 'hesat', 'code'));
end

%% Go to a useful starting folder
try
    temp_path = fullfile(root, 'GitHub', 'matlab');
    cd(temp_path);
catch exception
    % potentially could check for specific exceptions, just rethrow for now.
    rethrow(exception);
end