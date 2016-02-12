function [data] = initialize_data(board) %#codegen

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
% Notes:
%     1.  To support compilation, all the fields must be initialized before data can be used.
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

%% Hard-coded values
% max number of moves
max_moves = 100;

%% Aliases
% alias the board size
board_size = size(board);

%% initialize structure
data = struct();
% save original board for use in undoing moves
data.original_board = board;
% save the size of the board for use in subroutines
data.board_size = board_size;
% find transports
data.transports = get_transports(board);
% alias the final location for use at the end
temp = find(board == PIECE_.final);
if length(temp) ~= 1
    error('dstauffman:knight:BadFinalPos', 'There must be exactly one final position, not "%i".', length(temp));
end
data.final_pos  = temp(1);
% calculate the costs for landing on each square
data.costs = board_to_costs(board);
% crudely predict all the costs
data.pred_costs = predict_cost(board);
% initialize best costs on first run
data.best_costs = nan(board_size);
% initialize best solution
data.best_moves = [];
% initialize moves array and solved status
data.is_solved  = false;
data.all_moves  = nan(max_moves, numel(board));
data.all_boards = repmat(PIECE_.null, board_size(1), board_size(2), numel(board));
% initialize current cost and update in best_costs
data.current_cost = 0;
temp = find(board == PIECE_.start);
if length(temp) ~= 1
    error('dstauffman:knight:BadStartPos', 'There must be exactly one start position, not "%i".', length(temp));
end
temp = temp(1); % for compiler
data.best_costs(temp) = data.current_cost;
% create temp board and set the current position to the start
temp_board = board;
temp_board(temp) = PIECE_.current;
% store the first board
data.all_boards(:, :, temp) = temp_board;