classdef test_quat_interp < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the qrot function with the following cases:
    %     TBD

    properties
        time,
        quat,
        ti,
        qout,
        ti_extra,
        tolerance,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.time = [1 3 5];
            self.quat = [matspace.quaternions.qrot(1, 0), matspace.quaternions.qrot(1, pi/2), ...
                matspace.quaternions.qrot(1, pi)];
            self.ti   = [1 2 4.5 5];
            self.qout = [matspace.quaternions.qrot(1, 0), matspace.quaternions.qrot(1, pi/4), ...
                matspace.quaternions.qrot(1, 3.5/4*pi), matspace.quaternions.qrot(1, pi)];
            self.ti_extra = [0 1 2 4.5 5 10];
            self.tolerance = 1e-14;
        end
    end

    methods (Test)
        function test_nominal(self)
            qout = matspace.quaternions.quat_interp(self.time, self.quat, self.ti);
            self.verifyEqual(qout, self.qout, 'AbsTol', self.tolerance);
        end

        function test_empty(self)
            qout = matspace.quaternions.quat_interp(self.time, self.quat, []);
            self.verifyEqual(size(qout), [4 0]);
        end

        function test_scalar1(self)
            qout = matspace.quaternions.quat_interp(self.time, self.quat, self.ti(1));
            self.verifyEqual(qout, self.qout(:, 1), 'AbsTol', self.tolerance);
        end

        function test_scalar2(self)
            qout = matspace.quaternions.quat_interp(self.time, self.quat, self.ti(2));
            self.verifyEqual(qout, self.qout(:, 2), 'AbsTol', self.tolerance);
        end

        function test_extra1(self)
            exp_error = 'matspace:QuatInterpExtrap';
            self.verifyError(@() matspace.quaternions.quat_interp(self.time, self.quat, self.ti_extra, true), exp_error);
        end

        function test_extra2(self)
            import matlab.unittest.fixtures.SuppressedWarningsFixture
            self.applyFixture(SuppressedWarningsFixture('matspace:QuatInterpExtrap'));
            qout = matspace.quaternions.quat_interp(self.time, self.quat, self.ti_extra, false);
            self.verifyEqual(qout(:, 2:end-1), self.qout, 'AbsTol', self.tolerance);
            self.verifyEqual(qout(:, [1 end]), nan(4, 2));
        end
    end
end