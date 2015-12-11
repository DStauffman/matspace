%% run on MATLAB startup
addpath('C:\Users\DStauffman\Documents\GitHub\matlab\utils'); %#ok<MCAP>
format long g;
format compact;

%% Set system properties
system_dependent('DirChangeHandleWarn','Never');

%% Turn off expected warnings
warning('off','MATLAB:UIW_DOSUNC');
warning('off','MATLAB:dispatcher:nameConflict');
warning('off','MATLAB:dispatcher:pathWarning');

%% Go to GARSE code
try
    cd('C:\Users\DStauffman\Documents\GitHub\matlab\utils'); %#ok<MCCD>
catch exception
    % potentially could check for specific exceptions, just rethrow for now.
    rethrown(exception);
end