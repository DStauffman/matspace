classdef test_check_valid_sequence < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        moves,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board     = repmat(PIECE_.null, 3, 5);
            self.board(1)  = PIECE_.start;
            self.board(15) = PIECE_.final;
            self.moves     = [2, 2];
        end
    end
    
    methods (Test)
        function test_normal(self)
            % Normal, no printing
            is_valid = check_valid_sequence(self.board, self.moves, false);
            self.verifyTrue(is_valid);
        end
        
        function test_printing(self)
            % Normal, with printing
            [output, is_valid] = evalc('check_valid_sequence(self.board, self.moves, true);');
            self.verifyTrue(is_valid);
            self.verifyEqual(output, sprintf('%s\n','Sequence is valid and finished the puzzle.'));
        end
        
        function test_no_final(self)
            % No final position on board
            self.board(15) = PIECE_.water;
            self.verifyError(@() check_valid_sequence(self.board, self.moves, false), 'knight:FinalPos');
        end
        
        function test_bad_sequence(self)
            % Invalid sequence
            [output, is_valid] = evalc('check_valid_sequence(self.board, [-2, -2], true);');
            self.verifyFalse(is_valid);
            self.verifyEqual(output, sprintf('%s\n','Sequence is not valid.'));
        end
        
        function test_repeated_sequence1(self)
            % Repeated square sequence
            is_valid = check_valid_sequence(self.board, [2, 4, 2, 2]);
            self.verifyFalse(is_valid);
        end
        
        function test_repeated_sequence2(self)
            % Repeated square sequence
            [output, is_valid] = evalc('check_valid_sequence(self.board, [2, 4, 2, 2], true);');
            self.verifyFalse(is_valid);
            self.verifyEqual(output, sprintf('%s\n','No repeats allowed.','Sequence is not valid.'));
        end
        
        function test_repeated_sequence3(self)
            % Repeated square sequence
            is_valid = check_valid_sequence(self.board, [2, 4, 2, 2], false, true);
            self.verifyTrue(is_valid)
        end
        
        function test_good_but_incomplete_sequence(self)
            % Good, but incomplete sequence
            [output, is_valid] = evalc('check_valid_sequence(self.board, self.moves(1:end-1), true);');
            self.verifyTrue(is_valid);
            self.verifyEqual(output, sprintf('%s\n','Sequence is valid, but did not finish the puzzle.'));
        end
        
        function test_good_but_extra_sequence(self)
            % Good, but extra moves in sequence
            self.moves = [self.moves, 2];
            self.verifyError(@() check_valid_sequence(self.board, self.moves, false), 'knight:FinishedPlus');
        end
    end
end