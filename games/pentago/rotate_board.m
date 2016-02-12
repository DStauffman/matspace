function [new_pos] = rotate_board(old_pos,quad,dir)

% ROTATE_BOARD  rotates the specified board position.
%
% Input:
%     old_pos : (6x6) board position [num]
%     quad    : (scalar) quadrant to rotate [enum]
%     dir     : (scalar) direction to rotate [enum]
%
% Output:
%     new_pos : (6x6) New board position after completing move [num]
%
% Prototype:
%     old_pos = reshape([1 1 1 1 1 0 zeros(1,30)],6,6);
%     new_pos = rotate_board(old_pos,1,1);
%
% Written by David Stauffer in Jan 2010.
% Updated by David Stauffer in Feb 2010 to rotate multiple 36xN boards all in one call.

% determine if 6x6 board or 36xN
[r,c] = size(old_pos);

if r == 6 && c == 6
    % get quad
    switch quad
        case 1
            old_sub = old_pos([01 07 13; 02 08 14; 03 09 15]);
        case 2
            old_sub = old_pos([19 25 31; 20 26 32; 21 27 33]);
        case 3
            old_sub = old_pos([04 10 16; 05 11 17; 06 12 18]);
        case 4
            old_sub = old_pos([22 28 34; 23 29 35; 24 30 36]);
        otherwise
            error('dstauffman:pentago:BadQuad', 'Unexpected value for quad');
    end
    
    % rotate quad
    switch dir
        case 0
            new_sub = rotate_left(old_sub);
        case 1
            new_sub = rotate_right(old_sub);
        otherwise
            error('dstauffman:pentago:BadDir', 'Unexpected value for dir');
    end
    
    % place rotated quad
    new_pos = old_pos;
    switch quad
        case 1
            new_pos([01 07 13; 02 08 14; 03 09 15]) = new_sub;
        case 2
            new_pos([19 25 31; 20 26 32; 21 27 33]) = new_sub;
        case 3
            new_pos([04 10 16; 05 11 17; 06 12 18]) = new_sub;
        case 4
            new_pos([22 28 34; 23 29 35; 24 30 36]) = new_sub;
    end
elseif r == 36
    % get quad
    switch quad
        case 1
            ix_old = [01 02 03 07 08 09 13 14 15];
        case 2
            ix_old = [19 20 21 25 26 27 31 32 33];
        case 3
            ix_old = [04 05 06 10 11 12 16 17 18];
        case 4
            ix_old = [22 23 24 28 29 30 34 35 36];
        otherwise
            error('dstauffman:pentago:BadQuad', 'Unexpected value for quad');
    end
    % rotate quad
    switch dir
        case 0
            ix_new = ix_old([7 4 1 8 5 2 9 6 3]);
        case 1
            ix_new = ix_old([3 6 9 2 5 8 1 4 7]);
        otherwise
            error('dstauffman:pentago:BadDir', 'Unexpected value for dir');
    end
    % update placements
    new_pos = old_pos;
    new_pos(ix_old,:) = old_pos(ix_new,:);
else
    error('dstauffman:pentago:BadBoardSize', 'Unexpected value for board size.');
end


%% Subfunctions
function [new] = rotate_left(old)
% ROTATE_LEFT  rotates the quadrant to the left (counter-clockwise)
new = old([7 8 9; 4 5 6; 1 2 3]);

function [new] = rotate_right(old)
% ROTATE_RIGHT  rotates the quadrant to the right (clockwise)
new = old([3 2 1; 6 5 4; 9 8 7]);