classdef test_fix_rollover < matlab.unittest.TestCase %#ok<*PROP>

% Tests the fix_rollover function with the following cases:
%     Nominal
%     Matrix dim 1
%     Matrix dim 2
%     Log level 1
%     Optional inputs

    properties
        data,
        data2,
        exp,
        roll,
        log_level,
        dim,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.data  = [1 2 3 4 5 6 0 1  3  6  0  6  5 2];
            self.data2 = [];
            self.exp   = [1 2 3 4 5 6 7 8 10 13 14 13 12 9];
            self.roll  = 7;
            self.log_level = 10;
            self.dim   = [];
        end
    end

    methods (Test)
        function test_nominal(self)
            out = verifyWarning(self, @() matspace.utils.fix_rollover(self.data, self.roll, self.log_level), 'matspace:rollover');
            self.verifyEqual(out, self.exp);
        end

        function test_matrix_dim1(self)
            dim  = 1;
            data = [self.data; self.data];
            exp  = [self.data; self.data];
            out  = matspace.utils.fix_rollover(data, self.roll, self.log_level, dim);
            self.verifyEqual(out, exp);
        end

        function test_matrix_dim2(self)
            self.dim   = 2;
            self.data2 = [self.data; self.data];
            exp        = [self.exp; self.exp];
            out        = verifyWarning(self, @() matspace.utils.fix_rollover(self.data2, self.roll, self.log_level, self.dim), 'matspace:rollover');
            self.verifyEqual(out, exp);
        end

        function test_log_level(self)
            self.log_level = 1;
            out = matspace.utils.fix_rollover(self.data, self.roll, self.log_level);
            self.verifyEqual(out, self.exp);
        end

        function test_optional_inputs(self)
            import matlab.unittest.fixtures.SuppressedWarningsFixture
            self.applyFixture(SuppressedWarningsFixture('matspace:rollover'));
            out = matspace.utils.fix_rollover(self.data, self.roll);
            % out = verifyWarning(self, @() matspace.utils.fix_rollover(self.data, self.roll), 'matspace:rollover');
            self.verifyEqual(out, self.exp);
        end

        function test_non_integer_roll(self)
            exp  = 0:0.1:10;
            roll = 3.35;
            data = roll * mod(exp / roll, 1);
            out  = matspace.utils.fix_rollover(data, roll, 1);
            self.verifyEqual(out, exp, 'AbsTol', 1e-14);
        end

        function test_signed_rollover(self)
            exp  = 0:20;
            data = [0 1 2 3 -4 -3 -2 -1 0 1 2 3 -4 -3 -2 -1 0 1 2 3 -4];
            roll = 8;
            out  = matspace.utils.fix_rollover(data, roll, 1);
            self.verifyEqual(out, exp);
        end
    end
end