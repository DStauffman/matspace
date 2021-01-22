%% run on MATLAB startup
%#ok<*UNRCH,*MCAP,*MCCD>

%% set some formatting guides
format long g;
format compact;
datetime.setDefaultFormats('default', 'dd-MMM-uuuu HH:mm:ss.SSSSSS');

%% Get some information from environment variables
dcs_always  = getenv('DCS_MATLAB_ALWAYS');
dcs_tools   = getenv('DCS_MATLAB_TOOLS');
dcs_current = getenv('DCS_MATLAB_CURRENT');
dcs_prj_ldr = getenv('DCS_MATLAB_LOADER');
dcs_start   = getenv('DCS_MATLAB_START');
dcs_open    = getenv('DCS_MATLAB_OPEN');

%% Set system properties
% system_dependent('DirChangeHandleWarn','Never');

%% Turn off expected warnings
% warning('off', 'MATLAB:UIW_DOSUNC');
% warning('off', 'MATLAB:dispatcher:nameConflict');
% warning('off', 'MATLAB:dispatcher:pathWarning');
% warning('off', 'MATLAB:ClassInstanceExists');

%% Restore old style plot controls
if ~verLessThan('matlab', '9.4')
    set(groot, 'defaultFigureCreateFcn', @(fig, ~) addToolbarExplorationButtons(fig));
    set(groot, 'defaultAxesCreateFcn', @(ax, ~) set(ax.Toolbar, 'Visible', 'off'));
end

%% Add folders to path (ones added last have higher precidence)
if ~isempty(dcs_always)
    % folder to always have on my path
    addpath(dcs_always);
    disp('PATHSET:')
    disp(['    "', dcs_always,'"']);
end
if ~isempty(dcs_tools)
    % matspace library
    if isfile(fullfile(dcs_tools, 'pathset.m'))
        run(fullfile(dcs_tools, 'pathset.m'));
    elseif isfolder(dcs_tools)
        addpath(dcs_tools);
        disp('PATHSET:')
        disp(['    "', dcs_tools,'"']);
    end
end
if ~isempty(dcs_current)
    % Current project, either for work or home
    if isfile(fullfile(dcs_current, 'pathset.m'))
        run(fullfile(dcs_current, 'pathset.m'));
    elseif isfile(fullfile(dcs_current, 'matlab_setup.m'))
        disp(['Running matlab_setup.m in ', fullfile(dcs_current)]);
        run(fullfile(dcs_current, 'matlab_setup.m'));
    elseif isfolder(dcs_current)
        addpath(dcs_current);
        disp('PATHSET:')
        disp(['    "', dcs_current,'"']);
    end
end
if ~isempty(dcs_prj_ldr)
    % Add Project Loader
    addpath(dcs_prj_ldr);
    disp('PATHSET:')
    disp(['    "', dcs_prj_ldr, '"']);
end

%% Go to a useful starting folder
if ~isempty(dcs_start)
    try
        cd(dcs_start);
    catch dcs_exception
        % potentially could check for specific exceptions, just rethrow for now.
        rethrow(dcs_exception);
    end
end

%% Open primary working script
if ~isempty(dcs_open)
    if isfile(dcs_open)
        edit(dcs_open);
    else
        warning('matspace:startupOpen', 'Unable to open "%s".', dcs_open);
    end
end

%% Clear temporary variables
clear('dcs*');