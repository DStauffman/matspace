function [value_str] = latex_str(value, varargin)

% LATEX_STR  Formats a given value for display in a LaTeX document.
%
% Change Log
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.

%% Parse Inputs
% create parser
p = inputParser;
% set options
addRequired(p, 'Value', @isnumeric);
addOptional(p, 'Digits', -1, @isnumeric);
addParameter(p, 'Fixed', false, @islogical);
addParameter(p, 'CMP2AR', false, @islogical);
addParameter(p, 'Capped', 1073741823, @isnumeric);
% do parse
parse(p, value, varargin{:});
% create some convenient aliases
digits = p.Results.Digits;
fixed  = p.Results.Fixed;
cmp2ar = p.Results.CMP2AR;
capped = p.Results.Capped;

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
    formatter = ['%:.', int2str(digits), letter];
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