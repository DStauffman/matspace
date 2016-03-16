function [moves, data] = solve_min_puzzle(board)

% SOLVE_MIN_PUZZLE  puzzle solver.  Uses a breadth first approach to solve for the minimum length solution.
%
% Input:
%     board : (MxN) board layout
%
% Output:
%     moves : (1xA) list of moves to solve the puzzle, empty if no solution
%     data  : (struct) data structure for more diagnostics
%
% Prototype:
%     board = repmat(PIECE_.null, 2,5);
%     board[0, 0] = PIECE_.start;
%     board[0, 4] = PIECE_.final;
%     moves = solve_min_puzzle(board);
%     assert(all(moves == [2 -2])));
%
%     % Gives:
%     Initializing solver.
%     Solution found for cost of: 2.
%     Elapsed time : ...
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% coder dependencies
coder.extrinsic('now', 'datestr');

% hard-coded values
MAX_ITERS = 25;

% start timer
start_solver  = 0; %#ok<NASGU> % for compiler to know type
finish_solver = 0; %#ok<NASGU> % for compiler to know type
start_solver  = now;

% initialize the data structure for the solver
disp('Initializing solver.');

% check that the board has a final goal
if ~any(any(board == PIECE_.final))
    error('dstauffman:knight:FinalPos', 'The board does not have a finishing location.');
end

% initialize the data structure
data = initialize_data(board);

% solve the puzzle
for this_iter = 1:MAX_ITERS
    next_moves = find(data.best_costs == data.current_cost);
    for ix = 1:length(next_moves)
        start_pos = next_moves(ix);
        % update the current board and moves for the given position
        temp_board = data.all_boards(:, :, start_pos);
        % call solver for this move
        data = solve_next_move(temp_board, data, start_pos);
    end
    % increment the minimum cost and continue
    data.current_cost = data.current_cost + 1;
end

% if the puzzle was solved, then save the relevant move list
if data.is_solved
    moves = data.all_moves(:,data.final_pos)';
    moves = moves(~isnan(moves));
else
    disp('No solution found.');
    moves = [];
end

% display the elapsed time
finish_solver = now;
disp(['Elapsed time : ',datestr(finish_solver - start_solver, 'HH:MM:SS')]);