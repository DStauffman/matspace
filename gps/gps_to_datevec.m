function [date_gps] = gps_to_datevec(week, time)

% GPS_TO_DATEVEC  converts a GPS week and time to a MATLAB datevec.
%
% Summary:
%     Calculates the gps date based on the elasped number of weeks using the
%     built-in MATLAB datenum abilities, then applies the time in seconds.
%
% Input:
%     week     : (1xN) or (Nx1) GPS week [week]
%     time     : (1xN) or (Nx1) GPS time of week [sec]
%
% Output:
%     date_out : (Nx6) UTC date vector [year month day hour minute second]
%
% Prototype:
%     week     = [1782 1783];
%     time     = [425916 4132];
%     date_gps = gps_to_datevec(week,time);
%     assert(all(all(date_gps == [2014 3 6 22 18 36; 2014 3 9 1 8 52])));
%
% See Also:
%     datenum
%
% Notes:
%     1.  GPS week zero = Jan 06, 1980 at midnight.
%
% Change Log:
%     1.  Written by David C. Stauffer in Apr 2011.
%     2.  Incorporated by David C. Stauffer into matspace library in Nov 2016.

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

% GPS start week
start_week = datenum(date_zero) + days_per_week*week;
date_gps   = datevec(start_week + time/one_day);