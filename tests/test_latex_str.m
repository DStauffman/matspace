classdef test_latex_str < matlab.unittest.TestCase %#ok<*PROP>
    
    % Tests the latex_str function with the following cases:
    %     TBD

    properties
        value,
        value2
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            self.value = 101.666666666666;
            self.value2 = ar2mp(0.2); % 0.016528546178382508
        end
    end
    
    methods (Test)
        function test_string1(self)
            value_str = latex_str('test');
            self.verifyEqual(value_str, 'test');
        end

        function test_string2(self)
            value_str = latex_str('N_O');
            self.verifyEqual(value_str, 'N\_O');
        end

        function test_int1(self)
            value_str = latex_str(2015);
            self.verifyEqual(value_str, '2015');
        end

        function test_int2(self)
            value_str = latex_str(2015, 0, 'fixed', true);
            self.verifyEqual(value_str, '2015');
        end

        function test_int3(self)
            value_str = latex_str(2015, 1, 'fixed', true);
            self.verifyEqual(value_str, '2015.0');
        end

        function test_digits_all(self)
            value_str = latex_str(self.value);
            self.verifyEqual(value_str, '101.666666666666');
        end

        function test_digits0(self)
            value_str = latex_str(self.value, 0);
            self.verifyEqual(value_str, '1e+02');
        end

        function test_digits1(self)
            value_str = latex_str(self.value, 1);
            self.verifyEqual(value_str, '1e+02');
        end

        function test_digits2(self)
            value_str = latex_str(self.value, 2);
            self.verifyEqual(value_str, '1e+02');
        end

        function test_digits3(self)
            value_str = latex_str(self.value, 3);
            self.verifyEqual(value_str, '102');
        end

        function test_digits4(self)
            value_str = latex_str(self.value, 4);
            self.verifyEqual(value_str, '101.7');
        end

        function test_fixed_digits0(self)
            value_str = latex_str(self.value, 0, 'fixed', true);
            self.verifyEqual(value_str, '102');
        end

        function test_fixed_digits1(self)
            value_str = latex_str(self.value, 1, 'fixed', true);
            self.verifyEqual(value_str, '101.7');
        end

        function test_fixed_digits2(self)
            value_str = latex_str(self.value, 2, 'fixed', true);
            self.verifyEqual(value_str, '101.67');
        end

        function test_fixed_digits3(self)
            value_str = latex_str(self.value, 3, 'fixed', true);
            self.verifyEqual(value_str, '101.667');
        end

        function test_cmp2ar1(self)
            value_str = latex_str(self.value2, 3, 'fixed', true);
            self.verifyEqual(value_str, '0.017');
        end

        function test_cmp2ar2(self)
            value_str = latex_str(self.value2, 3, 'fixed', false);
            self.verifyEqual(value_str, '0.0165');
        end

        function test_cmp2ar3(self)
            value_str = latex_str(self.value2, 3, 'fixed', true, 'cmp2ar', true);
            self.verifyEqual(value_str, '0.200');
        end

        function test_cmp2ar4(self)
            value_str = latex_str(self.value2, 3, 'fixed', false, 'cmp2ar', true);
            self.verifyEqual(value_str, '0.2');
        end

        function test_nan(self)
            value_str = latex_str(nan);
            self.verifyEqual(value_str, 'NaN');
        end

        function test_infinity(self)
            value_str = latex_str(inf);
            self.verifyEqual(value_str, '$\infty$');
        end
    end
end