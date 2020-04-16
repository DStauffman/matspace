classdef test_maxmax < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the maxmax function with the following cases:
    % (1) 1 Argument
    %    (a) 10 x 1
    %    (b) 1 x 9
    %    (c) 3 x 4
    %    (d) 3 x 4 x 6
    %    (e) 3 x 4 x 2 x 5
    % (2) dim specified
    %    (a) 10 x 1, 1
    %    (b) 10 x 1, 2
    %    (c) 3 x 4, 1
    %    (d) 3 x 4, 2
    %    (e) 3 x 1 x 6, [1 2]
    %    (f) 3 x 1 x 6, [2 3]
    %    (g) 3 x 4 x 2 x 5, (2:4)

    methods (Test)
        function test_1a(self)
            % Case 1a
            x = randn(10,1);
            self.verifyEqual(matspace.utils.maxmax(x), max(x))
        end

        function test_1b(self)
            % Case 1b
            x = randn(1,9);
            self.verifyEqual(matspace.utils.maxmax(x), max(x))
        end

        function test_1c(self)
            % Case 1c
            x = randn(3,4);
            self.verifyEqual(matspace.utils.maxmax(x), max(max(x)))
        end

        function test_1d(self)
            % Case 1d
            x = randn(3,4,6);
            self.verifyEqual(matspace.utils.maxmax(x), max(max(max(x))))
        end

        function test_1e(self)
            % Case 1e
            x = randn(3,4,2,5);
            self.verifyEqual(matspace.utils.maxmax(x), max(max(max(max(x)))))
        end

        function test_2a(self)
            % Case 2a
            x = randn(10,1);
            self.verifyEqual(matspace.utils.maxmax(x, 1), max(x))
        end

        function test_2b(self)
            % Case 2b
            x = randn(10,1);
            self.verifyEqual(matspace.utils.maxmax(x, 2), x)
        end

        function test_2c(self)
            % Case 2c
            x = randn(3,4);
            self.verifyEqual(matspace.utils.maxmax(x, 1), max(x, [], 1))
        end

        function test_2d(self)
            % Case 2d
            x = randn(3,4);
            self.verifyEqual(matspace.utils.maxmax(x, 2), max(x, [] ,2))
        end

        function test_2e(self)
            % Case 2e
            x = randn(3,1,6);
            self.verifyEqual(matspace.utils.maxmax(x, [1 2]), max(max(x,[],1),[],2))
        end

        function test_2f(self)
            % Case 2f
            x = randn(3,1,6);
            self.verifyEqual(matspace.utils.maxmax(x, [2 3]), max(max(x,[],2),[],3))
        end

        function test_2g(self)
            % Case 2g
            x = randn(3,4,2,5);
            self.verifyEqual(matspace.utils.maxmax(x, 2:4), max(max(max(x,[],2),[],3),[],4))
        end
    end
end