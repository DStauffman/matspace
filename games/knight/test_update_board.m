classdef test_update_board < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        old_pos,
        move,
        new_pos,
        board,
        cost,
        costs,
        transports,
        board_size,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.old_pos    = 5;
            self.move       = 2; % 2 right and 1 down
            self.new_pos    = 10;
            self.board      = repmat(PIECE_.null, 2, 5);
            self.board(self.old_pos) = PIECE_.current;
            self.board_size = size(self.board);
            self.cost       = 5;
            self.costs      = self.cost * ones(size(self.board));
            self.transports = get_transports(self.board);
        end
    end
    
    methods (Test)
        
        function test_normal(self)
            % Normal move
            [self.board, cost, is_repeat, new_pos] = update_board(self.board, self.move, self.costs, ...
                self.transports, self.old_pos, self.board_size);
            self.verifyEqual(cost, self.costs(self.new_pos));
            self.verifyFalse(is_repeat);
            self.verifyEqual(new_pos, self.new_pos);
            self.verifyEqual(self.board(self.old_pos), PIECE_.visited);
            self.verifyEqual(self.board(self.new_pos), PIECE_.current);
        end
        
        function test_invalid_move(self)
            % Invalid move
            [self.board, cost, is_repeat, new_pos] = update_board(self.board, -2, self.costs, ...
                self.transports, self.old_pos, self.board_size);
            self.verifyTrue(isnan(cost));
            self.verifyFalse(is_repeat);
            self.verifyEqual(new_pos, self.old_pos);
            self.verifyEqual(self.board(self.old_pos), PIECE_.current);
            self.verifyEqual(self.board(self.new_pos), PIECE_.null);
        end
        
        function test_repeated_move(self)
            % Repeated move
            self.board(self.new_pos) = PIECE_.visited;
            [self.board, cost, is_repeat, new_pos] = update_board(self.board, self.move, self.costs, ...
                self.transports, self.old_pos, self.board_size);
            self.verifyEqual(cost, self.cost);
            self.verifyTrue(is_repeat);
            self.verifyEqual(new_pos, self.new_pos);
            self.verifyEqual(self.board(self.old_pos), PIECE_.visited);
            self.verifyEqual(self.board(self.new_pos), PIECE_.current);
        end
    end
end