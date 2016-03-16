function [board] = undo_move(board, last_move, original_board, transports, start_pos)

% UNDO_MOVE  undoes the last move on the board.
%
% Input:
%     board ........ : (MxN) board layout
%     last_move .... : (scalar) Last move that was previously performed
%     original_board : (MxN) original board layout before starting solver
%     transports ... : (1x2) list of linearized location of the transports
%     start_pos .... : (scalar) starting linearized location of the knight
%
% Output:
%     board ........ : (MxN) updated board position
%
% Prototype:
%     board             = repmat(PIECE_.null, 2, 5);
%     board(5)          = PIECE_.visited;
%     last_move         = 2; % (2 right and 1 down)
%     original_board    = repmat(PIECE_.null, 2, 5);
%     original_board(5) = PIECE_.start;
%     transports        = zeros(1, 0);
%     start_pos         = 10;
%     board(start_pos)  = PIECE_.current;
%     print_board(board);
%     . . x . .
%     . . . . K
%
%     board = undo_move(board, last_move, original_board, transports, start_pos);
%     print_board(board);
%     . . K . .
%     . . . . .
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% set the current position back to it's original piece
if original_board(start_pos) == PIECE_.start
    board(start_pos) = PIECE_.null;
else
    board(start_pos) = original_board(start_pos);
end
% find the inverse move
new_move = get_move_inverse(last_move);
% if on a transport, then undo travel it first
if ~isempty(transports)
    assert(length(transports) == 2, 'There must be exactly 0 or 2 transports.');
    if ismember(start_pos, transports)
        if start_pos == transports(1)
            start_pos = transports(2);
        elseif start_pos == transports(2)
            start_pos = transports(1);
        end
    end
end
% get the new position (without traversing transports)
all_pos = get_new_position(size(original_board), start_pos, new_move, zeros(1, 0));
% set the new position to current
board(all_pos(3)) = PIECE_.current;