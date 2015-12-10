classdef test_solve_next_move < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        data,
        start_pos,
        best_costs,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board     = repmat(PIECE_.null, 2,5);
            self.board(1)  = PIECE_.start;
            self.board(9)  = PIECE_.final;
            self.data      = initialize_data(self.board);
            self.start_pos = 1;
            self.board(self.start_pos) = PIECE_.current;
            self.best_costs = [0 nan nan nan nan; nan nan 1 nan nan];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal
            data = solve_next_move(self.board, self.data, self.start_pos);
            self.verifyEqual(data.best_costs, self.best_costs);
        end
    end
end