classdef test_vec_angle < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the bsl function with the following cases:
    %     Nominal
    %     Multishift
    %     In-place

    properties
        vec1,
        vec2,
        vec3,
        exp1,
        exp2,
        exp3,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.vec1 = [1.0; 0.0; 0.0];
            self.vec2 = matspace.vectors.rot(2, 1e-5) * self.vec1;
            self.vec3 = [sqrt(2) / 2; sqrt(2) / 2; 0.0];
            self.exp1 = 1e-5;
            self.exp2 = pi / 4;
            self.exp3 = 2 * pi / 3;
        end
    end

    methods (Test)
        function test_small(self)
            angle = matspace.vectors.vec_angle(self.vec1, self.vec2);
            self.verifyEqual(angle, self.exp1, AbsTol=14);
        end

        function test_bad_small(self)
            angle = matspace.vectors.vec_angle(self.vec1, self.vec2, UseCross=false);
            self.assertTrue(abs(angle - self.exp1) > 1e-14);
        end

        function test_nominal(self)
            angle = matspace.vectors.vec_angle(self.vec1, self.vec3);
            self.verifyEqual(angle, self.exp2, AbsTol=14);
            angle = matspace.vectors.vec_angle(self.vec1, self.vec3, UseCross=false);
            self.verifyEqual(angle, self.exp2, AbsTol=14);
        end

        function test_matrix(self)
            matrix1 = [self.vec1, self.vec2, self.vec3, self.vec1];
            matrix2 = [self.vec2, self.vec1, self.vec1, self.vec1];
            exp1 = [0.0, self.exp1, self.exp2, 0.0];
            exp2 = [self.exp1, self.exp1, self.exp2, 0.0];
            angle = matspace.vectors.vec_angle(matrix1, self.vec1);  % TODO: allow this case
            self.verifyEqual(angle, exp1, AbsTol=14);
            angle = matspace.vectors.vec_angle(self.vec1, matrix1);  % TODO: allow this case
            self.verifyEqual(angle, exp1, AbsTol=14);
            angle = matspace.vectors.vec_angle(matrix1, matrix2);
            self.verifyEqual(angle, exp2, AbsTol=14);
            angle = matspace.vectors.vec_angle(matrix1, matrix2, UseCross=false);
            self.verifyEqual(angle, exp2, AbsTol=12);
        end

        function test_bad_sizes(self)
            self.verifyError(@() matspace.vectors.vec_angle(rand(3, 4), rand(2, 4)), 'matspace:vecAngle:BadSize');
            self.verifyError(@() matspace.vectors.vec_angle(rand(3, 3), rand(3, 5)), 'matspace:vecAngle:BadSize');
        end

        function test_not_normalized(self)
            angle = matspace.vectors.vec_angle([0; 2; 0], [0; -5; 5], Normalized=false, UseCross=true);
            self.verifyEqual(angle, 3 * pi / 4, AbsTol=14);
            angle = matspace.vectors.vec_angle([0; 2; 0], [0; -5; 5], Normalized=false, UseCross=false);
            self.verifyEqual(angle, 3 * pi / 4, AbsTol=14);
        end

        function test_4d_vector(self)
            angle = matspace.vectors.vec_angle([1.0; 0.0; 0.0; 0.0], [0.0; 1.0; 0.0; 0.0], UseCross=false);
            self.verifyEqual(angle, pi / 2);
            self.verifyError(@() matspace.vectors.vec_angle([1.0; 0.0; 0.0; 0.0], [0.0; 1.0; 0.0; 0.0], ...
                UseCross=true), 'MATLAB:cross:InvalidDimAorBForCrossProd');
        end

        function test_2d_vector(self)
            angle = matspace.vectors.vec_angle([1; 0], [-0.5; sqrt(3) / 2], UseCross=false);
            self.verifyEqual(angle, self.exp3, AbsTol=14);
            angle = matspace.vectors.vec_angle([1; 0], [-0.5; -sqrt(3) / 2], UseCross=false);
            self.verifyEqual(angle, self.exp3, AbsTol=14);
            angle = matspace.vectors.vec_angle([1; 0], [-0.5; sqrt(3) / 2], UseCross=true);
            self.verifyEqual(angle, self.exp3, AbsTol=14);
            angle = matspace.vectors.vec_angle([1; 0], [-0.5; -sqrt(3) / 2], UseCross=true);
            self.verifyEqual(angle, self.exp3, AbsTol=14);
        end
    end
end