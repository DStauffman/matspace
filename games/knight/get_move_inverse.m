function [inv_move] = get_move_inverse(move)

% GET_MOVE_INVERSE  gets the inverse move to go back where you were:
%     -/+1 <-> -/+3
%     -/+2 <-> -/+4
%
% Input:
%     move : (scalar) move to be performed
%
% Output:
%     inv_move : (scalar) move that will undo the last one
%
% Prototype:
%     inv_move = get_move_inverse(-1);
%     assert(inv_move == -3);
%     inv_move = get_move_inverse(-3);
%     assert(inv_move == -1);
%     inv_move = get_move_inverse(2);
%     assert(inv_move == 4);
%     inv_move = get_move_inverse(4);
%     assert(inv_move == 2);
%
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% check that move is valid
if ~ismember(move, get_globals('moves'))
    error('dstauffman:knight:InvalidInvMove', 'Invalid move.');
end

% reverse move
inv_move = sign(move) * (mod(abs(move) + 1, 4) + 1);