function [gps_to_utc_offset] = get_gps_to_utc_offset(days_since_gps_date_zero)

% Calculate the GPS to UTC offset given the (fractional) number of days since GPS origin.
% 
% Input:
%     days_since_gps_date_zero: (N, ) Days (in continuous GPS reference, since GPS Date Zero (1980-Jan-06))
% 
% Output:
%     gps_to_utc_offset
% 
% Prototype:
%     gps_to_utc_offset = matspace.gps.get_gps_to_utc_offset(11111);
%     assert(gps_to_utc_offset == -15);
%
% Change Log:
%     1.  Functionalize separately by David C. Stauffer in August 2024 and expanded to include
%         all leap from the start of GPS epoch 0. Also fixed bug where later results where
%         wiping earlier ones.
%     2.  Matlab version replaced by fixed Python one by David C. Stauffer in February 2026.
%
% References:
%     Recent Leap Seconds
%     | Date        |     JD    |   MJD   |DAYS_GPS0| TAI-UTC|GPS-UTC|
%     | 1980 JAN 01 | 2444239.5 | 44239.0 |      0  |  19.0  |   0  |
%     | 1981 JUL 01 | 2444786.5 | 44786.0 |    542  |  20.0  |   1  |
%     | 1982 JUL 01 | 2445151.5 | 45151.0 |    907  |  21.0  |   2  |
%     | 1983 JUL 01 | 2445516.5 | 45516.0 |   1272  |  22.0  |   3  |
%     | 1985 JUL 01 | 2446247.5 | 46247.0 |   2003  |  23.0  |   4  |
%     | 1988 JAN 01 | 2447161.5 | 47161.0 |   2917  |  24.0  |   5  |
%     | 1990 JAN 01 | 2447892.5 | 47892.0 |   3648  |  25.0  |   6  |
%     | 1991 JAN 01 | 2448257.5 | 48257.0 |   4013  |  26.0  |   7  |
%     | 1992 JUL 01 | 2448804.5 | 48804.0 |   4560  |  27.0  |   8  |
%     | 1993 JUL 01 | 2449169.5 | 49169.0 |   4925  |  28.0  |   9  |
%     | 1994 JUL 01 | 2449534.5 | 49534.0 |   5290  |  29.0  |  10  |
%     | 1996 JAN 01 | 2450083.5 | 50083.0 |   5839  |  30.0  |  11  |
%     | 1997 JUL 01 | 2450630.5 | 50630.0 |   6386  |  31.0  |  12  |
%     | 1999 JAN 01 | 2451179.5 | 51179.0 |   6935  |  32.0  |  13  |
%     | 2006 JAN 01 | 2453736.5 | 53736.0 |   9492  |  33.0  |  14  |
%     | 2009 JAN 01 | 2454832.5 | 54832.0 |  10588  |  34.0  |  15  |
%     | 2012 JUL 01 | 2456109.5 | 56109.0 |  11865  |  35.0  |  16  |
%     | 2015 JUL 01 | 2457204.5 | 57204.0 |  12960  |  36.0  |  17  |
%     | 2017 JAN 01 | 2457754.5 | 57754.0 |  13510  |  37.0  |  18  |

import matspace.coder.discretize_mex

assert(all(days_since_gps_date_zero >= 0), 'Days since origin must be positive.');
% get the days since GPS origin that leap seconds are added
day_bounds = [...
    0, 542, 907, 1272, 2003, 2917, 3648, 4013, 4560, 4925, 5290, 5839, 6386, 6935, 9492, 10588, ...
    11865, 12960, 13510, 2^31, ...
];
ONE_DAY = 86400;
partial_days = (0:length(day_bounds) -1) / ONE_DAY;
leap_seconds = 0:-1:-18;
gps_day_bounds = day_bounds + partial_days;
this_bin = discretize_mex(days_since_gps_date_zero, gps_day_bounds);
gps_to_utc_offset = leap_seconds(this_bin);
