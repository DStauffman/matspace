classdef test_classify_move < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        move,
        move_type,
        transports,
        start_pos,
        board_size,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.board      = repmat(PIECE_.null, 2, 5);
            self.move       = 2; % (2 right and 1 down, so end at 10
            self.move_type  = MOVE_.normal;
            self.transports = get_transports(self.board);
            self.start_pos  = 5;
            self.board(self.start_pos) = PIECE_.current;
            self.board_size = size(self.board);
        end
    end
    
    methods (Test)
        function test_normal(self)
            % Normal
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, self.move_type);
        end
        
        function test_off_board(self)
            % Off board
            move_type = classify_move(self.board, -2, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.off_board);
        end
        
        function test_land_on_barrier_or_rock(self)
            % Land on barrier or rock
            self.board(10) = PIECE_.rock;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.blocked);
            self.board(10) = PIECE_.barrier;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.blocked);
        end
        
        function test_cant_pass_barrier(self)
            % Try to jump barrier
            self.board(9) = PIECE_.barrier;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.blocked);
        end
        
        function test_over_rock(self)
            % Land on rock
            self.board(9) = PIECE_.rock;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, self.move_type);
        end
        
        function test_visited(self)
            % Visited
            self.board(10) = PIECE_.visited;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.visited);
        end
        
        function test_winning(self)
            % Winning
            self.board(10) = PIECE_.final;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.winning);
        end
        
        function test_transport(self)
            % Transport
            self.board(10) = PIECE_.transport;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.transport);
        end
        
        function test_water(self)
            % Water
            self.board(10) = PIECE_.water;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.water);
        end
        
        function test_lava(self)
            % Lava
            self.board(10) = PIECE_.lava;
            move_type = classify_move(self.board, self.move, self.transports, self.start_pos, self.board_size);
            self.verifyEqual(move_type, MOVE_.lava);
        end
        
        function test_unexpected_piece(self)
            % nop
        end
    end
end