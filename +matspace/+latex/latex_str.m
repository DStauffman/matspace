function [value_str] = latex_str(value, digits, kwargs)

% LATEX_STR  Formats a given value for display in a LaTeX document.
%
% Input:
%     value ...... : (scalar) numeric or string value
%     varargin ... : (char, value) pairs for other options, from:
%         'Digits' : (1xA) time points for series two, default is empty
%         'Fixed'  : (BxA) data points for series two, default is empty
%         'CMP2AR' : (char) text to put on the plot titles, default is empty string
%         'Capped' : (char) type of data to use when converting axis scale, default is 'unity'
%
% Output:
%     out : (row) string specifying the given LaTeX output
%
% Prototype:
%     value_str = matspace.latex.latex_str(0);
%     assert(strcmp(value_str, '0'));
%
% Change Log
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

%% Arguments
arguments
    value {mustBeNumOrChar}
    digits (1, 1) {mustBeNumeric} = -1;
    kwargs.Fixed (1, 1) logical = false;
    kwargs.CMP2AR (1, 1) logical = false;
    kwargs.Capped (1, 1) {mustBeNumeric} = 1073741823;
end

%% Imports
import matspace.stats.mp2ar

%% Parse Inputs
% create parser
p = inputParser;
% create some validation functions
func_is_num_or_char = @(x) isnumeric(x) || ischar(x);
% set options
addRequired(p, 'Value', func_is_num_or_char);

% create some convenient aliases
fixed  = kwargs.Fixed;
cmp2ar = kwargs.CMP2AR;
capped = kwargs.Capped;

%% Process
% check for string case, and if so, just do replacements
if ischar(value)
    value_str = strrep(value, '_', '\_');
    return
end
% determine digit method
if fixed
    letter = 'f';
else
    letter = 'g';
end
% build the formatter
if digits >= 0
    formatter = ['%.', int2str(digits), letter];
else
    formatter = '';
end
% potentially convert units
if cmp2ar
    value = mp2ar(value);
end
if isnan(value)
    value_str = 'NaN';
elseif isinf(value) || value > capped
    value_str = '$\infty$';
else
    % format the string
    if isempty(formatter)
        value_str = num2str(value);
    else
        value_str = num2str(value, formatter);
    end
    % convert underscores
    value_str = strrep(value_str, '_', '\_');
end

%% Subfunctions
% Custom validator functions
function mustBeNumOrChar(x)
if ~isnumeric(x) && ~ischar(x)
    throwAsCaller(MException('matspace:latex_str:BadNumChar','Input must be numeric or char.'))
end