classdef test_print_board < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board1,
        board2,
        board3,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board1 = ones(4, 4);
            self.board2 = zeros(3, 5);
            self.board3 = reshape(0:11, 3, 4)';
            self.board3(self.board3 > 9) = 0;
        end
    end
    
    methods (Test)
        function test_square_board(self)
            % Square board
            output = evalc('print_board(self.board1);');
            self.verifyEqual(output, sprintf('%s\n','S S S S','S S S S','S S S S','S S S S'));
        end
        
        function test_rect_board(self)
            % Rectangular board
            output = evalc('print_board(self.board2);');
            self.verifyEqual(output, sprintf('%s\n','. . . . .','. . . . .','. . . . .'));
        end
        
        function test_all_board_piece_types(self)
            % All piece types on the board
            output = evalc('print_board(self.board3);');
            self.verifyEqual(output, sprintf('%s\n','. S E','K W R','B T L','x . .'));
        end
    end
end