classdef test_sort_best_moves < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        moves,
        costs,
        transports,
        start_pos,
        sorted_moves,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board        = repmat(PIECE_.null, 5, 8);
            self.board(13)    = PIECE_.current;
            self.board(40)    = PIECE_.final;
            self.moves        = get_globals('moves');
            self.costs        = predict_cost(self.board);
            self.transports   = [];
            self.start_pos    = 13;
            self.sorted_moves = [2 -3 -2 3 -4 4 -1 1];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal
            sorted_moves = sort_best_moves(self.board, self.moves, self.costs, self.transports, self.start_pos);
            self.verifyEqual(sorted_moves, self.sorted_moves);
        end
        
        function test_small_board(self)
            % Small board
            self.board        = zeros(2, 5);
            self.board(1)     = PIECE_.current;
            self.board(9)     = PIECE_.final;
            self.costs        = predict_cost(self.board);
            self.start_pos    = 1;
            self.sorted_moves = 2;
            sorted_moves = sort_best_moves(self.board, self.moves, self.costs, self.transports, self.start_pos);
            self.verifyEqual(sorted_moves, self.sorted_moves);
        end
    end
end