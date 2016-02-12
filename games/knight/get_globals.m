function [out] = get_globals(value)

% GET_GLOBALS  returns the desired global variable

switch value
    case 'board1'
        out = [
            '. . . . . . . .'
            '. . . . . . . .'
            '. S . . . . . .'
            '. . . . . . . .'
            '. . . . . E . .'
            '. . . . . . . .'
            '. . . . . . . .'
            '. . . . . . . .'
            ];
    case 'board2'
        out = [
            '. . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .'
            '. . . . . . . . B . . . L L L . . . . . . . . . . . . . . . . .'
            '. . . . . . . . B . . . L L L . . . L L L . . . . . . . . . . .'
            '. . . . . . . . B . . . L L L . . L L L . . . R R . . . . . . .'
            '. . . . . . . . B . . . L L L L L L L L . . . R R . . . . . . .'
            '. . . . . . . . B . . . L L L L L L . . . . . . . . . . . . . .'
            '. . . . . . . . B . . . . . . . . . . . . R R . . . . . . . . .'
            '. . . . . . . . B B . . . . . . . . . . . R R . . . . . . . . .'
            '. . . . . . . . W B B . . . . . . . . . . . . . . . . . . . . .'
            '. . . R R . . . W W B B B B B B B B B B . . . . . . . . . . . .'
            '. . . R R . . . W W . . . . . . . . . B . . . . . . . . . . . .'
            '. . . . . . . . W W . . . . . . . . . B . . . . . . T . . . . .'
            '. . . W W W W W W W . . . . . . . . . B . . . . . . . . . . . .'
            '. . . W W W W W W W . . . . . . . . . B . . R R . . . . . . . .'
            '. . . W W . . . . . . . . . . B B B B B . . R R . W W W W W W W'
            '. . . W W . . . . . . . . . . B . . . . . . . . . W . . . . . .'
            'W W W W . . . . . . . . . . . B . . . W W W W W W W . . . . . .'
            '. . . W W W W W W W . . . . . B . . . . . . . . . . . . B B B B'
            '. . . W W W W W W W . . . . . B B B . . . . . . . . . . B . . .'
            '. . . W W W W W W W . . . . . . . B W W W W W W B B B B B . . .'
            '. . . W W W W W W W . . . . . . . B W W W W W W B . . . . . . .'
            '. . . . . . . . . . . B B B . . . . . . . . . . B B . . . . . .'
            '. . . . . R R . . . . B . . . . . . . . . . . . . B . . . . . .'
            '. . . . . R R . . . . B . . . . . . . . . . . . . B . T . . . .'
            '. . . . . . . . . . . B . . . . . R R . . . . . . B . . . . . .'
            '. . . . . . . . . . . B . . . . . R R . . . . . . . . . . . . .'
            '. . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .'
            '. . . . . . . . . . . B . . . . . . . . . . R R . . . . . . . .'
            '. . . . . . . . . . . B . . . . . . . . . . . . . . . . . . . .'
            '. . . . . . . . . . . B . . . R R . . . . . . . . . . . . . . .'
            '. . . . . . . . . . . B . . . R R . . . . . . . . . . . . . . .'
            '. . . . . . . . . . . B . . . . . . . . . . . . . . . . . . . .'
            ];
    case 'chars'
        out = '.SEKWRBTLx';
    case 'costs'
        out = struct('normal', 1, 'transport', 1, 'water', 2, 'lava', 5, 'invalid', nan, 'start', 0);
    case 'moves'
        out = [-4 -3 -2 -1 1 2 3 4];
        % Move design is based on a first direction step of two moves, followed by a single step to the
        % left or right of the first one.
        % Note for chess nerds: The move is two steps and then one.  With no obstructions, it can be thought
        % of as one and then two, but with obstructions, this counts as a different move and is not allowed.
        % The number represents the cardinal direction of the move: 1=North, 2=East, 3=South, 4=West
        % The sign of the number represents whether the second step is left or right (positive is clockwise)
        % Therefore:
        %  Move -1       Move +1        Move -2      Move +2       Move -3       Move +3       Move -4       Move +4
        % . E x . .  |  . . x E .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .
        % . . x . .  |  . . x . .  |  . . . . E  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  E . . . .
        % . . S . .  |  . . S . .  |  . . S x x  |  . . S x x  |  . . S . .  |  . . S . .  |  x x S . .  |  x x S . .
        % . . . . .  |  . . . . .  |  . . . . .  |  . . . . E  |  . . x . .  |  . . x . .  |  E . . . .  |  . . . . .
        % . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . x E .  |  . E x . .  |  . . . . .  |  . . . . .
    case 'logging'
        out = false;
    otherwise
        error('dstauffman:knight:BadGlobal', 'Unexpected value to ask for: "%s".',value);
end