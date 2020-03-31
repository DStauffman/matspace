function [classification, caveat] = get_classification(classify)

% GET_CLASSIFICATION  gets the classification and any caveats from the text in OPTS
%
% Input:
%     classify : (row) string specifying text to put on plots for classification purposes [char]
%
% Output:
%     classification : (row) string specifying classification to use, from {'U', 'C', 'S', 'TS'} [char]
%     caveat ....... : (row) string specifying the extra caveats beyond the main classification [char]
%
% Prototype:
%     classify = 'UNCLASSIFIED//MADE UP CAVEAT';
%     [classification, caveat] = get_classification(classify);
%
% See Also:
%     plot_classification
%
% Change Log:
%     1.  Written by David C. Stauffer in March 2020.

% check for empty case, default to unclassified
if isempty(classify)
    % DCS: modify this section if you want a different default on your system (potentially put into a file instead?)
    classification = '';
    caveat         = '';
    return
end

% get the classification based solely on the first letter and check that it is valid
classification = classify(1);
assert(any(strcmp(classification, {'U', 'C', 'S', 'T'})), 'Unexpected classification of "%s" found', classification);

% pull out anything past the first // as the caveat(s)
slashes = strfind(classify, '//');
if isempty(slashes)
    caveat = '';
else
    caveat = classify(slashes(1):end);
end