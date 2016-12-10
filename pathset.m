function [] = pathset(location,ex)

% PATHSET  establish desired path, with all subfolders included.
%
% Summary:
%     This functions recursively adds all paths below the input location,
%     or if not specified, it's based on the location of the pathset.m function.
%     This is basically: addpath(genpath(location))
%     However, this function also allows you to exclude certain names, such as .svn
%     subfolders.
%
% Input:
%     location : |opt| (row) string specifying folder location [char]
%     ex       : |opt| (row) string specifying folder name to exclude [char]
%
% Output:
%     (NONE) - displays info to command window
%
% Prototype:
%     % add complete library to path
%     pathset;
%
% See Also:
%     pathremove
%
% Change Log:
%     1.  Written by Scott Sims in 2008, originally for EKF.
%     2.  Duplicated and updated by David Stauffer in Feb 2009 to specify an optional argument in.
%     3.  Moved from the GUI to just one location in UTILS by David Stauffer in Oct 2009.
%     4.  Updated by David Stauffer in Dec 2009 to pass PGPR_1030.
%     5.  Incorporated by David C. Stauffer into DStauffman library in November 2016.

%% hard-coded exclusions
exclusions = {'\.git', '\.svn', '\mex\make'};

%% use specified path, or path of function itself
switch nargin
    case 0
        mloc       = mfilename('fullpath');
        ix         = strfind(mloc,filesep);
        location   = mloc(1:ix(end));
    case 1
        % nop
    case 2
        ex = cellstr(ex);
        exclusions = [exclusions, ex];
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

%% add a filesep at the end if not there already
if ~strcmp(location(end),filesep)
    location = [location,filesep];
end

%% generate paths to add
paths = genpath(location);

%% convert paths to a cell array
ix      = [0, strfind(paths,pathsep)];
folders = cell(length(ix)-1,1);
% chop into folder names keying off the pathsep character
for i = 1:length(ix)-1
    folders{i,1} = paths(ix(i)+1:ix(i+1)-1);
end

%% only keep folders without exclusions
% the double cellfun call avoids for loops for folders and exclusions,
% where x is exclusions and y is folders
keep    = cellfun(@(y) all(cellfun(@(x) isempty(strfind(y,x)),exclusions)),folders);
folders = folders(keep);

%% add the paths
% reassert the pathsep character before calling addpath
temp    = [folders, cellstr(repmat(pathsep,length(folders),1))]';
addpath([temp{:}]);

%% display status
disp('PATHSET:');
disp(folders);