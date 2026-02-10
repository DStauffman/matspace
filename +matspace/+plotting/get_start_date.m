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
%     blank_sd1 = matspace.plotting.get_start_date([]);
%     assert(isempty(blank_sd1));
%
%     blank_sd2 = matspace.plotting.get_start_date(NaT);
%     assert(isempty(blank_sd2));
%
%     sd_str1   = matspace.plotting.get_start_date(datevec(now));  %#ok<TNOW1>
%     assert(strncmp(sd_str1, '  t(0) = ', 9));
%
%     sd_str2   = matspace.plotting.get_start_date(datetime('now'));
%     assert(strncmp(sd_str2, '  t(0) = ', 9));
%
% See Also:
%     datestr, datevec, date
%
% Change Log:
%     1.  Written by Matt Beck May 2009.
%     2.  Updated for PGPR 1010 by Matt Beck, June 2009.
%     3.  Incorporated by David C. Stauffer into matspace in December 2018.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% build date string
if isempty(date)
    % return an empty string if no date was specified
    start_date_str = '';
elseif isdatetime(date)
    if isnat(date)
        % return an empty string if a NaT is encountered
        start_date_str = '';
    else
        start_date_str = ['  t(0) = ',char(date, 'dd-MMM-yyyy HH:mm:ss'), ' Z'];
    end
else
    start_date = datestr(date, 0);  %#ok<DATST>
    start_date_str = ['  t(0) = ',start_date,' Z'];
end