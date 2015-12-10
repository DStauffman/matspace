function [board, cost, is_repeat, new_pos] = update_board(board, move, costs, transports, start_pos)

% UPDATE_BOARD  updates the new board based on the desired move.
%
% Input:
%     board .... : (MxN) board layout
%     move ..... : (scalar) move to be performed
%     costs .... : (MxN) costs for each square on the board layout
%     transports : (1x2) list of linearized locations of the transports
%     start_pos  : (scalar) starting linearized location of the knight
% 
% Output:
%     board .... : (MxN) updated board layout
%     cost ..... : (scalar) cost of the specified move type
%     is_repeat  : (scalar) boolean flag for whether the last move was a repeated visit or not
%     new_pos .. : (scalar) new linearized location of the knight
% 
% Prototype:
%     board      = zeros(2, 5);
%     move       = 2; % (2 right and 1 down)
%     costs      = ones(size(board));
%     transports = [];
%     start_pos  = 5;
%     board(start_pos) = PIECE_.current;
%     [board, cost, is_repeat, new_pos] = update_board(board, move, costs, transports, start_pos);
%     assert(cost == 1);
%     assert(is_repeat == false);
%     print_board(board);
%
%     % Gives:
%     . . x . .
%     . . . . K
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% initialize outputs
cost      = nan;
is_repeat = false;
% determine the board size
board_size = size(board);
% determine the move type
move_type = classify_move(board, move, transports, start_pos);
% if valid, apply the move
if move_type >= 0
    % set the current position to visited
    board(start_pos) = PIECE_.visited;
    % get the new position
    all_pos = get_new_position(board_size, start_pos, move, transports);
    new_pos = all_pos(3);
    % set the new position to current
    board(new_pos) = PIECE_.current;
    % determine what the cost was
    cost = costs(new_pos);
    if move_type == MOVE_.winning
        cost = -cost;
    elseif move_type == MOVE_.visited
        is_repeat = true;
    end
else
    new_pos = start_pos;
end