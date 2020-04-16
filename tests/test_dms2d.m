classdef test_dms2d < matlab.unittest.TestCase %#ok<*PROP>

% Tests the dms2d function with the following cases:
%     Scalar usage
%     Nominal

    properties
        deg,
        dms,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.deg = [0 15.508333333333333 30.253333333333333 181.3416666666666666 359.66666944444444444 362.2670833333333333];
            self.dms = [0 15 30 181  359  361;...
                        0 30 15  20   40   75; ...
                        0 30 12  30 0.01 61.5];
        end
    end

    methods (Test)
        function test_scalar(self)
            for i = 1:length(self.deg)
                out = matspace.units.dms2d(self.dms(:,i));
                self.verifyEqual(out, self.deg(i), 'AbsTol', 1e-14);
            end
        end

        function test_nominal(self)
            out = matspace.units.dms2d(self.dms);
            self.verifyEqual(out, self.deg, 'AbsTol', 1e-14);
        end
    end
end