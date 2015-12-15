classdef test_sort_best_moves < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        moves,
        costs,
        transports,
        start_pos,
        sorted_moves,
        board_size,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            board             = repmat(PIECE_.null, 5, 8);
            board(13)         = PIECE_.current;
            board(40)         = PIECE_.final;
            self.moves        = get_globals('moves');
            self.costs        = predict_cost(board);
            self.transports   = zeros(1, 0);
            self.start_pos    = 13;
            self.board_size   = size(board);
            self.sorted_moves = [2 -3 -2 3 -4 4 -1 1];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal
            sorted_moves = sort_best_moves(self.moves, self.costs, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(sorted_moves, self.sorted_moves);
        end
        
        function test_small_board(self)
            % Small board
            board             = zeros(2, 5);
            board(1)          = PIECE_.current;
            board(9)          = PIECE_.final;
            self.costs        = predict_cost(board);
            self.start_pos    = 1;
            self.board_size   = size(board);
            self.sorted_moves = 2;
            sorted_moves      = sort_best_moves(self.moves, self.costs, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(sorted_moves, self.sorted_moves);
        end
    end
end