function [] = print_sequence(board, moves)

% PRINT_SEQUENCE  prints the every board position for the given move sequence.
%
% Input:
%     board : (MxN) board layout
%     moves : (1xA) moves to be performed
%
% Output:
%     None
% 
% Prototype:
%     board = zeros(3, 5);
%     board(1, 1) = PIECE_.start;
%     board(3, 5) = PIECE_.final;
%     moves = [2 2];
%     print_sequence(board, moves);
%
%     %Gives:
%     Starting position:
%     S . . . .
%     . . . . .
%     . . . . E
%
%     After move 1, cost: 1
%     x . . . .
%     . . K . .
%     . . . . E
%   
%     After move 2, cost: 2
%     x . . . .
%     . . x . .
%     . . . . K
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% determine costs
costs = board_to_costs(board);
% find transports
transports = get_transports(board);
% create internal board for calculations
temp_board = board;
% get the board size
board_size = size(board);
% print status
disp('Starting position:');
print_board(temp_board);
% set the current position to the start
temp_board(temp_board == PIECE_.start) = PIECE_.current;
pos = get_current_position(temp_board);
% initialize total costs
total_cost = 0;
% loop through move sequence
for i = 1:length(moves)
    % alias this move
    this_move = moves(i);
    % update board
    [temp_board, cost, ~, pos] = update_board(temp_board, this_move, costs, transports, pos, board_size);
    if ~isnan(cost)
        % update total costs
        total_cost = total_cost + abs(cost);
        % print header
        fprintf(1,'\nAfter move %i, cost: %i\n',i, total_cost);
        % print new board
        print_board(temp_board);
    else
        error('dstauffman:knight:BadSequence', 'Bad sequence.');
    end
end