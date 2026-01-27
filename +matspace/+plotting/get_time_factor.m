function [mult] = get_time_factor(unit)

% Gets the time factor for the given unit relative to the base SI unit of "sec".
%
% Input:
% unit : str, Units to get the multiplying factor for
%
% Output:
% mult : int, Multiplication factor
%
% Prototype:
%     mult = matspace.plotting.get_time_factor('hr');
%     assert(mult == 3600);
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2020.
%     2.  Ported into Matlab by David C. Stauffer in January 2026.

arguments (Input)
    unit {mustBeMember(unit, ["epoch", "sec", "min", "hr", "day"])}
end
arguments (Output)
    mult (1, 1) double
end

switch unit
    case 'epoch'
        mult = 1/400;
    case 'sec'
        mult = 1;
    case 'min'
        mult = 60;
    case 'hr'
        mult = 3600;
    case 'day'
        mult = 86400;
    otherwise
        raise ValueError(f'Unexpected value for "{unit}".')
end