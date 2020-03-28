function [start_date_str] = get_start_date(date)

% GET_START_DATE  formats a datevec input into a string for xaxis labels.
%
% Summary:
%     Formats a datevec for xaxis plot label appending.  If date argument
%     is empty it returns an empty string.
%
% Input:
%     date           :  (1x6) date vector [year month day hr min sec]
%
% Output:
%     start_date_str :  (row) string with leading white space and 't(0)='
%                       followed by the date formatted to human readable form [char]
%
% Prototype:
%     blank_date           = [];
%     blank_start_date_str = get_start_date(blank_date);
%     assert(isempty(blank_start_date_str));
%
%    date           = datevec(now);
%    start_date_str = get_start_date(date);
%
% See Also:
%    datestr, datevec, date
%
% Change Log:
%     1.  Written by Matt Beck May 2009.
%     2.  Updated for PGPR 1010 by Matt Beck, June 2009.
%     3.  Incorporated by David C. Stauffer into matspace in December 2018.

% build date string
if ~isempty(date)
    start_date = datestr(date,0);
    start_date_str = ['  t(0) = ',start_date,' Z'];
else
    % return an empty string if no date was specified
    start_date_str = '';
end