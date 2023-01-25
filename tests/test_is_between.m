classdef test_is_between < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the is_between function with the following cases:
    %     Default behavior
    %     four arguments
    %     matrix scalar scalar
    %     matrix matrix scalar
    %     matrix scalar matrix
    %     scalar closed bounds
    %     bad number arguments (should error)
    %     bad boundaries (should error)
    %     datetimes

    methods (Test)
        function test_default(self)
            self.verifyTrue(matspace.utils.is_between(5,4,6));
            self.verifyFalse(matspace.utils.is_between(5,5,6));
            self.verifyFalse(matspace.utils.is_between(5,4,5));
        end

        function test_four_args(self)
            % All four combinations specified explicitly:
            % (a,b)  (a,b] [a,b) [a,b]
            a = 0;
            b = 10;

            self.verifyTrue(matspace.utils.is_between(0,a,b,[1 0]));
            self.verifyTrue(matspace.utils.is_between(0,a,b,[1 1]));
            self.verifyFalse(matspace.utils.is_between(0,a,b,[0 0]));
            self.verifyFalse(matspace.utils.is_between(0,a,b,[0 1]));

            self.verifyFalse(matspace.utils.is_between(10,a,b,[1 0]));
            self.verifyTrue(matspace.utils.is_between(10,a,b,[1 1]));
            self.verifyFalse(matspace.utils.is_between(10,a,b,[0 0]));
            self.verifyTrue(matspace.utils.is_between(10,a,b,[0 1]));
        end

        function test_matrix_scalar_scalar(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([0 0 1; 0 1 0; 1 0 0]);
            self.verifyEqual(matspace.utils.is_between(c,3,7),expectedResult);
        end

        function test_matrix_matrix_scalar(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([1 0 1; 1 1 1; 1 0 0]);
            self.verifyEqual(matspace.utils.is_between(c,3+eye(3),8,[1 1]),expectedResult);
        end

        function test_matrix_scalar_matrix(self)
            %      8     1     6
            %      3     5     7
            %      4     9     2
            c = magic(3);
            expectedResult = logical([0 0 1; 1 1 1; 1 0 0]);
            self.verifyEqual(matspace.utils.is_between(c,2,6+eye,[0 1]),expectedResult);
        end

        function test_scalar_closed_bound(self)
            self.verifyTrue(matspace.utils.is_between(6,5,6,1));
            self.verifyFalse(matspace.utils.is_between(6,5,6,0));
        end

        function test_bad_arg_list(self)
            self.verifyError(@() matspace.utils.is_between(1,2), 'matspace:UnexpectedNargin');
        end

        function test_bad_boundaries(self)
            self.verifyError(@() matspace.utils.is_between(1,2,3,[1 1 1]),'matspace:is_between:BadBoundarySpecification');
        end

        function test_datetimes(self)
            date_zero = datetime('now');
            value = date_zero + duration(0, 0, 1) * (0:10);
            lower = date_zero + duration(0, 0, 2);
            upper = date_zero + duration(0, 0, 8);
            out = matspace.utils.is_between(value, lower, upper, true);
            exp = true(size(value));
            exp([1 2 10 11]) = false;
            self.verifyEqual(out, exp);
            out2 = matspace.utils.is_between(value, lower, upper, false);
            exp2 = exp;
            exp2([3 9]) = false;
            self.verifyEqual(out2, exp2);
        end
    end
end