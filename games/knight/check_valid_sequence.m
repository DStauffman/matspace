function [is_valid] = check_valid_sequence(board, moves, print_status, allow_repeats)

% CHECK_VALID_SEQUENCE  Checks that the list of moves is a valid sequence to go from start to final position.

% Input:
%     board ....... : (MxN) board layout
%     moves ....... : (1xA) list of moves to be performed
%     print_status  : |opt| (scalar) boolean flag for whether to print the board after each move is made, default is false
%     allow_repeats : |opt| (scalar) boolean flag for whether to allow repeat visits to the same square, default is false
%
% Output:
%     is_valid : (scalar) boolean flag for whether the sequence is valid or not
%
% Prototype:
%     board = zeros(3, 5);
%     board(1, 1) = PIECE_.start;
%     board(3, 5) = PIECE_.final;
%     moves = [2 2];
%     is_valid = check_valid_sequence(board, moves);
%     assert(is_valid);
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% check for optional inputs
switch nargin
    case 2
        print_status  = false;
        allow_repeats = false;
    case 3
        allow_repeats = false;
    case 4
        % nop
    otherwise
        error('dstauffman:knight:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% initialize output
is_valid = true;
is_done  = false;

% determine the costs
costs = board_to_costs(board);
% find transports
transports = get_transports(board);
% create internal board for calculations
temp_board = board;
% get the board size
board_size = size(board);
% set the current position to the start
temp_board(temp_board == PIECE_.start) = PIECE_.current;
pos = get_current_position(temp_board);
% check that the board has a final goal
if ~any(temp_board == PIECE_.final)
    error('dstauffman:knight:FinalPos','The board does not have a finishing location.');
end
% loop through moves
for i = 1:length(moves)
    % alias this move
    this_move = moves(i);
    % update the board and determine the cost
    [temp_board, cost, is_repeat, pos] = update_board(temp_board, this_move, costs, transports, pos, board_size);
    % if cost was zero, then the move was invalid
    if isnan(cost)
        is_valid = false;
        break
    end
    % check for repeated conditions
    if ~allow_repeats && is_repeat
        is_valid = false;
        if print_status
            disp('No repeats allowed.');
        end
        break
    end
    % check for winning conditions (based on negative cost value)
    if cost < 0
        is_done = true;
        if i < length(moves)
            error('dstauffman:knight:FinishedPlus', 'Sequence finished, but then kept going.');
        end
    end
end
if print_status
    if is_valid
        if is_done
            disp('Sequence is valid and finished the puzzle.');
        else
            disp('Sequence is valid, but did not finish the puzzle.');
        end
    else
        disp('Sequence is not valid.');
    end
end