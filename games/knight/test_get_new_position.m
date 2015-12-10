classdef test_get_new_position < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        pos,
        board,
        board_size,
        transports,
        valid_moves,
        future_moves,
        bad_moves,
        results,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            %  Move -1       Move +1        Move -2      Move +2       Move -3       Move +3       Move -4       Move +4
            % . E x . .  |  . . x E .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .
            % . . x . .  |  . . x . .  |  . . . . E  |  . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  E . . . .
            % . . S . .  |  . . S . .  |  . . S x x  |  . . S x x  |  . . S . .  |  . . S . .  |  x x S . .  |  x x S . .
            % . . . . .  |  . . . . .  |  . . . . .  |  . . . . E  |  . . x . .  |  . . x . .  |  E . . . .  |  . . . . .
            % . . . . .  |  . . . . .  |  . . . . .  |  . . . . .  |  . . x E .  |  . E x . .  |  . . . . .  |  . . . . .
            self.pos          = 13;
            self.board        = zeros(5, 5);
            self.board(self.pos) = PIECE_.start;
            self.board_size   = size(self.board);
            self.transports   = get_transports(self.board);
            self.valid_moves  = [-4 -3 -2 -1 1 2 3 4];
            self.future_moves = [-8 -7 -6 -5 5 6 7 8];
            self.bad_moves    = [0 9 -9 100];
            self.results      = [4, 20, 22, 6, 16, 24, 10, 2];
        end
    end
    
    methods (Test)
        function test_valid_moves(self)
            % All valid moves
            for i = 1:length(self.valid_moves)
                this_move   = self.valid_moves(i);
                this_result = self.results(i);
                all_pos = get_new_position(self.board_size, self.pos, this_move, self.transports);
                self.verifyEqual(all_pos(3), this_result);
                % TODO: assert something about all_pos(1) and all_pos(2)?
            end
        end
        
        function test_future_moves(self)
            % Not yet done moves
            for i = 1:length(self.future_moves)
                this_move    = self.future_moves(i);
                self.verifyError(@() get_new_position(self.board_size, self.pos, this_move, self.transports), 'knight:BadExtendedMoves');
            end
        end
        
        function test_bad_moves(self)
            % Invalid moves
            for this_move=self.bad_moves
                self.verifyError(@() get_new_position(self.board_size, self.pos, this_move, self.transports), 'knight:InvalidMoveValue');
            end
        end
        
        function test_transport(self)
            % Transport move
            self.board(24)  = PIECE_.transport;
            self.board(20)  = PIECE_.transport;
            self.transports = get_transports(self.board);
            for i = 1:length(self.valid_moves)
                this_move = self.valid_moves(i);
                this_result = self.results(i);
                all_pos = get_new_position(self.board_size, self.pos, this_move, self.transports);
                if ismember(all_pos(3), self.transports)
                    % flip coordinates
                    [x, y] = ind2sub(size(self.board), this_result);
                    ix = sub2ind(size(self.board), y, x);
                    self.verifyEqual(all_pos(3), ix);
                else
                    self.verifyEqual(all_pos(3), this_result)
                end
            end
        end
        function test_bad_transports(self)
            % Bad number of transports
            transports = 1;
            self.verifyError(@() get_new_position(self.board_size, self.pos, self.valid_moves(1), transports), 'knight:NumTransports');
            transports = [1 2 3];
            self.verifyError(@() get_new_position(self.board_size, self.pos, self.valid_moves(1), transports), 'knight:NumTransports');
        end
    end
end