function [mex_dir] = get_mex_dir()

% GET_MEX_DIR  gets the location of the mex directory for the DStauffman MATLAB library.
%
% Input:
%     None
%
% Output:
%     mex_dir : (str) mex output directory [char]
%
% Prototype:
%     mex_dir = get_mex_dir();
%
% See Also:
%     get_root_dir, mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in DStauffman MATLAB library.

% keep the path name up to the second to last file separator
mex_dir   = fullfile(get_root_dir,'mex',filesep);