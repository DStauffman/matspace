classdef test_apply_prob_to_mask < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the qrot function with the following cases:
    %     Nominal
    %     Zero prob
    %     100% prob

    methods (Test)
        function test_nominal(self)
            import matspace.stats.apply_prob_to_mask
            mask = rand(50000, 1) < 0.5;
            prob = 0.3;
            num = nnz(mask);
            out = apply_prob_to_mask(mask, prob);
            self.verifyLessThan(num, 30000, "Too many trues in mask.");
            self.verifyLessThan(nnz(out), 0.4 * num, "Too many trues in out.");
        end
        function test_row_vector(self)
            import matspace.stats.apply_prob_to_mask
            mask = rand(1, 50000) < 0.5;
            prob = 0.3;
            num = nnz(mask);
            out = apply_prob_to_mask(mask, prob);
            self.verifyLessThan(num, 30000, "Too many trues in mask.");
            self.verifyLessThan(nnz(out), 0.4 * num, "Too many trues in out.");
        end
        function test_zero_prob(self)
            import matspace.stats.apply_prob_to_mask
            mask = rand(1000, 1) < 0.8;
            prob = 0.0;
            out = apply_prob_to_mask(mask, prob);
            self.verifyTrue(all(~out));
        end
        function test_one_prob(self)
            import matspace.stats.apply_prob_to_mask
            mask = rand(1000, 1) < 0.4;
            prob = 1.0;
            out = apply_prob_to_mask(mask, prob);
            self.verifyEqual(out, mask);
        end
    end
end