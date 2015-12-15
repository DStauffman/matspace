classdef test_char_board_to_nums < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        char_board,
        board,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.char_board  = ['. S E K W'; 'R B T L x'];
            self.board       = [0 1 2 3 4; 5 6 7 8 9];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal char board to nums with all values
            board = char_board_to_nums(self.char_board);
            self.verifyEqual(double(board), self.board);
        end
    end
end