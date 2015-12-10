classdef test_get_move_inverse < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        moves,
        inv_moves,
        bad_moves,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.moves     = [-4, -3, -2, -1, 1, 2, 3, 4];
            self.inv_moves = [-2, -1, -4, -3, 3, 4, 1, 2];
            self.bad_moves = [1000, -2000];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % All inverses
            for i = 1:length(self.moves)
                this_move = self.moves(i);
                this_inv_move = self.inv_moves(i);
                inv_move = get_move_inverse(this_move);
                self.verifyEqual(inv_move, this_inv_move);
            end
        end
        
        function test_bad_moves(self)
            % Bad moves
            for this_move=self.bad_moves
                self.verifyError(@() get_move_inverse(this_move), 'knight:InvalidInvMove');
            end
        end
    end
end