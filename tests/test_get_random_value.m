classdef test_get_random_value < matlab.unittest.TestCase
    methods (Test)
        function test_none(self)
            import matspace.utils.get_random_value
            % single draw
            value = get_random_value('None');
            self.verifyEqual(value, 1);
            % vector draw
            num = [100, 1];
            values = get_random_value('None', num);
            exp = ones(num);
            self.verifyEqual(values, exp);
            % scaled draw
            scaled_values = get_random_value('None', num, 5);
            exp = repmat(5, num);
            self.verifyEqual(scaled_values, exp);
        end
        function test_uniform(self)
            import matspace.utils.get_random_value
            % single draw
            value = get_random_value('Uniform');
            self.verifyLessThan(value, 1);
            self.verifyGreaterThanOrEqual(value, 0);
            % vector draw
            num = [10000, 1];
            values = get_random_value('Uniform', num);
            self.verifyEqual(size(values), num);
            self.verifyLessThan(values, 1);
            self.verifyGreaterThanOrEqual(values, 0);
            half = nnz(value < 0.5);
            self.verifyTrue(half > 4500 & half < 5500);
            % scaled draw
            scaled_values = get_random_value('Uniform', num, 0, 10);
            self.verifyEqual(size(scaled_values), num);
        end
        function test_normal(self)
            import matspace.utils.get_random_value
            % single draw
            value = get_random_value('Normal');
            self.verifyEqual(size(value), [1 1]);
            % vector draw
            num = [10000, 1];
            values = get_random_value('Normal', num);
            m = mean(values);
            s = std(values);
            tol = 0.1;
            self.verifyGreaterThan(m, -tol);
            self.verifyLessThan(m, +tol);
            self.verifyGreaterThan(s, 1 - tol);
            self.verifyLessThan(s, 1 + tol);
            % scaled draw
            mu = 5;
            sigma = 3;
            scaled_values = get_random_value('Normal', num, mu, sigma);
            m = mean(scaled_values);
            s = std(scaled_values);
            tol = 0.1;
            self.verifyGreaterThan(m, mu - tol);
            self.verifyLessThan(m, mu + tol);
            self.verifyGreaterThan(s, sigma - tol);
            self.verifyLessThan(s, sigma + tol);
        end
        function test_beta(self)
            import matspace.utils.get_random_value
            % single draw
            value = get_random_value('Beta');
            self.verifyEqual(size(value), [1 1]);
            % vector draw
            num = [10000, 1];
            %values = get_random_value('Beta', num, 0, 10);

            % scaled draw
            %scaled_values = get_random_value('Beta', num, 0, 10, 1, 2);
            %exp = ones(num);
            %self.verifyEqual(value, exp);
        end
%         function test_gamma(self)
%             import matspace.utils.get_random_value
%             num = [10000, 1];
%             value = get_random_value('Gamma', num, 1, 2);
%             exp = ones(num);
%             self.verifyEqual(value, exp);
%         end
%         function test_triangle(self)
%             import matspace.utils.get_random_value
%             num = [10000, 1];
%             value = get_random_value('Triangle', num, 0, 4);
%             exp = ones(num);
%             self.verifyEqual(value, exp);
%         end
    end
end