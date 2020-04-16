function [folders] = pathset(location, exclude)

% PATHSET  establish desired path, with all subfolders included.
%
% Summary:
%     This functions recursively adds all paths below the input location,
%     or if not specified, it's based on the location of the pathset.m function.
%     This is basically: addpath(genpath(location))
%     However, this function also allows you to exclude certain names, such as .git
%     subfolders.
%
% Input:
%     location : |opt| string specifying folder location [char]
%     ex       : |opt| string or cell array specifying folder name(s) to exclude [char]
%
% Output:
%     folders : string array of folders added to the path, also displays this info to command window
%
% Prototype:
%     % add complete library to path
%     matspace.paths.pathset;
%
% See Also:
%     matspace.paths.pathremove, addpath, genpath, rmpath
%
% Change Log:
%     1.  Written by Scott Sims in 2008, originally for EKF.
%     2.  Duplicated and updated by David C. Stauffer in Feb 2009 to specify an optional argument in.
%     3.  Moved from the GUI to just one location in UTILS by David C. Stauffer in Oct 2009.
%     4.  Updated by David C. Stauffer in Dec 2009 to pass PGPR_1030.
%     5.  Incorporated by David C. Stauffer into matspace library in November 2016.
%     6.  Updated by David C. Stauffer in September 2018 to use new string arrays, making the
%         function much more compact and easier to understand.
%     7.  Updated by David C. Stauffer in April 2020 to put into a package.

%% hard-coded exclusions
exclusions = ["\.git", "\.svn", "\mex\make", "/.git", "/.svn", "/mex/make"];

%% use specified path, or path of function itself
switch nargin
    case 0
        path_name = mfilename('fullpath');
        ix        = strfind(path_name,filesep);
        location  = path_name(1:ix(end-1)-1);
    case 1
        % nop
    case 2
        exclusions = [exclusions, string(cellstr(exclude))];
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% Generate folders paths to add
% Check for package locations
ix = strfind(location, [filesep,'+']);
if ~isempty(ix)
    % if in a package, then get the parent
    folders = string(location(1:ix(1)-1));
    warning('matspace:pathsetPackage', 'Location: "%s" is a package, so its root of "%s" was set instead.', location, folders);
else
    % nominal situation, generate included paths recursively
    folders = string(genpath(location)).split(pathsep);
end
% remove any empty paths (usually caused by a trailing pathsep returned from genpath
folders(strlength(folders) == 0) = [];
% remove any excluded folders
folders(contains(folders, exclusions)) = [];

%% add the paths
addpath(folders.join(pathsep));

%% display status
disp('PATHSET:');
disp(folders);