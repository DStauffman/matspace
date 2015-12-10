classdef(Enumeration) PIECE_ < int32

% PIECE_  is a enumerator class definition for the possible piece types.
%
% Input:
%     None
%
% Output:
%     PIECE_             : (enum) possible piece types
%         .null      = 0 : Empty square that has never been used
%         .start     = 1 : Original starting position
%         .final     = 2 : Final ending position
%         .current   = 3 : Current knight position
%         .water     = 4 : water, costs two moves to land on
%         .rock      = 5 : rock, can be jumped across, but not landed on
%         .barrier   = 6 : barrier, cannot be landed on or moved across
%         .transport = 7 : transport to the other transport, can only be exactly 0 or 2 on the board
%         .lava      = 8 : lava, costs 5 moves to land on
%         .visited   = 9 : previously visited square that cannot be used again
%
% Prototype:
%     PIECE_.water         % returns 'water' as an enumeratod PIECE_ type
%     double(PIECE_.water) % returns 4, which is the enumerated value of PIECE_.water
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
        null(0)
        start(1)
        final(2)
        current(3)
        water(4)
        rock(5)
        barrier(6)
        transport(7)
        lava(8)
        visited(9)
    end
end