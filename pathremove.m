function pathremove(location)

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
%     pathremove;
%
%     % clean up by restoring path for continuing use
%     pathset;
%
% See Also:
%     pathset
%
% Change Log:
%     1.  Written by Scott Sims in 2008, originally for EKF.
%     2.  Duplicated and updated by David Stauffer in Feb 2009 to specify an option argument in.
%     3.  Updated by David Stauffer in Dec 2009 to pass PGPR_1030 and fix bug for not removing root path.
%     4.  Incorporated by David C. Stauffer into DStauffman library in November 2016.

%% use specified path, or path of function itself
switch nargin
    case 0
        location = fileparts(mfilename('fullpath'));
    case 1
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% find the established paths
established = string(path).split(pathsep);

%% find the paths to remove
folders = string(genpath(location)).split(pathsep);
% remove any empty paths (usually caused by a trailing pathsep returned from genpath
folders(strlength(folders) == 0) = [];
% find those to actually remove
remove = intersect(established, folders);

%% remove the folders and display results
if ~isempty(remove)
    % TODO: remove loop once R2018B+
    for i = 1:length(remove)
        rmpath(remove{i});
    end
    disp('DESCOPED:');
    disp(remove);
end