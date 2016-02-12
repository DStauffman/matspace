function [move_type] = classify_move(board, move, transports, start_pos, board_size) %#codegen

% CLASSIFY_MOVE  determines if the desired move is valid or not, and what type of move/cost it would have.
%
% Input:
%     board .... : (MxN) board layout
%     move ..... : (scalar) move to be performed
%     transports : (1x2) list of linearized locations of the transports
%     start_pos  : (scalar) starting linearized location of the knight
%     board_size : (1x2) size of the board
%
% Output:
%     move_type  : (MOVE_) move enum
%
% Prototype:
%     board      = zeros(2,5);
%     move       = 2; % (2 right and 1 down)
%     transports = [];
%     start_pos  = 5;
%     board(start_pos) = PIECE_.current;
%     board_size = size(board);
%     move_type  = classify_move(board, move, transports, start_pos, board_size);
%     assert(move_type == MOVE_.normal);
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% find the traversal for the desired move
all_pos = get_new_position(board_size, start_pos, move, transports);

% check that the final and intermediate positions were all on the board
if any(isnan(all_pos))
    move_type = MOVE_.off_board;
    return
end

% get the values for each position
p1 = board(all_pos(1));
p2 = board(all_pos(2));
p3 = board(all_pos(3));

% check for error conditions
if p3 == PIECE_.start || p3 == PIECE_.current
    error('dstauffman:knight:InvalidLocation', 'The piece should never be able to move to it''s current or starting position.');
end

% check for blocked conditions
if p3 == PIECE_.rock || p3 == PIECE_.barrier || p1 == PIECE_.barrier || p2 == PIECE_.barrier
    move_type = MOVE_.blocked;
    return
end

% remaining moves are valid, determine type
switch p3
    case PIECE_.visited
        move_type = MOVE_.visited;
    case PIECE_.null
        move_type = MOVE_.normal;
    case PIECE_.final
        move_type = MOVE_.winning;
    case PIECE_.transport
        move_type = MOVE_.transport;
    case PIECE_.water
        move_type = MOVE_.water;
    case PIECE_.lava
        move_type = MOVE_.lava;
    otherwise
        error('dstauffman:knight:BadPieceType', 'Unexpected piece type.'); %TODO: print type that works for the compiler
        %error('dstauffman:knight:BadPieceType', 'Unexpected piece type "%s.%s".', class(p3), char(p3));
end