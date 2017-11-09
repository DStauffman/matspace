function [date_utc] = gps_to_utc(week, time, gps_to_utc_offset)

% GPS_TO_UTC  converts a GPS week and time to UTC time as a datevec.
%
% Summary:
%     Calculates the gps date based on the elasped number of weeks using the
%     built-in MATLAB datenum abilities, then applies the time in seconds,
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
%     date_utc = gps_to_utc(week,time);
%     assert(all(all(date_utc == [2014 3 6 22 18 19; 2014 3 9 1 8 35])));
%
% See Also:
%     datenum, gps_to_datevec
%
% Notes:
%     1.  GPS week zero = Jan 06, 1980 at midnight.
%     2.  The GPS leap second offset as of Jan 2017 is 18 seconds.
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
%     1.  Written by David Stauffer in March 2011.
%     2.  Updated by David Stauffer in Apr 2011 to include leap seconds since J2000.
%     3.  Updated by David C. Stauffer to be current through 2017, and incorporated into DStauffman
%         library.

% hard-coded values
date_zero     = [1980 01 06 00 00 00];
one_day       = 86400;
days_per_week = 7;
week_rollover = 1024;

% if week is less than 1024, then assume it has rollovers that put it in the correct 20 year period
% based on the date returned by the 'now' command.
if week < week_rollover
    num_rollovers = floor((now-datenum(date_zero)) / (days_per_week*week_rollover));
    week          = week + num_rollovers*week_rollover;
end

% check for optional inputs
switch nargin
    % note 9492 = datenum([2006 1 1 0 0 0]) - datenum(date_zero)
    % TODO: make a loop version of this
    case 2
        % starting for current time (2015+)
        gps_to_utc_offset    = -18*ones(size(week));
        days_since_date_zero = week*days_per_week + time/one_day;
        % GPS offset for J2000 - 1 Jan 2006
        gps_to_utc_offset(days_since_date_zero <  9492) = -13;
        % GPS offset for 1 Jan 2006 to 1 Jan 2009
        gps_to_utc_offset(days_since_date_zero < 10588) = -14;
        % GPS offset for 1 Jan 2009 to 1 Jul 2012
        gps_to_utc_offset(days_since_date_zero < 11865) = -15;
        % GPS offset for 1 Jul 2012 to 1 Jul 2015
        gps_to_utc_offset(days_since_date_zero < 12960) = -16;
        % GPS offset for 1 Jul 2015 to 1 Jan 2017
        gps_to_utc_offset(days_since_date_zero < 13510) = -17;
    case 3
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% GPS start week
start_week = datenum(date_zero) + days_per_week*week;
date_utc   = datevec(start_week + (time+gps_to_utc_offset)./one_day);