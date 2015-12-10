function [x, y] = get_current_position(board)
    
% GET_CURRENT_POSITION  gets the current position of the knight.
%
% Input:
%     board : (MxN) board layout
% 
% Output:
%     x : (scalar) current X position
%     y : (scalar) current Y position
% 
% Prototype:
%     board = zeros(5,5);
%     board(2,5) = PIECE_.current;
%     [x, y] = get_current_position(board);
%     assert(x == 2 & y == 5);
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% find position
pos = find(board == PIECE_.current);

% check that only exactly one current position was found, and if not, print the messed up board
num_current = length(pos);
if num_current ~= 1
    print_board(board);
    if num_current == 0
        error('knight:NoCurrent', 'No current position was found.');
    else
        error('knight:TooManyCurrent', 'Only exactly one current position may be found, not %i.', length(pos));
    end
end

if nargout == 2
    % convert to x and y locations
    [x, y] = ind2sub(size(board), pos);
else
    x = pos;
end