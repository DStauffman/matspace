classdef test_modd < matlab.unittest.TestCase %#ok<*PROP>

% Tests the modd function with the following cases:
%     Nominal
%     Scalar
%     scalar and vector
%     vector and scalar
%     matrix versions (x2)

    properties
        x,
        y,
        mod,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.x   = [-4 -3 -2 -1 0 1 2 3 4];
            self.y   = [ 4  1  2  3 4 1 2 3 4];
            self.mod = 4;
        end
    end

    methods (Test)
        function test_nominal(self)
            y = matspace.utils.modd(self.x, self.mod);
            self.verifyEqual(y, self.y);
        end
        function test_scalar(self)
            y = matspace.utils.modd(4, 4);
            self.verifyEqual(y, 4);
        end
        function test_scalar_vector(self)
            y = matspace.utils.modd([2 4], 4);
            self.verifyEqual(y, [2 4]);
        end
        function test_vector_scalar(self)
            y = matspace.utils.modd(4, [3 4]);
            self.verifyEqual(y, [1 4]);
        end
        function test_matrix1(self)
            y = matspace.utils.modd(repmat(self.x, [3 1]), self.mod);
            self.verifyEqual(y, repmat(self.y, [3 1]));
        end
        function test_matrix2(self)
            y = matspace.utils.modd([1 2; 3 4], [1 1; 2 2]);
            self.verifyEqual(y, [1 1; 1 2]);
        end
    end
end