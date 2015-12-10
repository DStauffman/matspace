function [data] = solve_next_move(board, data, start_pos)

% SOLVE_NEXT_MOVE  solves the puzzle using a breadth first approach.
% 
% Input:
%     board ... : (MxN) board layout
%     data .... : (struct) Internal data structure for storing information throughout solver calls, see initialize_data
%     start_pos : (scalar) starting linearized location
% 
% Output:
%     data .... : (struct) Internal data structure with the following fields updated:
%         .TBD...
% 
% Prototype:
%     board     = repmat(PIECE_.null, 2,5);
%     board(1)  = PIECE_.start;
%     board(9)  = PIECE_.final;
%     data      = initialize_data(board);
%     start_pos = 1;
%     board(start_pos) = PIECE_.current;
%     data = solve_next_move(board, data, start_pos);
%     assert(all(all(isequaln(data.best_costs, [0 nan nan nan nan; nan nan 1 nan nan]))));
% 
% Change Log:
%     1.  Written by David C. Stauffer in December 2015.

% get globals
moves = get_globals('moves');
logging = get_globals('logging');

% check for a start piece, in which case something is messed up
assert(~any(any(board == PIECE_.start)), 'Empty dicts should not have a start piece and vice versa.');
% guess the order for the best moves based on predicited costs
sorted_moves = sort_best_moves(board, moves, data.pred_costs, data.transports, start_pos);
% try all the next possible moves
for this_move = sorted_moves
    % make the move
    [board, cost, is_repeat, new_pos] = update_board(board, this_move, data.costs, ...
        data.transports, start_pos);
    % optional logging for debugging
    if logging
        fprintf('this_move = %i, this_cost = %g, total moves = %i', this_move, cost, data.moves);
    end
    % if the move was invalid then go to the next one
    if isnan(cost);
        if logging
            disp(' - invalid');
        end
        continue
    end
    % valid move
    % determine if move was to a previously visited square of worse cost than another sequence
    if is_repeat || data.current_cost + abs(cost) >= data.best_costs(new_pos)
        if logging
            disp(' - worse repeat');
        end
        % reject move and re-establish the visited state
        board = undo_move(board, this_move, data.original_board, data.transports, new_pos);
        if cost > 0 && is_repeat
            board(new_pos) = PIECE_.visited;
        end
        continue
    end
    % optional logging for debugging
    if logging
        if cost < 0
            disp(' - solution');
            disp(['Potential solution found, moves = ',mat2str(data.moves),' + ',num2str(this_move)]);
        elseif is_repeat
            disp(' - better repeat');
        else
            disp(' - new step');
        end
    end
    % move is new or better, update current and best costs and append move
    assert(isnan(data.best_costs(new_pos)));
    data.best_costs(new_pos) = data.current_cost + cost;
    data.all_moves{new_pos} = [data.moves, this_move];
    data.all_boards(:, :, new_pos) = board;
    if cost < 0
        disp(['Solution found for cost of: ',int2str(data.current_cost + abs(cost)),'.']);
        data.is_solved = true;
        board = undo_move(board, this_move, data.original_board, data.transports, new_pos);
    else
        % undo board as prep for next move
        board = undo_move(board, this_move, data.original_board, data.transports, new_pos);
    end
end