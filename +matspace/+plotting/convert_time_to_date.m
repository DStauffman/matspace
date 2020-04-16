function [date] = convert_time_to_date(time, date_zero, units)

% CONVERT_TIME_TO_DATE  converts a time to a datetime object if not already one
%
% Input:
%     date_zero : (datetime or datevec) representing the date of time zero
%     time .... : (1xN) time in the given units
%     units ... : (str) specifying the units of the time vector, from {'sec', 'min', 'hr', 'day', 'month', 'year'} [char]
%
% Output:
%     date .... : (1xN datetime) dates
%
% Prototype:
%     date_zero = [2003 1 1 0 0 0];
%     time      = 0:10;
%     units     = 'day';
%     date      = matspace.plotting.convert_time_to_date(time, date_zero, units);
%     assert(date(1)  == datetime('01-Jan-2003 00:00:00'));
%     assert(date(11) == datetime('11-Jan-2003 00:00:00'));
%
% Change Log:
%     1.  Written by David C. Stauffer in April 2020.

% simple check for whether we are already in a datetime class
if isdatetime(time)
    date = time;
    return
end

% empty times
if isempty(time)
    date = NaT(size(time));
    return
end

% check infinite cases that don't need units or a date_zero
if isscalar(time) && isinf(time)
    if time == inf
        date = datetime('inf');
    else
        date = datetime('-inf');
    end
    return
end

% optional inputs
switch nargin
    case 2
        units = 'sec';
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

if isempty(date_zero)
    error('matspace:missingDateZero', 'There is no date_zero to use to convert to datetime objects.');
end

% do conversions
switch units
    case 'sec'
        date = datetime(date_zero) + seconds(time);
    case 'min'
        date = datetime(date_zero) + minutes(time);
    case 'hr'
        date = datetime(date_zero) + hours(time);
    case 'day'
        date = datetime(date_zero) + days(time);
    case 'month'
        % Note: months must be integer valued, otherwise use days or fractional years
        date = datetime(date_zero) + calendarDuration(0, time, 0);
    case 'year'
        date = datetime(date_zero) + years(time);
    otherwise
        error('matspace:badTimeUnits', 'Unexpected units of "%s".', units);
end