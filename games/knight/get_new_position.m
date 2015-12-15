function [all_pos] = get_new_position(board_size, pos, move, transports)

% GET_NEW_POSITION  gets the new position of the knight after making the desired move.
%
% Input:
%     board_size : (1x2) size of the board
%     pos ...... : (scalar) current linearized position
%     move ..... : (scalar) move to be performed
%     transports : (1x2) or (empty) list of linearized transport locations
%
% Output:
%     all_pos : (3x1) list of linearized positions
%
% Prototype:
%     board_size = [5 5];
%     pos        = 12;
%     move       = 2; % (2 right and 1 down)
%     transports = [];
%     all_pos    = get_new_position(board_size, pos, move, transports);
%     assert(all(all_pos == [17; 22; 23]));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% convert current position to X & Y locations
[x, y] = ind2sub(board_size, pos);

% move the piece
switch move
    case -1
        delta = [-1  0; -2  0; -2 -1];
    case 1
        delta = [-1  0; -2  0; -2  1];
    case -2
        delta = [ 0  1;  0  2; -1  2];
    case 2
        delta = [ 0  1;  0  2;  1  2];
    case -3
        delta = [ 1  0;  2  0;  2  1];
    case 3
        delta = [ 1  0;  2  0;  2 -1];
    case -4
        delta = [ 0 -1;  0 -2;  1 -2];
    case 4
        delta = [ 0 -1;  0 -2; -1 -2];
    case {-5, 5, -6, 6, -7, 7, -8, 8}
        error('knight:BadExtendedMoves', 'Extended moves are not yet implemented.');
    otherwise
        error('knight:InvalidMoveValue', 'Invalid move of "%i"', move);
end

% update X & Y locations
new_xy = bsxfun(@plus, [x, y], delta);

% check for out of limit conditions
new_xy(new_xy < 1) = nan;
new_xy(new_xy(:,1) > board_size(1),1) = nan;
new_xy(new_xy(:,2) > board_size(2),2) = nan;

% convert back to linearized locations (explicit isnan check necessary for compiler)
if any(any(isnan(new_xy)))
    all_pos = nan(3, 1);
    return
else
    all_pos = sub2ind(board_size, new_xy(:,1), new_xy(:,2));
end

% handle landing on a transport
if ~isempty(transports)
    if length(transports) ~= 2
        error('knight:NumTransports','There must be exactly 0 or 2 transports, not %i.',length(transports));
    end
    if ismember(all_pos(3),transports)
        if all_pos(3) == transports(1)
            all_pos(3) = transports(2);
        elseif all_pos(3) == transports(2)
            all_pos(3) = transports(1);
        end
    end
end