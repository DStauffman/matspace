function [out] = convert_datetime_to_npdatetime64(date_time, kwargs)

% CONVERT_NPDATETIME64_TO_DATETIME  converts a given numpy datetime64 to a Matlab datetime
%
% Prototype:
%     date_time = datetime(2026, 2, 4, 19, 43, 29, TimeZone='UTC');
%     out = matspace.time.convert_datetime_to_npdatetime64(date_time);
%     assert(out == int64(1770234209000000000));

arguments (Input)
    date_time {mustBeVector}  % double or int64
    kwargs.Units (1, 1) string = "ns"
end
arguments (Output)
    out {mustBeVector, mustBeNumeric}
end
units = kwargs.Units;

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

out = convertTo(date_time, 'epochtime', Epoch='1970-01-01', TicksPerSecond=ticks);