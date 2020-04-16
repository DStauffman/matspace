function [y] = unit(x, dim)

% UNIT  creates a unit vector along the specified dimension.
%
% Input:
%     x   : array of vectors
%     dim : dimesion to process along, defaults to first non-singleton dimension
%
% Output:
%     y   : normalized array of vectors
%
% Prototype:
%     x = [1 1 1 1; 2 3 2 3; 4 5 6 7];
%     y = matspace.utils.unit(x, 2);
%
% See Also:
%     matspace.utils.rms, rms, vecnorm
%
% Change Log:
%     1.  Added to the matspace library in December 2015.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% check for optional inputs
switch nargin
    case 1
        dim = find(size(x) > 1, 1, 'first');
        if isempty(dim)
            dim = 1;
        end
    case 2
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% calculate unit vector
y = x ./ realsqrt(sum(x.*conj(x),dim));