classdef(Enumeration) MOVE_ < int32

% MOVE_  is a enumerator class definition for the possible move types.
%
% Input:
%     None
%
% Output:
%     MOVE_               : (enum) possible move types
%         .off_board = -2 : Invalid due to being off the board
%         .blocked   = -1 : Blocked move due to barrier
%         .visited   =  0 : Previously visited location
%         .normal    =  1 : Normal and valid move
%         .transport =  2 : Move that used a transport
%         .water     =  3 : Move that landed on water
%         .lava      =  4 : Move that landed on lava
%         .winning   =  5 : Move that finished the puzzle
%
% Prototype:
%     MOVE_.off_board         % returns 'off_board' as an enumeratod MOVE_ type
%     double(MOVE_.off_board) % returns -2, which is the enumerated value of MOVE_.off_board
%
% See Also:
%     None
%
% Notes:
%     1.  The int32 type is used for compatibility with the coder.
%     2.  Enumerator file name format employs all capitals followed by a single
%         underscore for consistency and enumerator identification.
%
% Change Log:
%     1.  Written by David Stauffer in December 2015.

    enumeration
        off_board(-2)
        blocked(-1)
        visited(0)
        normal(1)
        transport(2)
        water(3)
        lava(4)
        winning(5)
    end
end