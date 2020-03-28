function [mex_dir] = get_mex_dir()

% GET_MEX_DIR  gets the location of the mex directory for the matspace library.
%
% Input:
%     None
%
% Output:
%     mex_dir : (str) mex output directory [char]
%
% Prototype:
%     import matspace.get_mex_dir
%     mex_dir = get_mex_dir();
%
% See Also:
%     matspace.get_root_dir, mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in matspace library.
%     2.  Updated by David C. Stauffer in March 2019 to put path functions into a package.

% Imports
import matspace.get_root_dir

% keep the path name up to the second to last file separator
mex_dir   = fullfile(get_root_dir,'mex',filesep);