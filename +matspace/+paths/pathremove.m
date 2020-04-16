function pathremove(location, exclude)

% PATHREMOVE  removes all the paths recursively.
%
% Summary:
%     This functions recursively removes all paths below the input location,
%     or if not specified, it's based on the location of the pathremove.m function.
%     This is basically rmpath(genpath(location))
%
% Input:
%     location : optional (row) string specifying folder location [char]
%
% Output:
%     none - displays info to command window
%
% Prototype:
%     % remove library from path
%     matspace.paths.pathremove;
%
%     % clean up by restoring path for continuing use
%     matspace.paths.pathset;
%
% See Also:
%     matspace.paths.pathset
%
% Change Log:
%     1.  Written by Scott Sims in 2008, originally for EKF.
%     2.  Duplicated and updated by David C. Stauffer in Feb 2009 to specify an option argument in.
%     3.  Updated by David C. Stauffer in Dec 2009 to pass PGPR_1030 and fix bug for not removing root path.
%     4.  Incorporated by David C. Stauffer into matspace library in November 2016.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.

%% hard-coded exclusions
exclusions = ["\.git", "\.svn", "\mex\make", "/.git", "/.svn", "/mex/make"];

%% use specified path, or path of function itself
switch nargin
    case 0
        path_name = mfilename('fullpath');
        ix        = strfind(path_name,filesep);
        location  = path_name(1:ix(end-2));
    case 1
        % nop
    case 2
        exclusions = [exclusions, string(cellstr(exclude))];
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% find the established paths
established = string(path).split(pathsep);

%% find the paths to remove
folders = string(genpath(location)).split(pathsep);
% remove any empty paths (usually caused by a trailing pathsep returned from genpath
folders(strlength(folders) == 0) = [];
% remove any excluded folders
folders(contains(folders, exclusions)) = [];
% find those to actually remove
remove = intersect(established, folders);

%% remove the folders and display results
if ~isempty(remove)
    rmpath(folders.join(pathsep));
    disp('DESCOPED:');
    disp(remove);
end