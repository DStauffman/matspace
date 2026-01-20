classdef test_bsr < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the bsr function with the following cases:
    %     Nominal
    %     Multishift
    %     In-place

    properties
        bits,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.bits = [0, 0, 1, 1, 1];
        end
    end

    methods (Test)
        function test_nominal(self)
            out = matspace.gps.bsr(self.bits);
            self.verifyNotEqual(self.bits, out);
            self.verifyEqual(out, [1, 0, 0, 1, 1]);
        end
    
        function test_multiple(self)
            out = matspace.gps.bsr(self.bits, 3);
            self.verifyNotEqual(self.bits, out);
            self.verifyEqual(out, [1, 1, 1, 0, 0]);
        end
    end
end
