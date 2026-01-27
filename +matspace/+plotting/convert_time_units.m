function [new_time] = convert_time_units(time, old_unit, new_unit)

% Converts the given time history from the old units to the new units.
%
% Input:
% time : array_like
%     Time history in the old units
% old_unit : str
%     Name of the old units
% new_unit : str
%     Name of the desired new units
%
% Output:
%     new_time : New time history in the new units
%
% Change Log:
%     1.  Written by David C. Stauffer in June 2020.
%
% Prototype:
%     time = 7200;
%     old_unit = 'sec';
%     new_unit = 'hr'
%     new_time = matspace.plotting.convert_time_units(time, old_unit, new_unit);
%     assert(new_time == 2);

arguments (Input)
    time (1, 1) double
    old_unit {mustBeTextScalar}
    new_unit {mustBeTextScalar}
end
arguments (Output)
    new_time (1, 1) double
end

import matspace.plotting.get_time_factor

if strcmp(old_unit, new_unit)
    new_time = time;
    return
end
mult_old = get_time_factor(old_unit);
mult_new = get_time_factor(new_unit);
mult = mult_old / mult_new;
new_time = time * mult;