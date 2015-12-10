classdef test_print_sequence < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        moves,
        output,
        output2,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board     = repmat(PIECE_.null, 3, 5);
            self.board(1)  = PIECE_.start;
            self.board(15) = PIECE_.final;
            self.moves     = [2, 2];
            self.output    = sprintf('%s\n','Starting position:','S . . . .','. . . . .','. . . . E','', ...
                'After move 1, cost: 1','x . . . .','. . K . .','. . . . E','','After move 2, cost: 2', ...
                'x . . . .','. . x . .','. . . . K');
            self.output2   = sprintf('%s\n','Starting position:','S W W W W','W W W W W','W W W W E','', ...
                'After move 1, cost: 2','x W W W W','W W K W W','W W W W E','','After move 2, cost: 3', ...
                'x W W W W','W W x W W','W W W W K');
        end
    end
    
    methods (Test)
        function test_normal(self)
            % Normal
            output = evalc('print_sequence(self.board, self.moves);');
            self.verifyEqual(output, self.output);
        end
        
        function test_other_costs(self)
            % Non standard costs
            self.board(self.board == PIECE_.null) = PIECE_.water;
            output = evalc('print_sequence(self.board, self.moves);');
            self.verifyEqual(output, self.output2);
        end
        
        function test_invalid_sequence(self)
            % Invalid sequence
            self.moves = [-2, -2];
            output = evalc('self.verifyError(@() print_sequence(self.board, self.moves), ''knight:BadSequence'');');
            self.verifyEqual(output, self.output(1:length(output)));
        end
    end
end