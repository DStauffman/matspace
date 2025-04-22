function [tests_dir] = get_tests_dir()

% GET_OUTPUT_DIR  gets the location of the output directory of the matspace library.
%
% Input:
%     None
%
% Output:
%     output_dir : (str) results output directory [char]
%
% Prototype:
%     output_dir = matspace.paths.get_output_dir();
%
% See Also:
%     matspace.paths.get_root_dir, mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in matspace library.
%     2.  Updated by David C. Stauffer in March 2019 to put path functions into a package.

% Imports
import matspace.paths.get_root_dir

% keep the path name up to the second to last file separator
tests_dir = fullfile(get_root_dir(), 'tests');