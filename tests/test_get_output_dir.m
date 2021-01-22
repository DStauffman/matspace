classdef test_get_output_dir < matlab.unittest.TestCase

    % Tests the get_output_dir function with the following cases:
    %     Nominal

    methods (Test)
        function test_nominal(self)
            out_dir = matspace.paths.get_output_dir();
            exp = ['matspace', filesep, 'results'];
            self.verifyEqual(out_dir(end-length(exp)+1:end), exp);
        end
    end
end