function [sorted_moves] = sort_best_moves(moves, costs, transports, start_pos, board_size)

% SORT_BEST_MOVES  sorts the given moves into the most likely best order based on a predicted cost.
%
% Inptu:
%     moves .... : (1xA) list of possible moves to check
%     costs .... : (MxN) predicted cost to finish
%     transports : (1x2) or (empty) location of the transports
%     start_pos  : (scalar) starting linearized location of the knight
%     board_size : (1x2) size of the board
% 
% Output:
%     sorted_moves : (1xB) valid moves sorted by most likely first
% 
% Prototype:
%     board        = repmat(PIECE_.null, 5, 8);
%     board(13)    = PIECE_.current;
%     board(40)    = PIECE_.final;
%     moves        = get_globals('moves');
%     costs        = predict_cost(board);
%     transports   = zeros(1, 0);
%     start_pos    = 13;
%     board_size   = size(board);
%     sorted_moves = sort_best_moves(moves, costs, transports, start_pos, board_size);
%     assert(all(sorted_moves == [-3, 2]));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% initialize the costs
pred_costs = nan(size(moves));
for ix = 1:length(moves)
    move = moves(ix);
    all_pos = get_new_position(board_size, start_pos, move, transports);
    new_pos = all_pos(3);
    if ~isnan(new_pos)
        pred_costs(ix) = costs(new_pos);
    end
end
[~, sorted_ix] = sort(pred_costs);
sorted_ix2     = sorted_ix(~isnan(pred_costs(sorted_ix)));
sorted_moves   = moves(sorted_ix2);