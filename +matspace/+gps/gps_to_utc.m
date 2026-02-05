function [date_utc] = gps_to_utc(week, time, kwargs)

% GPS_TO_UTC  converts a GPS week and time to UTC time as a datetime.
%
% Summary:
%     Calculates the gps date based on the elasped number of weeks using the
%     built-in MATLAB datetime abilities, then applies the time in seconds,
%     then applies the GPS offset and returns the answer as a datevec.
%
% Input:
%     week              : (1xN) or (Nx1) GPS week [week]
%     time              : (1xN) or (Nx1) GPS time of week [sec]
%     gps_to_utc_offset : |opt| (scalar) gps to UTC leap second correction [sec]
%
% Output:
%     date_utc : (Nx6) UTC date vector [year month day hour minute second]
%
% Prototype:
%     week     = [1782 1783];
%     time     = [425916 4132];
%     date_utc = matspace.gps.gps_to_utc(week, time);
%     assert(all(date_utc == [datetime(2014, 3, 6, 22, 18, 19, TimeZone='UTC'); datetime(2014, 3, 9, 1, 8, 35, TimeZone='UTC')], 'all'));
%
% See Also:
%     datetime, matspace.gps.gps_to_datetime
%
% Notes:
%     1.  GPS week zero = Jan 06, 1980 at midnight.
%
% Reference:
%     Recent Leap Seconds:
%         1999 JAN 01 = JD 2451179.5,  TAI-UTC=  32.0,  GPS-UTC = 13
%         2006 JAN 01 = JD 2453736.5,  TAI-UTC=  33.0,  GPS-UTC = 14
%         2009 JAN 01 = JD 2454832.5,  TAI-UTC=  34.0,  GPS-UTC = 15
%         2012 JUL 01 = JD 2456109.5,  TAI-UTC=  35.0,  GPS-UTC = 16
%         2015 JUL 01 = JD 2457204.5,  TAI-UTC=  36.0,  GPS-UTC = 17
%         2017 JAN 01 = JD 2457754.5,  TAI-UTC=  37.0,  GPS-UTC = 18
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2011.
%     2.  Updated by David C. Stauffer in Apr 2011 to include leap seconds since J2000.
%     3.  Updated by David C. Stauffer to be current through 2017, and incorporated into matspace
%         library.
%     4.  Updated by David C. Stauffer in July 2018, based on bug found by Chinh Tran to add leap
%         second at GPS midnight rather than UTC midnight.
%     5.  Updated by David C. Stauffer in April 2020 to put into a package.
%     6.  Updated by David C. Stauffer in February 2026 to use datetime instead of datevec.

arguments (Input)
    week {mustBeNumeric, mustBeVector}
    time {mustBeNumeric, mustBeVector}
    kwargs.GpsToUTcOffset {mustBeNumeric, mustBeVector} = zeros(1, 0)
end
arguments (Output)
    date_utc datetime {mustBeVector}
end
gps_to_utc_offset = kwargs.GpsToUTcOffset;

import matspace.gps.get_gps_to_utc_offset

% hard-coded values
date_zero     = datetime(1980, 01, 06, 00, 00, 00);
one_week      = 7 * seconds(86400);
week_rollover = 1024;

% if week is less than 1024, then assume it has rollovers that put it in the correct 20 year period
% based on the date returned by the 'now' command.
if week < week_rollover
    num_rollovers = floor((datetime('now') - date_zero) / (one_week*week_rollover));
    week          = week + num_rollovers*week_rollover;
end

% check for optional inputs
if isempty(gps_to_utc_offset)
    days_since_date_zero = days(week*one_week + seconds(time));
    gps_to_utc_offset = get_gps_to_utc_offset(days_since_date_zero);
end

% GPS start week
start_week = date_zero + one_week*week;
date_utc   = start_week + seconds(time + gps_to_utc_offset);
date_utc.TimeZone = 'UTC';