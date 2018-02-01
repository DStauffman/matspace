classdef test_bins_to_str_ranges < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the bins_to_str_ranges function with the following cases:
    %     Nominal
    %     Different dt
    %     High cut-off
    %     Low cut-off
    %     Bad cut-off
    %     Single value ranges
    %     String passthrough
    
    properties
        bins,
        strs
    end


    methods (TestMethodSetup)
        function initialize(self)
            self.bins = [0 20 40 60 10000];
            self.strs = string({'0-19', '20-39', '40-59', '60+'});
        end
    end
    
    methods (Test)
        function test_nominal(self)
            out = bins_to_str_ranges(self.bins);
            self.verifyEqual(out, self.strs);
        end

        function test_dt(self)
            out = bins_to_str_ranges(self.bins, 0.1);
            self.verifyEqual(out, string({'0-19.9', '20-39.9', '40-59.9', '60+'}));
        end
        
        function test_no_cutoff(self)
            out = bins_to_str_ranges(self.bins, 1, 1e6);
            self.verifyEqual(out, string({'0-19', '20-39', '40-59', '60-9999'}));
        end
    
        function test_no_cutoff2(self)
            out = bins_to_str_ranges([-10, 10, 30]);
            self.verifyEqual(out, string({'-10-9', '10-29'}));
        end

        function test_bad_cutoff(self)
            out = bins_to_str_ranges(self.bins, 1, 30);
            self.verifyEqual(out, string({'0-19', '20+', '40+', '60+'}));
        end

        function test_single_ranges(self)
            out = bins_to_str_ranges([0 1 5 6 10000]);
            self.verifyEqual(out, string({'0', '1-4', '5', '6+'}));
        end

        function test_str_passthrough(self)
            out = bins_to_str_ranges({'Urban', 'Rural', 'ignored'});
            self.verifyEqual(out, string({'Urban', 'Rural'}));
        end

        function test_str_passthrough2(self)
            out = bins_to_str_ranges(string({'Urban', 'Rural', 'ignored'}));
            self.verifyEqual(out, string({'Urban', 'Rural'}));
        end
    end
end