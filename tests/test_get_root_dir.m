classdef test_get_root_dir < matlab.unittest.TestCase

    % Tests the get_root_dir function with the following cases:
    %     Nominal

    methods (Test)
        function test_nominal(self)
            root = matspace.paths.get_root_dir();
            exp = 'matspace';
            self.verifyEqual(root(end-length(exp)+1:end), exp);
        end
    end
end