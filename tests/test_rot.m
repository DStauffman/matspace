classdef test_rot < matlab.unittest.TestCase %#ok<*PROP>
    
    % Tests the rot function with the following cases:
    %     Reference 1, single axis
    %     Reference 2, single axis
    
    properties
        t1,
        t1d,
        r1x,
        r1y,
        r1z,
        t2,
        t2d,
        r2x,
        r2y,
        r2z,
        tolerance,
    end
    
    methods (TestMethodSetup)
        function initialize(self)
            % reference 1
            self.t1 = pi/6;
            self.t1d = 30;
            self.r1x = [1 0 0; 0 sqrt(3)/2 1/2; 0 -1/2 sqrt(3)/2];
            self.r1y = [sqrt(3)/2 0 -1/2; 0 1 0; 1/2 0 sqrt(3)/2];
            self.r1z = [sqrt(3)/2 1/2 0; -1/2 sqrt(3)/2 0; 0 0 1];
            
            % reference 2
            self.t2 = 3*pi/4;
            self.t2d = 135;
            self.r2x = [1 0 0; 0 -sqrt(2)/2 sqrt(2)/2; 0 -sqrt(2)/2 -sqrt(2)/2];
            self.r2y = [-sqrt(2)/2 0 -sqrt(2)/2; 0 1 0; sqrt(2)/2 0 -sqrt(2)/2];
            self.r2z = [-sqrt(2)/2 sqrt(2)/2 0; -sqrt(2)/2 -sqrt(2)/2 0; 0 0 1];
            
            self.tolerance = 1e-12;
        end
    end
    
    methods (Test)
        function test_ref1(self)
            out1 = rot(1, self.t1);
            out2 = rot(2, self.t1);
            out3 = rot(3, self.t1);
            self.verifyEqual(out1, self.r1x, 'AbsTol', self.tolerance);
            self.verifyEqual(out2, self.r1y, 'AbsTol', self.tolerance);
            self.verifyEqual(out3, self.r1z, 'AbsTol', self.tolerance);
        end
        
        function test_ref2(self)
            out1 = rot(1, self.t2);
            out2 = rot(2, self.t2);
            out3 = rot(3, self.t2);
            self.verifyEqual(out1, self.r2x, 'AbsTol', self.tolerance);
            self.verifyEqual(out2, self.r2y, 'AbsTol', self.tolerance);
            self.verifyEqual(out3, self.r2z, 'AbsTol', self.tolerance);
        end
        
        function test_rot_radians(self)
            % out1 = rot(1, self.t1, 0);
            % out2 = rot(2, self.t1, 0);
            % out3 = rot(3, self.t1, 0);
            % out1 = rot(1, self.t2, 0);
            % out2 = rot(2, self.t2, 0);
            % out3 = rot(3, self.t2, 0);
            % self.verifyEqual(out1, self.r1x, 'AbsTol', self.tolerance);
            % self.verifyEqual(out2, self.r1y, 'AbsTol', self.tolerance);
            % self.verifyEqual(out3, self.r1z, 'AbsTol', self.tolerance);
            % self.verifyEqual(out1, self.r2x, 'AbsTol', self.tolerance);
            % self.verifyEqual(out2, self.r2y, 'AbsTol', self.tolerance);
            % self.verifyEqual(out3, self.r2z, 'AbsTol', self.tolerance);
        end
        
        function test_rot_degrees(self)
            % out1 = rot(1, self.t1d, 1);
            % out2 = rot(2, self.t1d, 1);
            % out3 = rot(3, self.t1d, 1);
            % out1 = rot(1, self.t2d, 1);
            % out2 = rot(2, self.t2d, 1);
            % out3 = rot(3, self.t2d, 1);
            % self.verifyEqual(out1, self.r1x, 'AbsTol', self.tolerance);
            % self.verifyEqual(out2, self.r1y, 'AbsTol', self.tolerance);
            % self.verifyEqual(out3, self.r1z, 'AbsTol', self.tolerance);
            % self.verifyEqual(out1, self.r2x, 'AbsTol', self.tolerance);
            % self.verifyEqual(out2, self.r2y, 'AbsTol', self.tolerance);
            % self.verifyEqual(out3, self.r2z, 'AbsTol', self.tolerance);
        end
        
        function test_1ax_mult_rot(self)
            % one axis, multiple rotations
        end
        
        function test_mult_ax_1rot(self)
            % multiple axes, one rotation
        end
        
        function test_mult_ax_mult_rot(self)
            % multiple axes, multiple rotations
        end
        
        function test_mult_ax_mult_rot_1_unit(self)
            % mutiple axis, multiple rotations, one unit
        end
        
        function test_mult_ax_mult_rot_mult_units(self)
            % mutiple axis, multiple rotations, multiple units
        end
    end
end