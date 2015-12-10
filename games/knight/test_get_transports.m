classdef test_get_transports < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        transports,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board = repmat(PIECE_.null, 3, 3);
            self.transports = [4, 9];
        end
    end
    
    methods (Test)
        function test_valid_transports(self)
            % Valid transports
            self.board(4) = PIECE_.transport;
            self.board(9) = PIECE_.transport;
            transports = get_transports(self.board);
            self.verifyEqual(transports, self.transports)
        end
        function test_no_transports(self)
            % No transports
            transports = get_transports(self.board);
            self.verifyEqual(transports, []);
        end
        
        function test_invalid_transports(self)
            % Invalid transports
            self.board(4) = PIECE_.transport;
            self.verifyError(@() get_transports(self.board), 'knight:BadTransports');
        end
    end
end