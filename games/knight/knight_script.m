% The "knight" file solves the Knight Board puzzle given to Matt Beck during a job interview.
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015 based on Python version.
% 
% [Knight Board]
% The knight board can be represented in x,y coordinates.  The upper left position
% is (0,0) and the bottom right is (7,7).  Assume there is a single knight chess
% piece on the board that can move according to chess rules.  Sample S[tart] and
% E[nd] points are shown below:
%     . . . . . . . .
%     . . . . . . . .
%     . S . . . . . .
%     . . . . . . . .
%     . . . . . E . .
%     . . . . . . . .
%     . . . . . . . .
%     . . . . . . . .
% Level 1: Write a function that accepts a sequence of moves and reports
%     whether the sequence contains only valid knight moves.  It should also
%     optionally print the state of the knight board to the terminal as shown
%     above after each move.  The current position should be marked with a 'K'.
% Level 2: Compute a valid sequence of moves from a given start point to a given
%     end point.
% Level 3: Compute a valid sequence of moves from a given start point to a
%     given end point in the fewest number of moves.
% Level 4: Now repeat the Level 3 task for this 32x32 board.  Also, modify
%     your validator from Level 1 to check your solutions.  This board has the
%     following additional rules:
%         1) W[ater] squares count as two moves when a piece lands there
%         2) R[ock] squares cannot be used
%         3) B[arrier] squares cannot be used AND cannot lie in the path
%         4) T[eleport] squares instantly move you from one T to the other in
%             the same move
%         5) L[ava] squares count as five moves when a piece lands there
%     . . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
%     . . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .
%     . . . . . . . . B . . . L L L . . . L L L . . . . . . . . . . .
%     . . . . . . . . B . . . L L L . . L L L . . . R R . . . . . . .
%     . . . . . . . . B . . . L L L L L L L L . . . R R . . . . . . .
%     . . . . . . . . B . . . L L L L L L . . . . . . . . . . . . . .
%     . . . . . . . . B . . . . . . . . . . . . R R . . . . . . . . .
%     . . . . . . . . B B . . . . . . . . . . . R R . . . . . . . . .
%     . . . . . . . . W B B . . . . . . . . . . . . . . . . . . . . .
%     . . . R R . . . W W B B B B B B B B B B . . . . . . . . . . . .
%     . . . R R . . . W W . . . . . . . . . B . . . . . . . . . . . .
%     . . . . . . . . W W . . . . . . . . . B . . . . . . T . . . . .
%     . . . W W W W W W W . . . . . . . . . B . . . . . . . . . . . .
%     . . . W W W W W W W . . . . . . . . . B . . R R . . . . . . . .
%     . . . W W . . . . . . . . . . B B B B B . . R R . W W W W W W W
%     . . . W W . . . . . . . . . . B . . . . . . . . . W . . . . . .
%     W W W W . . . . . . . . . . . B . . . W W W W W W W . . . . . .
%     . . . W W W W W W W . . . . . B . . . . . . . . . . . . B B B B
%     . . . W W W W W W W . . . . . B B B . . . . . . . . . . B . . .
%     . . . W W W W W W W . . . . . . . B W W W W W W B B B B B . . .
%     . . . W W W W W W W . . . . . . . B W W W W W W B . . . . . . .
%     . . . . . . . . . . . B B B . . . . . . . . . . B B . . . . . .
%     . . . . . R R . . . . B . . . . . . . . . . . . . B . . . . . .
%     . . . . . R R . . . . B . . . . . . . . . . . . . B . T . . . .
%     . . . . . . . . . . . B . . . . . R R . . . . . . B . . . . . .
%     . . . . . . . . . . . B . . . . . R R . . . . . . . . . . . . .
%     . . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
%     . . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .
%     . . . . . . . . . . . B . . . . . . . . . . . . . . . . . . . .  % The last four rows originally missing
%     . . . . . . . . . . . B . . . R R . . . . . . . . . . . . . . .
%     . . . . . . . . . . . B . . . R R . . . . . . . . . . . . . . .
%     . . . . . . . . . . . B . . . . . . . . . . . . . . . . . . . .
% Level 5 [HARD]: Compute the longest sequence of moves to complete Level 3 without
%     visiting the same square twice.  Use the 32x32 board.

%% Inputs
BOARD1 = get_globals('board1');
BOARD2 = get_globals('board2');

do_steps = [-1 0 1 2 3 4 5];

print_seq = true;

%% Step -1 (Unit tests)
if ismember(-1, do_steps)
    % Run unit tests
end

%% convert board to numeric representation for efficiency
board1 = char_board_to_nums(BOARD1);
board2 = char_board_to_nums(BOARD2);

%% Step 0
if ismember(0, do_steps)
    disp('Step 0: print the boards.');
    fprintf(1, '\n%s\n', 'Board 1:');
    print_board(board1);
    fprintf(1, '\n%s\n', 'Board 2:');
    print_board(board2);
    fprintf('\n');
end

%% Step 1
if ismember(1, do_steps)
    disp('Step 1: See if the sequence is valid.');
    moves1 = [2 2];
    is_valid1 = check_valid_sequence(board1, moves1, true);
    if is_valid1 && print_seq
        print_sequence(board1, moves1);
    end
end

%% Step 3
if ismember(3, do_steps)
    disp('Step 3: solve the first board for the minimum length solution.');
    moves3 = solve_min_puzzle(board1);
    disp(moves3);
    is_valid3 = check_valid_sequence(board1, moves3, true);
    if is_valid3 && print_seq
        print_sequence(board1, moves3);
    end
end

%% Step 4
if ismember(4, do_steps)
    disp('Step 4: solve the second board for the minimum length solution.');
    board2(1) = PIECE_.start;
    % board2(1024) = PIECE_.final;
    board2(1004) = PIECE_.final;
    moves4 = solve_min_puzzle(board2);
    disp(moves4);
    is_valid4 = check_valid_sequence(board2, moves4, true);
    if is_valid4 && print_seq
        print_sequence(board2, moves4);
    end
end

%% Step 5
if ismember(5, do_steps)
    % TODO: write this
end

%% Step 10, alternate solver for testing
if ismember(10, do_steps)
    disp('Step 10: solve a test board for the minimum length solution.');
    board3 = repmat(PIECE_.null, 6, 5);
    board3(:,3) = PIECE_.barrier;
    board3(1,1) = PIECE_.start;
    board3(6,4) = PIECE_.final;
    board3(5,1) = PIECE_.transport;
    board3(2,4) = PIECE_.transport;
    print_board(board3);
    fprintf('\n');
    moves10 = solve_min_puzzle(board3);
    is_valid10 = check_valid_sequence(board3, moves10, true);
    disp(moves10);
    if is_valid10
        print_sequence(board3, moves10);
    end
end