classdef test_undo_move < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        last_move,
        original_board,
        transports,
        start_pos,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board             = repmat(PIECE_.null, 2, 5);
            self.board(5)          = PIECE_.visited;
            self.last_move         = 2; % 2 right and 1 down
            self.original_board    = repmat(PIECE_.null, 2, 5);
            self.original_board(5) = PIECE_.start;
            self.transports        = get_transports(self.original_board);
            self.start_pos         = 10;
            self.board(self.start_pos) = PIECE_.current;
        end
    end
    
    methods (Test)
        function test_normal(self)
            % Normal
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(5), PIECE_.current);
            self.verifyEqual(self.board(10), self.original_board(10));
        end
        
        function test_other_piece(self)
            % Other piece to replace
            self.original_board(10) = PIECE_.water;
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(5), PIECE_.current);
            self.verifyEqual(self.board(10), self.original_board(10));
        end
        
        function test_transport1(self)
            % Transport
            self.board(1)   = PIECE_.transport;
            self.board(4)   = PIECE_.transport;
            self.transports = get_transports(self.board);
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(5), PIECE_.current);
            self.verifyEqual(self.board(10), self.original_board(10));
        end
        
        function test_transport2(self)
            % Transport
            self.board(1)   = PIECE_.transport;
            self.board(5)   = PIECE_.transport;
            self.transports = get_transports(self.board);
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(5), PIECE_.current);
            self.verifyEqual(self.board(10), self.original_board(10));
            self.verifyEqual(self.board(1), PIECE_.transport);
        end
        
        function test_transport3(self)
            % Transport
            self.board(5)   = PIECE_.transport;
            self.board(9)   = PIECE_.transport;
            self.transports = get_transports(self.board);
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(5), PIECE_.current);
            self.verifyEqual(self.board(10), self.original_board(10));
            self.verifyEqual(self.board(9), PIECE_.transport);
        end
        
        function test_transport4(self)
            % Transport
            self.last_move          = 4;
            self.board(1)           = PIECE_.transport;
            self.original_board(1)  = PIECE_.transport;
            self.original_board(10) = PIECE_.transport;
            self.transports         = [1 10];
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(6), PIECE_.current);
            self.verifyEqual(self.board(10), PIECE_.transport);
            self.verifyEqual(self.board(1), PIECE_.transport);
        end
        
        function test_transport5(self)
            % Transport
            self.last_move          = 4;
            self.board(1)           = PIECE_.transport;
            self.original_board(1)  = PIECE_.transport;
            self.original_board(10) = PIECE_.transport;
            self.transports         = [10 1]; % manually reverse their order
            self.board = undo_move(self.board, self.last_move, self.original_board, self.transports, self.start_pos);
            self.verifyEqual(self.board(6), PIECE_.current);
            self.verifyEqual(self.board(10), PIECE_.transport);
            self.verifyEqual(self.board(1), PIECE_.transport);
        end
    end
end