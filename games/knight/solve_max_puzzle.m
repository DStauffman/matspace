function [moves] = solve_max_puzzle(board)

% SOLVE_MAX_PUZZLE  puzzle solver.  Uses a depth first approach to solve for the maximum length
%     nonrepeating solution.
%
% Input:
%     board : (MxN) board layout
%
% Output:
%     moves : (1xA) list of moves to solve the puzzle, empty if no solution
%
% Prototype:
%     board = repmat(PIECE_.null, 2,5);
%     board[0, 0] = PIECE_.start;
%     board[0, 4] = PIECE_.final;
%     moves = solve_min_puzzle(board);
%     % assert(all(moves == [2 -2]))); % TODO: update this
%
%     % Gives:
%     Initializing solver.
%     Solution found for cost of: 8.
%     Elapsed time : ...
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% start timer
start_solver = now;

% initialize the data structure for the solver
disp('Initializing solver.');

% check that the board has a final goal
if ~any(board == PIECE_.final)
    error('dstauffman:knight:FinalPos', 'The board does not have a finishing location.');
end

% display the elapsed time
disp(['Elapsed time : ' datestr(now - start_solver, 'HH:MM:SS')]);

moves = []; % TODO: for now output an empty list