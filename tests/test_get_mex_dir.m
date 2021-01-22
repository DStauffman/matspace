classdef test_get_mex_dir < matlab.unittest.TestCase

    % Tests the get_mex_dir function with the following cases:
    %     Nominal

    methods (Test)
        function test_nominal(self)
            mex_dir = matspace.paths.get_mex_dir();
            exp = ['matspace', filesep, 'mex'];
            self.verifyEqual(mex_dir(end-length(exp)+1:end), exp);
        end
    end
end