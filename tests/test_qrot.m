classdef test_qrot < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the qrot function with the following cases:
    %     Single input case
    %     Single axis, multiple angles
    %     Multiple axes, single angle
    %     Multiple axes, multiple angles
    %     Null (x2)
    %     Vector mismatch (causes AssertionError)

    properties
        axis,
        angle,
        angle2,
        quat,
        quat2,
        null,
        null_quat,
        tolerance,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.axis   = [1 2 3];
            self.angle  = pi/2;
            self.angle2 = pi/3;
            r2o2        = sqrt(2)/2;
            r3o2        = sqrt(3)/2;
            self.quat   = [r2o2 0 0 r2o2; 0 r2o2 0 r2o2; 0 0 r2o2 r2o2]';
            self.quat2  = [ 0.5 0 0 r3o2; 0  0.5 0 r3o2; 0 0  0.5 r3o2]';
            self.null   = [];
            self.null_quat = zeros(4, 0);
            self.tolerance = 1e-14;
        end
    end

    methods (Test)
        function test_single_inputs(self)
            for i = 1:length(self.axis)
                quat = matspace.quaternions.qrot(self.axis(i), self.angle);
                self.verifyEqual(quat, self.quat(:, i), 'AbsTol', self.tolerance);
            end
        end
        
        function test_single_axis(self)
            for i = 1:length(self.axis)
                quat = matspace.quaternions.qrot(self.axis(i), [self.angle, self.angle2]);
                self.verifyEqual(quat, [self.quat(:, i), self.quat2(:, i)], 'AbsTol', self.tolerance);
            end
        end

        function test_single_angle(self)
            quat = matspace.quaternions.qrot(self.axis, self.angle);
            self.verifyEqual(quat, self.quat, 'AbsTol', self.tolerance);
        end

        function test_all_vector_inputs(self)
            quat = matspace.quaternions.qrot(self.axis, [self.angle, self.angle, self.angle2]);
            self.verifyEqual(quat, [self.quat(:,1), self.quat(:,2), self.quat2(:,3)], 'AbsTol', self.tolerance);
        end

        function test_null1(self)
            quat = matspace.quaternions.qrot(self.axis(1), self.null);
            self.verifyEqual(quat, self.null_quat);
        end

        function test_null2(self)
            quat = matspace.quaternions.qrot(self.null, self.angle);
            self.verifyEqual(quat, self.null_quat);
        end

        function test_vector_mismatch(self)
            % TODO: raises error
            self.verifyError(@() matspace.quaternions.qrot(self.axis, [self.angle, self.angle2]), 'MATLAB:assertion:failed');
        end

        function test_larger_angle(self)
            quat = matspace.quaternions.qrot(1, 5.1*pi);
            self.verifyGreaterThan(quat(4), 0);
        end
    end
end