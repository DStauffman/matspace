function [out] = convert_posix_to_datetime(posix, kwargs)

% CONVERT_POSIX_TO_DATETIME  converts a given posix time to a Matlab datetime.
%
% Input:
%     posix        : date as seconds since posix origin (1970-01-01)
%     kwargs       :
%         TimeZone : time zone, default is UTC
%
% Output:
%     out : date as matlab datetime
%
% Prototype:
%     posix = 1770234209;
%     out = matspace.time.convert_posix_to_datetime(posix);
%     assert(out == datetime(2026, 2, 4, 19, 43, 29, TimeZone='UTC'));
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

arguments (Input)
    posix {mustBeVector, mustBeNumeric}
    kwargs.TimeZone (1, 1) string = "UTC"
end
arguments (Output)
    out datetime {mustBeVector}
end
time_zone = kwargs.TimeZone;

out = datetime(posix, ConvertFrom='posixtime', TimeZone=time_zone);