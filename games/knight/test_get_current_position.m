classdef test_get_current_position < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        pos,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board = repmat(PIECE_.null, 2, 5);
            self.pos = 5;
            self.board(self.pos) = PIECE_.current;
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % Nominal
            pos = get_current_position(self.board);
            self.verifyEqual(pos, self.pos);
        end
        
        function test_no_current(self)
            % No current piece
            self.board(self.pos) = PIECE_.start;
            output = evalc('self.verifyError(@() get_current_position(self.board), ''knight:NoCurrent'');');
            self.verifyEqual(output,sprintf('%s\n','. . S . .','. . . . .'));
        end
        
        function test_multiple_currents(self)
            % Multiple current pieces
            self.board(self.pos + 1) = PIECE_.current;
            output = evalc('self.verifyError(@() get_current_position(self.board), ''knight:TooManyCurrent'');');
            self.verifyEqual(output,sprintf('%s\n','. . K . .','. . K . .'));
        end
    end
end