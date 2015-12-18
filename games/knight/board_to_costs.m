function [costs] = board_to_costs(board)

% BOARD_TO_COSTS  translates a board to the associated costs for landing on any square within the board.
% 
% Input:
%     board : (MxN) board layout
% 
% Output:
%     costs : (MxN) costs for each square on the board layout
% 
% Prototype:
%     board = repmat(PIECE_.null, 3, 3);
%     board(1, 1) = PIECE_.water;
%     board(2, 2) = PIECE_.start;
%     board(3, 3) = PIECE_.barrier;
%     costs = board_to_costs(board);
%     assert(all(all(isequaln(costs,[2 1 1; 1 0 1; 1 1 nan]))));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% get the costs data
cost_data = get_globals('costs');

% initialize output
costs = nan(size(board));

% costs(board == PIECE_.rock | board == PIECE_.barrier) = cost_data.invalid; % implied by preallocation
costs(board == PIECE_.null | board == PIECE_.final) = cost_data.normal;
costs(board == PIECE_.start)     = cost_data.start;
costs(board == PIECE_.transport) = cost_data.transport;
costs(board == PIECE_.water)     = cost_data.water;
costs(board == PIECE_.lava)      = cost_data.lava;

% test for unexpected pieces
if any(any(not(ismember(board, [PIECE_.null, PIECE_.start, PIECE_.final, PIECE_.water, PIECE_.rock, ...
        PIECE_.barrier, PIECE_.transport, PIECE_.lava]))));
    error('knight:BadPiece', 'Unexpected pieces on the board.');
end