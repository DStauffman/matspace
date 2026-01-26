classdef test_ifelse < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the ifelse function with the following cases:
    %     True
    %     False
    %     non-scalar outputs

    methods (Test)
        function test_true(self)
            out = matspace.utils.ifelse(true, 3, 5);
            self.verifyEqual(out, 3);
        end

        function test_false(self)
            out = matspace.utils.ifelse(false, 3, 5);
            self.verifyEqual(out, 5);
        end

        function test_nonscalar(self)
            out = matspace.utils.ifelse(true, 'option', 'default');
            self.verifyEqual(out, 'option');
            out = matspace.utils.ifelse(false, "option", "default");
            self.verifyEqual(out, "default");
            out = matspace.utils.ifelse(true, [1, 2, 3], 5:10);
            self.verifyEqual(out, [1, 2, 3]);
        end

        function test_bad_boolean(self)
            self.verifyError(@() matspace.utils.ifelse([true false], [1, 2], [3, 4]), ...
                'MATLAB:validation:IncompatibleSize');
        end
    end
end