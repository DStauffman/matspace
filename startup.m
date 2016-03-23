%% run on MATLAB startup
%#ok<*UNRCH,*MCAP,*MCCD>

% set some formatting guides
format long g;
format compact;

% get the user name
username = getenv('username');

%% Set system properties
% system_dependent('DirChangeHandleWarn','Never');

%% Turn off expected warnings
% warning('off','MATLAB:UIW_DOSUNC');
% warning('off','MATLAB:dispatcher:nameConflict');
% warning('off','MATLAB:dispatcher:pathWarning');

%% Add folders to path (most important ones last)
try
    % HESAT
    temp_path = fullfile('C:','Users',username,'Documents','GitHub','hesat','code');
    disp(['Added HESAT (',temp_path,') to path.']);
    addpath(genpath(temp_path));
    % DStauffman Matlab library
    temp_path = fullfile('C:','Users',username,'Documents','GitHub','matlab');
    disp(['Added DStauffman Matlab Library (',temp_path,') to path.']);
    addpath(genpath(temp_path));
    % User's MATLAB folder
    temp_path = fullfile('C:','Users',username,'Documents','MATLAB');
    disp(['Added User MATLAB (',temp_path,') to path.']);
    addpath(temp_path);
catch exception
    % potentially could check for specific errors, just rethrow for now.
    rethrow(exception);
end

%% Go to a useful starting folder
try
    temp_path = fullfile('C:','Users',username,'Documents','GitHub','matlab');
    cd(temp_path);
catch exception
    % potentially could check for specific exceptions, just rethrow for now.
    rethrow(exception);
end