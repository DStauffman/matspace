function [] = display_error(hObject,result)

% DISPLAY_ERROR  displays an error message in the edit box, and the sets to a valid value.
%
% Input:
%     hObject : (scalar) handle to the edit box with the error [num]
%     result  : (scalar) Original, presumably valid value to set back at the end [num or char]
%
% Output:
%     (None)
%
% Prototype:
%     % TBD
%
% See Also:
%     bac_gui.m
%
% NOTES:
%     1.  This function could be updated to change the text to red and back or something similar.
%
% Change Log:
%     1.  Written by David C. Stauffer in Apr 2012.

% display the error statement
set(hObject, 'String', 'Error!')

% pause for a bit
pause(1);

% change back to valid value
if isnumeric(result)
    set(hObject, 'String', num2str(result));
else
    set(hObject, 'String', result);
end