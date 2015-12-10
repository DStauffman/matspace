function [] = print_board(board)

% Prints the current board position to the console window.
%
% Input:
%     board : (NxM) board layout
%
% Output:
%     None
%
% Prototype:
%     board = zeros(3,5);
% 	  board(1,3) = PIECE_.current;
% 	  print_board(board);
%
%     % Gives:
%     . . K . .
%     . . . . .
%     . . . . .
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% hard-coded values
% ordered list of characters
chars = get_globals('chars');

% get the board shape
[rows, cols] = size(board);

% build some pads of spaces and newlines
pads  = repmat([repmat(' ', 1, cols-1), char(10)], 1, rows);

% combine the characters and the pads
text  = [chars(reshape(transpose(board),1, [])+1); pads];

% print the results
fprintf(text(:))