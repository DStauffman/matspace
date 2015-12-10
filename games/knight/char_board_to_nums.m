function [board] = char_board_to_nums(char_board)

% CHAR_BOARD_TO_NUMS  converts the original board from a character array into a matrix of numbers.
% 
% Input:
%     char_board : (MxN) of (char) board as an original character array
% 
% Output:
%     board : (MxN) board layout
% 
% Prototype:
%     char_board = ['. . S . .'; '. . . . E'];
%     board = char_board_to_nums(char_board);
%     assert(all(all(board == [0 0 1 0 0; 0 0 0 0 2])));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% get ordered list of characters
chars = get_globals('chars');

% remove the spaces
temp_board = char_board(char_board ~= ' ');

% preallocate the numeric version
num_board = zeros(size(temp_board));

% loop through and convert to numbers
for i = 1:length(chars)
    num_board(temp_board == chars(i)) = i-1;
end

% find the number of rows
rows = size(char_board, 1);

% output the final board
board = reshape(num_board, rows, []);