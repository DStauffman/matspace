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
            self.strs = ["0-19", "20-39", "40-59", "60+"];
        end
    end

    methods (Test)
        function test_nominal(self)
            out = matspace.latex.bins_to_str_ranges(self.bins);
            self.verifyEqual(out, self.strs);
        end

        function test_dt(self)
            out = matspace.latex.bins_to_str_ranges(self.bins, 0.1);
            self.verifyEqual(out, ["0-19.9", "20-39.9", "40-59.9", "60+"]);
        end

        function test_no_cutoff(self)
            out = matspace.latex.bins_to_str_ranges(self.bins, 1, 1e6);
            self.verifyEqual(out, ["0-19", "20-39", "40-59", "60-9999"]);
        end

        function test_no_cutoff2(self)
            out = matspace.latex.bins_to_str_ranges([-10, 10, 30]);
            self.verifyEqual(out, ["-10-9", "10-29"]);
        end

        function test_bad_cutoff(self)
            out = matspace.latex.bins_to_str_ranges(self.bins, 1, 30);
            self.verifyEqual(out, ["0-19", "20+", "40+", "60+"]);
        end

        function test_single_ranges(self)
            out = matspace.latex.bins_to_str_ranges([0 1 5 6 10000]);
            self.verifyEqual(out, ["0", "1-4", "5", "6+"]);
        end

        function test_str_passthrough(self)
            out = matspace.latex.bins_to_str_ranges({'Urban', 'Rural', 'ignored'});
            self.verifyEqual(out, ["Urban", "Rural"]);
        end

        function test_str_passthrough2(self)
            out = matspace.latex.bins_to_str_ranges(["Urban", "Rural", "ignored"]);
            self.verifyEqual(out, ["Urban", "Rural"]);
        end
    end
end