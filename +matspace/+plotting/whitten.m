function [new_color] = whitten(color, dt, white)

% WHITTEN  shifts an RGBA color towards white.
%
% Input:
%     color : (3xN) given color RGB triple
%     dt    : (scalar) |opt| Amount to move towards white, from 0 (none) to 1 (all the way), default is 0.3
%     white : (3x1) |opt|, color to *whitten* towards, usually assumed to be white
%
% Output
%     new_color : (3xN) new whitten color
%
% Prototype:
%     color = [1 0.4 0];
%     new_color = matspace.plotting.whitten(color);
%     assert(all(new_color == [1.0 0.58 0.3]));
%
% Change Log:
%     1.  Ported from Python to MATLAB by David C. Stauffer in February 2019.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% optional inputs
switch nargin
    case 1
        dt = 0.3;
        white = ones(size(color));
    case 2
        white = ones(size(color));
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% apply the shift
new_color = color * (1-dt) + white*dt;