classdef test_gps_to_utc < matlab.unittest.TestCase

    % Tests the matspace.gps.gps_to_datetime function with the following cases:
    %     Nominal
    %     Wrapped
    %     Manual Leap Seconds

    methods (Test)
        function test_nominal(self)
            week = [1782, 1783];
            time = [425916, 4132];
            date_utc = matspace.gps.gps_to_utc(week, time);
            exp = [datetime(2014, 3, 6, 22, 18, 20, TimeZone='UTC'), datetime(2014, 3, 9, 1, 8, 36, TimeZone='UTC')];
            self.verifyEqual(date_utc, exp);
        end

        function test_wrapped(self)
            week = 758;  % 2806 when unrolled in 2021
            time = 425915.34;
            date_utc = matspace.gps.gps_to_utc(week, time);
            exp = datetime(2033, 10, 20, 22, 18, 17, 340, TimeZone='UTC');  % Note: will change with leap seconds
            self.verifyEqual(date_utc, exp);
        end

        function test_manual_leap_seconds(self)
            week = 2806;
            time = 425915;
            date_utc = matspace.gps.gps_to_utc(week, time, GpsToUTcOffset=-200);
            exp = datetime(2033, 10, 20, 22, 15, 15, TimeZone='UTC');
            self.verifyEqual(date_utc, exp);
        end
    end
end
