classdef test_initialize_data < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        fields,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board    = repmat(PIECE_.null, 2, 5);
            self.board(1) = PIECE_.start;
            self.board(9) = PIECE_.final;
            self.fields   = {'all_boards'; 'all_moves'; 'best_costs'; ...
                'best_moves'; 'board_size'; 'costs'; 'current_cost'; 'final_pos'; 'is_solved'; ...
                'original_board'; 'pred_costs'; 'transports'};
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal
            data = initialize_data(self.board);
            self.verifyEqual(sort(fieldnames(data)), self.fields);
        end
    end
end