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

% use specified path, or path of function itself
switch nargin
    case 0
        mloc     = mfilename('fullpath');
        ix       = strfind(mloc,filesep);
        location = mloc(1:ix(end)-1);
    case 1
        % remove a filesep at the end to make logic work correctly
        if strcmp(location(end),filesep)
            location = location(1:end-1);
        end
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% find the established paths
established = path;
ix = strfind(established,pathsep);
ix = [0,ix];
cell_established = cell(length(ix)-1,1);
for i = 1:length(ix)-1;
    cell_established{i,1} = established(ix(i)+1:ix(i+1)-1);
end

% find the paths to remove
remove = genpath(location);
ix = strfind(remove,pathsep);
ix = [0,ix];

% check if folders are on the path
cell_remove = cell(length(ix)-1,1);
for i = 1:length(ix)-1;
    cell_remove{i,1} = remove(ix(i)+1:ix(i+1)-1);
end

% remove the folders and display results
listed = NaN(length(cell_remove),1);
for i = 1:length(cell_remove)
    listed(i) = any(strcmp(cell_remove(i),cell_established));
end
ix = find(listed);
if ~isempty(ix)
    rmpath(cell_remove{ix});
    disp('DESCOPED:');
    disp(cell_remove(ix))
end