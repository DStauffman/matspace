classdef test_unit < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the minmin function with the following cases:
    %     single row input
    %     single col input
    %     4D matrix, should operate on 1st dim
    %     3D matrix, operate on 2nd dim
    %     first non-singleton dimension
    %     zero vector
    %     complex conjugate

    methods (Test)
        function test_row(self)
            x = [1 2 3 4];
            y = matspace.utils.unit(x);
            self.verifyEqual(sum(y.^2), 1, 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x), zeros(1,3), 'AbsTol', 1e-15);
        end

        function test_column(self)
            x = [1 2 3 4]';
            y = matspace.utils.unit(x);
            self.verifyEqual(sum(y.^2), 1, 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x), zeros(3,1), 'AbsTol', 1e-15);
        end

        function test_4d_matrix(self)
            x = rand(3,2,4,5);
            y = matspace.utils.unit(x);
            self.verifyEqual(sum(y.^2), ones(1,2,4,5), 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x), zeros(2,2,4,5), 'AbsTol', 1e-15);
        end

        function test_specified_dim(self)
            x = rand(3,4,5);
            y = matspace.utils.unit(x, 2);
            self.verifyEqual(sum(y.^2,2), ones(3,1,5), 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x,1,2), zeros(3,3,5), 'AbsTol', 1e-15);
        end

        function test_first_non_singleton_dim(self)
            x = rand(1,1,3,1,5);
            y = matspace.utils.unit(x);
            self.verifyEqual(sum(y.^2), ones(1,1,1,1,5), 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x), zeros(1,1,2,1,5), 'AbsTol', 1e-15);
        end

        function test_zeros(self)
            x = [0 1; 0 2];
            y = matspace.utils.unit(x);
            self.verifyTrue(all(isnan(y(:,1))));
        end

        function test_complex_conjugate(self)
            x = [2+1i 2-1i; 1 1];
            y = matspace.utils.unit(x);
            self.verifyEqual(sum(y.*conj(y)), ones(1,2), 'AbsTol', 1e-15);
            self.verifyEqual(diff(y./x), zeros(1,2), 'AbsTol', 1e-15);
        end
    end
end