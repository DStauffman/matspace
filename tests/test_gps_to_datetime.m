classdef test_gps_to_datetime < matlab.unittest.TestCase

    % Tests the matspace.gps.gps_to_datetime function with the following cases:
    %     Nominal
    %     Wrapped

    methods (Test)
        function test_nominal(self)
            week = [1782, 1783];
            time = [425916, 4132];
            date_gps = matspace.gps.gps_to_datetime(week, time);
            exp = [datetime(2014, 3, 6, 22, 18, 36), datetime(2014, 3, 9, 1, 8, 52)];
            self.verifyEqual(date_gps, exp)
        end

        function test_wrapped(self)
            week = 758;  % 2806 when unrolled in 2021
            time = 425915.34;
            date_gps = matspace.gps.gps_to_datetime(week, time);
            exp = datetime(2033, 10, 20, 22, 18, 35, 340);
            self.verifyEqual(date_gps, exp);
        end
    end
end