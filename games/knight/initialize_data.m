function [data] = initialize_data(board)

% INITIALIZE_DATA  initializes the internal data structure for use in the solver.
% 
% Input:
%     board : (MxN) board layout
% 
% Output:
%     data : (struct) internal data structure for use in the solver. Contains the following fields:
%         .all_boards
%         .all_moves
%         .best_costs
%         .best_moves
%         .costs
%         .current_cost
%         .final_loc
%         .is_solved
%         .moves
%         .original_board
%         .pred_costs
%         .transports
% 
% Prototype:
%     board    = repmat(PIECE_.null, 2, 5);
%     board(1) = PIECE_.start;
%     board(9) = PIECE_.final;
%     data = initialize_data(board);
%     assert(all(ismember(sort(fieldnames(data)),{'all_boards'; 'all_moves'; 'best_costs'; ...
%         'best_moves'; 'costs'; 'current_cost'; 'final_pos'; 'is_solved'; 'moves'; ...
%         'original_board'; 'pred_costs'; 'transports'})));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

%% initialize dictionary
data = struct();
% save original board for use in undoing moves
data.original_board = board;
% find transports
data.transports = get_transports(board);
% alias the final location for use at the end
temp = find(board == PIECE_.final);
assert(length(temp) == 1, 'There must be exactly one final position.');
data.final_pos = temp(1);
% calculate the costs for landing on each square
data.costs = board_to_costs(board);
% crudely predict all the costs
data.pred_costs = predict_cost(board);
% initialize best costs on first run
data.best_costs = nan(size(board));
% initialize best solution
data.best_moves = [];
% initialize moves array and solved status
data.moves = [];
data.is_solved = false;
data.all_moves = arrayfun(@(x) zeros(1,0), 1:numel(board), 'UniformOutput', false);
data.all_boards = nan(size(board,1), size(board,2), numel(board));
% initialize current cost and update in best_costs
data.current_cost = 0;
temp = find(board == PIECE_.start);
assert(length(temp) == 1, 'There must be exactly one start position.');
data.best_costs(temp) = data.current_cost;
% create temp board and set the current position to the start
temp_board = board;
temp_board(temp) = PIECE_.current;
% store the first board
data.all_boards(:, :, temp) = temp_board;