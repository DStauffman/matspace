classdef test_predict_cost < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        costs,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board    = zeros(2, 5);
            self.board(1) = PIECE_.start;
            self.board(9) = PIECE_.final;
            self.costs    = [2 1.5 1 0.5 0; 2 1.5 1 1 0.5];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            costs = predict_cost(self.board);
            self.verifyEqual(costs, self.costs);
        end
    end
end