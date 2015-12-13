function [output_dir] = get_output_dir()

% GET_OUTPUT_DIR  gets the location of the output directory of the DStauffman MATLAB library.
%
% Input:
%     None
%
% Output:
%     output_dir : (str) results output directory [char]
%
% Prototype:
%     output_dir = get_output_dir();
%
% See Also:
%     get_root_dir, mfilename
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 for inclusion in DStauffman MATLAB library.

% keep the path name up to the second to last file separator
output_dir   = fullfile(get_root_dir,'results',filesep);