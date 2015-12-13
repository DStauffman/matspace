function [root_dir] = get_root_dir()

% GET_ROOT_DIR  gets the root location of the DStauffman MATLAB library.
%
% Input:
%     None
%
% Output:
%     root_dir : (str) root directory [char]
%
% Prototype:
%     root_dir = get_root_dir();
%
% See Also:
%     mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in DStauffman MATLAB library.

% get the fullpath name to this m file
path_name = mfilename('fullpath');

% find all the string separators
ix        = strfind(path_name,filesep);

% keep the path name up to the second to last file separator
root_dir  = path_name(1:ix(end-1));