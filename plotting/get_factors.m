function [mult, label] = get_factors(prefix)

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
%     [mult, label] = get_factors(prefix);
%     assert(mult == 1e-6);
%     assert(strcmp(label, '\mu'));
%
% See Also:
%     yscale_plots
%
% Reference:
%     1.  http://en.wikipedia.org/wiki/Metric_prefix
%
% Change Log:
%     1.  Written by David C. Stauffer in November 2012 as part of yscale_plots.
%     2.  Pulled out into a separate function by David C. Stauffer in February 2019.

% find the desired units and label prefix
switch prefix
    case 'yotta'
        mult  = 1e24;
        label = 'Y';
    case 'zetta'
        mult  = 1e21;
        label = 'Z';
    case 'exa'
        mult  = 1e18;
        label = 'E';
    case 'peta'
        mult  = 1e15;
        label = 'P';
    case 'tera'
        mult  = 1e12;
        label = 'T';
    case 'giga'
        mult  = 1e9;
        label = 'G';
    case 'mega'
        mult  = 1e6;
        label = 'M';
    case 'kilo'
        mult  = 1e3;
        label = 'k';
    case 'hecto'
        mult  = 1e2;
        label = 'h';
    case 'deca'
        mult  = 1e1;
        label = 'da';
    case 'unity'
        mult  = 1;
        label = '';
    case 'deci'
        mult  = 1e-1;
        label = 'd';
    case 'centi'
        mult  = 1e-2;
        label = 'c';
    case 'milli'
        mult  = 1e-3;
        label = 'm';
    case 'micro'
        mult  = 1e-6;
        label = '\mu';
    case 'nano'
        mult  = 1e-9;
        label = 'n';
    case 'pico'
        mult  = 1e-12;
        label = 'p';
    case 'femto'
        mult  = 1e-15;
        label = 'f';
    case 'atto'
        mult  = 1e-18;
        label = 'a';
    case 'zepto'
        mult  = 1e-21;
        label = 'z';
    case 'yocto'
        mult  = 1e-24;
        label = 'y';
    otherwise
        error('matspace:plotting:InvalidPrefix', 'Unexpected value for units prefix: "%s".', prefix);
end