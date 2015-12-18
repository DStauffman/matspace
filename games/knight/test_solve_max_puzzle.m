classdef test_solve_max_puzzle < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        moves,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board     = repmat(PIECE_.null, 3, 5);
            self.board(1)  = PIECE_.start;
            self.board(13) = PIECE_.final;
            self.moves     = [2, -2]; % TODO: should be 8 moves long?
        end
    end
    
    methods (Test)
        function test_max(self)
            % Max solver
            self.assumeTrue(false); % TODO: remove later when this is coded
            [output, moves] = evalc('solve_max_puzzle(self.board);');
            self.verifyEqual(moves, self.moves)
            expected_output_start = sprintf('%s\n','Initializing solver.','Solution found for cost of: 8.');
            self.verifyEqual(output(1:length(expected_output_start)), expected_output_start);
        end
        
        function test_no_solution(self)
            % Unsolvable
            self.assumeTrue(false); % TODO: remove later when this is coded
            board     = repmat(PIECE_.null, 2, 5);
            board(1)  = PIECE_.start;
            board(10) = PIECE_.final; %#ok<NASGU> - used in evalc command
            [output, moves] = evalc('solve_max_puzzle(board);');
            self.verifyTrue(isempty(moves));
            expected_output_start = sprintf('%s\n','Initializing solver.','No solution found.');
            self.verifyEqual(output(1:length(expected_output_start)), expected_output_start);
        end
    end
end