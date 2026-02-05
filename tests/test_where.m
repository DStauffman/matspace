classdef test_where < matlab.unittest.TestCase

    % Tests the where function with the following cases:
    %     True
    %     False
    %     Vector option
    %     Bad Sizes

    methods (Test)
        function test_true(self)
            out = matspace.utils.where(true, 3, 5);
            self.verifyEqual(out, 3);
        end

        function test_false(self)
            out = matspace.utils.where(false, 3, 5);
            self.verifyEqual(out, 5);
        end

        function test_nonscalar(self)
            bool = [true false false true];
            a    = [1 3 5 7];
            b    = [-2 -4 -6 -8];
            out  = matspace.utils.where(bool, a, b);
            expected = [1 -4 -6 7];
            self.verifyEqual(out, expected);
        end

        function test_scalar_values(self)
            bool = [true false false true];
            a    = 5;
            b    = -3;
            out  = matspace.utils.where(bool, a, b);
            expected = [5 -3 -3 5];
            self.verifyEqual(out, expected);
        end

        function test_a_scalar(self)
            bool = [true false false true];
            a    = 5;
            b    = [-3 -2 -1 0];
            out  = matspace.utils.where(bool, a, b);
            expected = [5 -2 -1 5];
            self.verifyEqual(out, expected);
        end

        function test_b_scalar(self)
            bool = [true false false true];
            a    = [5 6 7 8];
            b    = -3;
            out  = matspace.utils.where(bool, a, b);
            expected = [5 -3 -3 8];
            self.verifyEqual(out, expected);
        end

        function test_bad_sizes(self)
            self.verifyError(@() matspace.utils.where([true false], [1, 2, 100], [3, 4]), '');
        end

        function test_bad_chars(self)
            self.verifyError(@() matspace.utils.where(true, 'text', 'some other text'), '');
        end
    end
end