function [transports] = get_transports(board)

% GET_TRANSPORTS  gets the locations of all the transports.
%
% Input:
%     board : (MxN) board layout
%
% Output:
%     transports : (1x2) or (empty) array of linearized transport locations
%
% Prototype:
%     board = repmat(PIECE_.null, 3, 3);
%     board(1, 2) = PIECE_.transport;
%     board(3, 3) = PIECE_.transport;
%     transports  = get_transports(board);
%     assert(all(transports == [4 9]));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

if any(any(board == PIECE_.transport))
    transports = find(board == PIECE_.transport)';
    if length(transports) ~= 2
        error('knight:BadTransports', 'There must be 0 or exactly 2 transports.');
    end
else
    transports = [];
end