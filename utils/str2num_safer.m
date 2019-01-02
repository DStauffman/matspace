function [value] = str2num_safer(str)

% STR2NUM_SAFER  converts a string to double, but allows some operations, such as multiplication.
%
% Summary:
%     Calls str2double first, if that works, then good.  If not, then check for allowed characters
%     and then call eval.
%
% Input:
%     str : (char) string to evaluate
%
% Output:
%     value : (scalar) numeric value of str, NaN if invalid
%
% Prototype:
%     value = str2num_safer('60');
%     assert(value == 60);
%     value = str2num_safer('30*3600');
%     assert(value == 108000);
%     value = str2num_safer('rm -rf *');
%     assert(isnan(value));
%
% See Also:
%     str2double, eval
%
% Change Log:
%     1.  Written by David C. Stauffer in July 2018.

% nominal output based on str2double function
value = str2double(str);

% check for more complicated cases
if isnan(value)
    % if not just a simple number, then check for allowed characters
    allowed = '0123456789.*';
    for i = 1:length(str)
        this_char = str(i);
        if ~contains(allowed, this_char)
            % if any characters are not allowed, return NaN
            value = nan;
            return
        end
    end
    % do eval if all characters are valid
    value = eval(str);
    if isempty(value)
        value = Nan;
    end
end