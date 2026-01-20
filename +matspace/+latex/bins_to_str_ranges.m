function [out] = bins_to_str_ranges(bins, dt, cutoff)

% BINS_TO_STR_RANGES  Takes a given bin vector, and returns a string representation with both boundaries.
%
% Input:
%     bins   : (1xN) Boundaries for the bins
%     dt     : (scalar) Amount to subtract from the right side boundary, default is 1
%     cutoff : (scalar) Value at which to consider everything above it as unbounded
%
% Output:
%     out    : (1xN-1 string) text representations of the bins [char]
%
% Notes:
%     1.  This function works on ages, years, CD4 bins or other similar things.
%
% Prototype:
%     age_bins = [0 20 40 60 100000];
%     age_strs = matspace.latex.bins_to_str_ranges(age_bins);
%     assert(all(age_strs == ["0-19", "20-39", "40-59", "60+"]));
%
% Change Log
%     1.  Ported from Python to Matlab by David C. Stauffer in January 2018.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.
%     3.  Updated by David C. Stauffer in January 2026 to use arguments.

arguments (Input)
    bins {mustBeVector}
    dt (1, 1) double = 1
    cutoff (1, 1) double = 1000
end

arguments (Output)
    out (1, :) string
end

% preallocate output
num_bins = length(bins)-1;
out = strings(1, num_bins);

% loop through ages
for i = 1:num_bins
    % alias the left boundary
    left = bins(i);
    % check for string values and just pass them through
    if ~isnumeric(left)
        out(i) = left;
        continue
    end
    % alias the right boundary
    right = bins(i + 1) - dt;
    % check for large values, and replace appropriately
    if left == right
        this_str = num2str(left, '%g');
    elseif right < cutoff
        this_str = num2str([left, right], '%g-%g');
    else
        this_str = num2str(left, '%g+');
    end
    % save this result
    out(i) = this_str;
end