classdef test_get_tests_dir < matlab.unittest.TestCase

    % Tests the get_tests_dir function with the following cases:
    %     Nominal

    methods (Test)
        function test_nominal(self)
            test_dir = matspace.paths.get_tests_dir();
            exp = ['matspace', filesep, 'tests'];
            self.verifyEqual(test_dir(end-length(exp)+1:end), exp);
        end
    end
end