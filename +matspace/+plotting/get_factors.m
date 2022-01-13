function [mult, label] = get_factors(prefix, inverse)

% GET_FACTORS  gets the multiplication factor and unit label for the desired units.
%
% Input:
%     prefix : (row) string specifying the unit standard metric prefix
%                    from: {'yotta','zetta','exa','peta','tera','giga','mega',
%                           'kilo','hecto','deca','unity','deci','centi','milli',
%                           'micro','nano','pico','femto','atto','zepto','yocto'}
%
% Output:
%     mult   : (scalar) multiplication factor [num]
%     label  : (row) string abbreviation for the prefix [char]
%
% Prototype:
%     prefix = 'micro';
%     [mult, label] = matspace.plotting.get_factors(prefix);
%     assert(mult == 1e-6);
%     assert(strcmp(label, '\mu'));
%
% See Also:
%     matspace.plotting.yscale_plots
%
% Reference:
%     1.  http://en.wikipedia.org/wiki/Metric_prefix
%
% Change Log:
%     1.  Written by David C. Stauffer in November 2012 as part of yscale_plots.
%     2.  Pulled out into a separate function by David C. Stauffer in February 2019.
%     3.  Updated by David C. Stauffer in April 2020 to put into a package.

arguments
    prefix
    inverse logical = false
end

% find the desired units and label prefix
switch prefix
    case 'yotta'
        if ~inverse
            mult = 1e24;
        else
            mult = 1e-24;
        end
        label = 'Y';
    case 'zetta'
        if ~inverse
            mult = 1e21;
        else
            mult = 1e-21;
        end
        label = 'Z';
    case 'exa'
        if ~inverse
            mult = 1e18;
        else
            mult = 1e-18;
        end
        label = 'E';
    case 'peta'
        if ~inverse
            mult = 1e15;
        else
            mult = 1e-15;
        end
        label = 'P';
    case 'tera'
        if ~inverse
            mult = 1e12;
        else
            mult = 1e-12;
        end
        label = 'T';
    case 'giga'
        if ~inverse
            mult = 1e9;
        else
            mult = 1e-9;
        end
        label = 'G';
    case 'mega'
        if ~inverse
            mult = 1e6;
        else
            mult = 1e-6;
        end
        label = 'M';
    case 'kilo'
        if ~inverse
            mult = 1e3;
        else
            mult = 1e-3;
        end
        label = 'k';
    case 'hecto'
        if ~inverse
            mult = 1e2;
        else
            mult = 1e-2;
        end
        label = 'h';
    case 'deca'
        if ~inverse
            mult = 1e1;
        else
            mult = 1e-1;
        end
        label = 'da';
    case 'unity'
        mult = 1;
        label = '';
    case 'deci'
        if ~inverse
            mult = 1e-1;
        else
            mult = 1e1;
        end
        label = 'd';
    case 'centi'
        if ~inverse
            mult = 1e-2;
        else
            mult = 1e2;
        end
        label = 'c';
    case 'milli'
        if ~inverse
            mult = 1e-3;
        else
            mult = 1e3;
        end
        label = 'm';
    case 'micro'
        if ~inverse
            mult = 1e-6;
        else
            mult = 1e6;
        end
        label = '\mu';
    case 'nano'
        if ~inverse
            mult = 1e-9;
        else
            mult = 1e9;
        end
        label = 'n';
    case 'pico'
        if ~inverse
            mult = 1e-12;
        else
            mult = 1e12;
        end
        label = 'p';
    case 'femto'
        if ~inverse
            mult = 1e-15;
        else
            mult = 1e15;
        end
        label = 'f';
    case 'atto'
        if ~inverse
            mult = 1e-18;
        else
            mult = 1e18;
        end
        label = 'a';
    case 'zepto'
        if ~inverse
            mult = 1e-21;
        else
            mult = 1e21;
        end
        label = 'z';
    case 'yocto'
        if ~inverse
            mult = 1e-24;
        else
            mult = 1e24;
        end
        label = 'y';
    % Special cases
    case 'percentage'
        if ~inverse
            mult = 0.01;
        else
            mult = 100;
        end
        label = '%';
    % below follow some stupid english units for rotation angles (try to never use them!)
    case 'arcminute'
        if ~inverse
            mult = 1.0 / ONE_MINUTE * DEG2RAD;
        else
            mult = ONE_MINUTE / DEG2RAD;
        end
        label = 'amin';
    case 'arcsecond'
        if ~inverse
            mult = ARCSEC2RAD;
        else
            mult = RAD2ARCSEC;
        end
        label = 'asec';
    case 'arcsecond^2'
        if ~inverse
            mult = ARCSEC2RAD^2;
        else
            mult = RAD2ARCSEC^2;
        end
        label = 'asec^2';
    case 'milliarcsecond'
        if ~inverse
            mult = 1e3 * ARCSEC2RAD;
        else
            mult = 1e-3 * RAD2ARCSEC;
        end
        label = 'mas';
    case 'microarcsecond'
        if ~inverse
            mult = 1e6 * ARCSEC2RAD;
        else
            mult = 1e-6 * RAD2ARCSEC;
        end
        label = MICRO_SIGN + 'as';
    otherwise
        error('matspace:plotting:InvalidPrefix', 'Unexpected value for units prefix: "%s".', prefix);
end