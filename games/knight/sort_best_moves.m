function [sorted_moves] = sort_best_moves(board, moves, costs, transports, start_pos)

% SORT_BEST_MOVES  sorts the given moves into the most likely best order based on a predicted cost.
%
% Inptu:
%     board .... : (MxN) board layout
%     moves .... : (1xA) list of possible moves to check
%     costs .... : (MxN) predicted cost to finish
%     transports : (1x2) or (empty) location of the transports
%     start_pos  : (scalar) starting linearized location of the knight
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
%     transports   = [];
%     start_pos    = 13;
%     sorted_moves = sort_best_moves(board, moves, costs, transports, start_pos);
%     assert(all(sorted_moves == [-3, 2]));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% initialize the costs
pred_costs = nan(size(moves));
for ix = 1:length(moves)
    move = moves(ix);
    all_pos = get_new_position(size(board), start_pos, move, transports);
    new_pos = all_pos(3);
    if ~isnan(new_pos)
        pred_costs(ix) = costs(new_pos);
    end
end
[~, sorted_ix] = sort(pred_costs);
sorted_ix(isnan(pred_costs(sorted_ix))) = [];
sorted_moves = moves(sorted_ix);