function [out] = convert_npdatetime64_to_datetime(np_date, kwargs)

% CONVERT_NPDATETIME64_TO_DATETIME  converts a given numpy datetime64 to a Matlab datetime
%
% Prototype:
%     np_date = 1770234209000000000;
%     out = matspace.time.convert_npdatetime64_to_datetime(np_date);
%     assert(out == datetime(2026, 2, 4, 19, 43, 29, TimeZone='UTC'));

arguments (Input)
    np_date {mustBeVector}  % double or int64
    kwargs.Units (1, 1) string = "ns"
    kwargs.TimeZone (1, 1) string = "UTC"
end
arguments (Output)
    out datetime {mustBeVector}
end
units = kwargs.Units;
time_zone = kwargs.TimeZone;

switch units
    case 'Y'
        ticks = nan;  % TODO: non-linear conversion
    case 'M'
        ticks = nan;  % TODO: non-linear conversion
    case 'W'
        ticks = 1/(7*86400);
    case 'D'
        ticks = 1/86400;
    case 'h'
        ticks = 1/3600;
    case 'm'
        ticks = 1/60;
    case 's'
        ticks = 1;
    case 'ms'
        ticks = 1e3;
    case {'us', 'μs'}
        ticks = 1e6;
    case 'ns'
        ticks = 1e9;
    case 'ps'
        ticks = 1e12;
    case 'fs'
        ticks = 1e15;
    case 'at'
        ticks = 1e18;
    otherwise
        error('Not yet implemented.');
end

out = datetime(np_date, ConvertFrom='epochtime', Epoch='1970-01-01', TicksPerSecond=ticks, TimeZone=time_zone);