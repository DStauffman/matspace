classdef test_intersect2 < matlab.unittest.TestCase %#ok<*PROP>

% Tests the fix_rollover function with the following cases:
%     TBD

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

        function test_unique(self)
            a = [1 2.5 4 6];
            b = [0 8 2.5 4 6];
            [c, ia, ib] = matspace.stats.intersect2(a, b);
            self.verifyEqual(c, [2.5 4 6]);
            self.verifyEqual(ia, [2; 3; 4]);
            self.verifyEqual(ib, [3; 4; 5]);
            [c, ia, ib] = matspace.stats.intersect2(a, b, 1e-7);
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
            [c, ia, ib] = matspace.stats.intersect2(a, b, 0.12);
            self.verifyEqual(c, [2 3.1 3.9 4]);
            self.verifyEqual(ia, [2; 3; 4; 5]);
            self.verifyEqual(ib, [1; 2; 3]);
        end
        
        function test_tolerance_no_ix(self)
            a = [1 3 5 7 9];
            b = [1.01 2.02 3.03 4.04 5.05 6.06 7.07 8.08 9.09];
            c = matspace.stats.intersect2(a, b, 0.055);
            self.verifyEqual(c, [1, 3, 5]);
            c2 = matspace.stats.intersect2(b, a, 0.055);
            self.verifyEqual(c2, [1.01 3.03 5.05]);
        end

        function test_int(self)
            % TODO: force this to use ints and non-ints
            a = [0 4 10 20 30 -40 30];
            b = [1 5 7 31 -10 -40];
            [c, ia, ib] = matspace.stats.intersect2(a, b, 0);
            self.verifyEqual(c, -40);
            self.verifyEqual(ia, 6);
            self.verifyEqual(ib, 6);
            [c, ia, ib] = matspace.stats.intersect2(int32(a), int32(b), int32(0));
            self.verifyEqual(c, -40);
            self.verifyEqual(ia, 6);
            self.verifyEqual(ib, 6);
        end

        function test_int_even_tol(self)
            % TODO: force this to use ints
            a = [0 4 10 20 30 -40 30];
            b = [1 5 7 31 -10 -40];
            [c, ia, ib] = matspace.stats.intersect2(a, b, 2);
            self.verifyEqual(c, [-40 0 4 30]);
            self.verifyEqual(ia, [1; 2; 5; 6]);
            self.verifyEqual(ib, [1; 2; 4; 6]);
        end

        function test_int_odd_tol(self)
            % TODO: force this to use ints
            a = [0 4 10 20 30 -40 30];
            b = [1 5 7 31 -10 -40];
            [c, ia, ib] = matspace.stats.intersect2(a, b, 3);
            self.verifyEqual(c, [-40 0 4 10 30]);
            self.verifyEqual(ia, [1; 2; 3; 5; 6]);
            self.verifyEqual(ib, [1; 2; 3; 4; 6]);
        end
        
        function test_int64(self)
            % TODO: force this to use ints
            t_offset = 2^62;
            a = [0 4 10 20 30 -40 30] + t_offset;
            b = [1 5 7 31 -10 -40] + t_offset;
            [c, ia, ib] = matspace.stats.intersect2(a, b, 0);
            self.verifyEqual(c, -40 + t_offset);
            self.verifyEqual(ia, 5);
            self.verifyEqual(ib, 5);
        end
        
        function test_int64_even_tol(self)
            % TODO: force this to use ints
            t_offset = 2^62;
            a = [0 4 10 20 30 -40 30] + t_offset;
            b = [1 5 7 31 -10 -40] + t_offset;
            [c, ia, ib] = matspace.stats.intersect2(a, b, 2);
            self.verifyEqual(c, [-40 0 4 30] + t_offset);
            self.verifyEqual(ia, [1; 2; 5; 6]);
            self.verifyEqual(ib, [1; 2; 4; 6]);
        end

        function test_int64_odd_tol(self)
            % TODO: force this to use ints
            t_offset = 2^62;
            a = [0 4 10 20 30 -40 30] + t_offset;
            b = [1 5 7 31 -10 -40] + t_offset;
            [c, ia, ib] = matspace.stats.intersect2(a, b, 3);
            self.verifyEqual(ia, [1; 2; 3; 5; 6]);
            self.verifyEqual(ib, [1; 2; 3; 4; 6]);
            self.verifyEqual(c, [-40 0 4 10 30] + t_offset);
        end
        
        % TODO: add rows, add stable
    end
end