classdef test_intersect2 < matlab.unittest.TestCase %#ok<*PROP>

% Tests the fix_rollover function with the following cases:
%     Nominal
%     Floats (x3)
%     Unique
%     No index outputs
%     Tolerance
%     Tolerance without index outputs
%     Integers as double and as ints
%     Ints with Even tolerance
%     Ints with Odd tolerance
%     Large ints with tolerances (x3)
%     Rows (x2)
%     Rows & Order
%     Stable

    methods (Test)
        function test_nominal(self)
            a = [1 2 4 4 6];
            b = [0 8 2 2 5 8 6 8 8];
            [c, ia, ib] = matspace.stats.intersect2(a, b);
            self.verifyEqual(c, [2 6]);
            self.verifyEqual(ia, [2; 5]);
            self.verifyEqual(ib, [3; 7]);
        end

        function test_floats(self)
            a = [1 2.5 4 6];
            b = [0 8 2.5 4 6];
            [c, ia, ib] = matspace.stats.intersect2(a, b);
            self.verifyEqual(c, [2.5 4 6]);
            self.verifyEqual(ia, [2; 3; 4])
            self.verifyEqual(ib, [3; 4; 5])
        end

        function test_floats2(self)
            a           = [1 2 3 3 5 6];
            b           = [3.0000000001 4.9999999999];
            precision   = 1e-6;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, [3, 5]);
            self.verifyEqual(ia, [3; 5]);
            self.verifyEqual(ib, [1; 2]);
        end

        function test_floats3(self)
            a           = [1.000001; 1.99999975];
            b           = [1.0000015; 2.00000025];
            precision   = 1e-6;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, a);
            self.verifyEqual(ia, [1; 2]);
            self.verifyEqual(ib, [1; 2]);
        end

        function test_unique(self)
            a = [1 2.5 4 6];
            b = [0 8 2.5 4 6];
            [c, ia, ib] = matspace.stats.intersect2(a, b);
            self.verifyEqual(c, [2.5 4 6]);
            self.verifyEqual(ia, [2; 3; 4]);
            self.verifyEqual(ib, [3; 4; 5]);
            precision = 1e-7;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, [2.5 4 6]);
            self.verifyEqual(ia, [2; 3; 4]);
            self.verifyEqual(ib, [3; 4; 5]);
        end

        function test_no_indices(self)
            a = [1 2 4 4 6];
            b = [0 8 2 2 5 8 6 8 8];
            c = matspace.stats.intersect2(a, b);
            self.verifyEqual(c, [2 6]);
        end

        function test_tolerance(self)
            a = [1 2 3.1 3.9 4 6];
            b = [2 3 4 5];
            precision = 0.12;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, [2 3.1 3.9 4]);
            self.verifyEqual(ia, [2; 3; 4; 5]);
            self.verifyEqual(ib, [1; 2; 3]);
        end
        
        function test_tolerance_no_ix(self)
            a = [1 3 5 7 9];
            b = [1.01 2.02 3.03 4.04 5.05 6.06 7.07 8.08 9.09];
            precision = 0.055;
            c = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, [1, 3, 5]);
            c2 = matspace.stats.intersect2(b, a, precision);
            self.verifyEqual(c2, [1.01 3.03 5.05]);
        end

        function test_int(self)
            % first test as doubles that are ints
            a = [0 4 10 20 30 -40 30];
            b = [1 5 7 31 -10 -40];
            precision = 0;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, -40);
            self.verifyEqual(ia, 6);
            self.verifyEqual(ib, 6);
            % then test with actual int types
            [c, ia, ib] = matspace.stats.intersect2(int32(a), int32(b), int32(0));
            self.verifyEqual(c, int32(-40));
            self.verifyEqual(ia, 6);
            self.verifyEqual(ib, 6);
        end

        function test_int_even_tol(self)
            a = int32([0 4 10 20 30 -40 30]);
            b = int32([1 5 7 31 -10 -40]);
            precision = int32(2);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, int32([-40 0 4 30]));
            self.verifyEqual(ia, [6; 1; 2; 5]);
            self.verifyEqual(ib, [6; 1; 2; 4]);
        end

        function test_int_odd_tol(self)
            a = int32([0 4 10 20 30 -40 30]);
            b = int32([1 5 7 31 -10 -40]);
            precision = int32(3);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, int32([-40 0 4 10 30]));
            self.verifyEqual(ia, [6; 1; 2; 3; 5]);
            self.verifyEqual(ib, [6; 1; 2; 3; 4]);
        end

        function test_int64(self)
            % TODO: force this to use ints
            t_offset = int64(2)^62;
            a = int64([0 4 10 20 30 -40 30]) + t_offset;
            b = int64([1 5 7 31 -10 -40]) + t_offset;
            precision = int64(0);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, int64(-40) + t_offset);
            self.verifyEqual(ia, 6);
            self.verifyEqual(ib, 6);
        end

        function test_int64_even_tol(self)
            t_offset = int64(2)^62;
            a = int64([0 4 10 20 30 -40 30]) + t_offset;
            b = int64([1 5 7 31 -10 -40]) + t_offset;
            precision = int64(2);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(c, int64([-40 0 4 30]) + t_offset);
            self.verifyEqual(ia, [6; 1; 2; 5]);
            self.verifyEqual(ib, [6; 1; 2; 4]);
        end

        function test_int64_odd_tol(self)
            t_offset = int64(2)^62;
            a = int64([0 4 10 20 30 -40 30]) + t_offset;
            b = int64([1 5 7 31 -10 -40]) + t_offset;
            precision = int64(3);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision);
            self.verifyEqual(ia, [6; 1; 2; 3; 5]);
            self.verifyEqual(ib, [6; 1; 2; 3; 4]);
            self.verifyEqual(c, int64([-40 0 4 10 30]) + t_offset);
        end

        function test_rows(self)
            a = [1 2 3 4; 5 6 7 8];
            b = [2 4 6 8; 1 3 5 7];
            precision = 0.1;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'rows');
            self.verifyEqual(c, zeros(0, 4));
            self.verifyEqual(ia, zeros(0, 1));
            self.verifyEqual(ib, zeros(0, 1));
        end

        function test_rows2(self)
            a = [1 2; 3 4; 5 6; 7 8; 9.01 9.999];
            b = [1 3; 3 4.01; 6 5; 9 10; 7 7];
            precision = 0.1;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'rows');
            self.verifyEqual(c, [3 4; 9.01 9.999]);
            self.verifyEqual(ia, [2; 5]);
            self.verifyEqual(ib, [2; 4]);
        end

        function test_rows_and_order(self)
            a = [10 10; 1 2; 5 6; 3 4; 8 8];
            b = [1 2.1; 3 4; 5.1 6.1; 8 9];
            precision = 0.2;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'rows', 'sorted');
            self.verifyEqual(c, [1 2; 5 6; 3 4]); % Note: currently this option doesn't actually do the sort as sorting a row isn't really defined
            self.verifyEqual(ia, [2; 3; 4]);
            self.verifyEqual(ib, [1; 2; 3]);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'rows', 'stable');
            self.verifyEqual(c, [1 2; 5 6; 3 4]);
            self.verifyEqual(ia, [2; 3; 4]);
            self.verifyEqual(ib, [1; 2; 3]);
        end

        function test_stable(self)
            a = [10 20 -30 40 -50 65 70];
            b = (-100:10:100) + 0.01 * rand([1 21]);
            precision = 0.01;
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'sorted');
            self.verifyEqual(c, [-50 -30 10 20 40 70]);
            self.verifyEqual(ia, [5; 3; 1; 2; 4; 7]);
            self.verifyEqual(ib, [6; 8; 12; 13; 15; 18]);
            [c, ia, ib] = matspace.stats.intersect2(a, b, precision, 'stable');
            self.verifyEqual(c, [10 20 -30 40 -50 70]);
            self.verifyEqual(ia, [1; 2; 3; 4; 5; 7]);
            self.verifyEqual(ib, [6; 8; 12; 13; 15; 18]);
        end

        % TODO: add matrices
    end
end