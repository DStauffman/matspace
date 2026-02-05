function [date_gps] = gps_to_datetime(week, time)

% GPS_TO_DATETIME  converts a GPS week and time to a MATLAB datetime.
%
% Summary:
%     Calculates the gps date based on the elasped number of weeks using the
%     built-in MATLAB datetime abilities, then applies the time in seconds.
%
% Input:
%     week     : (1xN) or (Nx1) GPS week [week]
%     time     : (1xN) or (Nx1) GPS time of week [sec]
%
% Output:
%     date_out : (Nx6) GPS datetime [year month day hour minute second]
%
% Prototype:
%     week     = [1782 1783];
%     time     = [425916 4132];
%     date_gps = matspace.gps.gps_to_datetime(week, time);
%     assert(all(date_gps == [datetime(2014, 3, 6, 22, 18, 36); datetime(2014, 3, 9, 1, 8, 52)], 'all'));
%
% See Also:
%     datetime, matspace.gps.gps_to_datetime
%
% Notes:
%     1.  GPS week zero = Jan 06, 1980 at midnight.
%
% Change Log:
%     1.  Written by David C. Stauffer in Apr 2011.
%     2.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.
%     4.  Updated by David C. Stauffer in February 2026 to use datetime instead of datevec.

arguments (Input)
    week {mustBeNumeric, mustBeVector}
    time {mustBeNumeric, mustBeVector}
end
arguments (Output)
    date_gps datetime {mustBeVector}
end

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

% GPS start week
start_week = date_zero + one_week*week;
date_gps   = start_week + seconds(time);