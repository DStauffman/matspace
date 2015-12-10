classdef test_board_to_costs < matlab.unittest.TestCase %#ok<*PROP>
    
    properties
        board,
        costs,
    end
    
    methods (TestMethodSetup) % also have TestMethodTeardown or only once use via TestClassSetup
        function initialize(self)
            char_board = ['. S E . W'; 'R B T L .'];
            self.board = char_board_to_nums(char_board);
            self.costs = [1 0 1 1 2; nan nan 1 5 1];
        end
    end
    
    methods (Test)
        function test_nominal(self)
            % normal usage with all possible costs
            costs = board_to_costs(self.board);
            self.verifyEqual(costs, self.costs)
        end
        function test_bad_board1(self)
            % Bad costs (current piece)
            self.board(1, 1) = PIECE_.current;
            self.verifyError(@() board_to_costs(self.board), 'knight:BadPiece');
        end
        function test_bad_board2(self)
            % Bad costs (visited piece)
            self.board(1, 1) = PIECE_.visited;
            self.verifyError(@() board_to_costs(self.board), 'knight:BadPiece');
        end
        function test_bad_board3(self)
            % Bad costs (undefined piece)
            self.board(1, 1) = 1000;
            self.verifyError(@() board_to_costs(self.board), 'MATLAB:class:InvalidEnum');
        end
    end
end