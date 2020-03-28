function [output_dir] = get_output_dir()

% GET_OUTPUT_DIR  gets the location of the output directory of the matspace library.
%
% Input:
%     None
%
% Output:
%     output_dir : (str) results output directory [char]
%
% Prototype:
%     import matspace.get_output_dir
%     output_dir = get_output_dir();
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
output_dir = fullfile(matspace.get_root_dir,'results',filesep);