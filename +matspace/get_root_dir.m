function [root_dir] = get_root_dir()

% GET_ROOT_DIR  gets the root location of the matspace library.
%
% Input:
%     None
%
% Output:
%     root_dir : (str) root directory [char]
%
% Prototype:
%     import matspace.get_root_dir
%     root_dir = get_root_dir();
%
% See Also:
%     mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in matspace library.
%     2.  Updated by David C. Stauffer in March 2019 to put path functions into a package.

% get the fullpath name to this m file
path_name = mfilename('fullpath');

% find all the string separators
ix        = strfind(path_name,filesep);

% keep the path name up to the second to last file separator
root_dir  = path_name(1:ix(end-1));