function [out] = bins_to_str_ranges(bins, dt, cutoff)

% BINS_TO_STR_RANGES  Takes a given bin vector, and returns a string representation with both boundaries.
%
% Input:
%     bins   : (1xN) Boundaries for the bins
%     dt     : (scalar) Amount to subtract from the right side boundary, default is 1
%     cutoff : (scalar) Value at which to consider everything above it as unbounded
%
% Output:
%     out    : (1xN string) text representations of the bins [char]
%
% Notes:
%     1.  This function works on ages, years, CD4 bins or other similar things.
%
% Prototype:
%     age_bins = [0 20 40 60 100000];
%     age_strs = bins_to_str_ranges(age_bins);
%     assert(all(age_strs == ["0-19", "20-39", "40-59", "60+"]));
%
% Change Log
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.

% Check for optional inputs
switch nargin
    case 1
        dt     = 1;
        cutoff = 1000;
    case 2
        cutoff = 1000;
    case 3
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% preallocate output
out = strings(0);

% loop through ages
for r = 1:length(bins)-1
    % alias the left boundary
    left = bins(r);
    % check for string values and just pass them through
    if ~isnumeric(left)
        out(end+1) = left; %#ok<AGROW>
        continue
    end
    % alias the right boundary
    right = bins(r+1) - dt;
    % check for large values, and replace appropriately
    if left == right
        this_str = num2str(left, '%g');
    elseif right < cutoff
        this_str = num2str([left, right], '%g-%g');
    else
        this_str = num2str(left, '%g+');
    end
    % save this result
    out(end+1) = this_str; %#ok<AGROW>
end