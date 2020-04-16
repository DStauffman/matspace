classdef test_d2r < matlab.unittest.TestCase %#ok<*PROP>

% Tests the d2r function with the following cases:
%     Scalar usage
%     Nominal

    properties
        deg,
        rad,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.deg = [0   30   45   60   90 180    270  360  540  720   -30   -60   -90];
            self.rad = [0 pi/6 pi/4 pi/3 pi/2  pi 3*pi/2 2*pi 3*pi 4*pi -pi/6 -pi/3 -pi/2];
        end
    end

    methods (Test)
        function test_scalar(self)
            for i = 1:length(self.deg)
                out = matspace.units.d2r(self.deg(i));
                self.verifyEqual(out, self.rad(i));
            end
        end

        function test_nominal(self)
            out = matspace.units.d2r(self.deg);
            self.verifyEqual(out, self.rad);
        end
    end
end