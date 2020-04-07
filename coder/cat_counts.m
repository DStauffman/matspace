function [n] = cat_counts(x, cats) %#codegen

% CAT_COUNTS  is a compilable version of the categorical counts of discretize.
%
% Input:
%     x     : (Nx1) array of values to be counted into bins [num]
%     cats  : (1xM) array of category values [num]
%
% Output:
%     n     : (M-1x1) array of counts of the values in the bins [num]
%
% Prototype:
%     x    = [1 2 3 1 1 4 8 3];
%     cats = [1 2 3 4];
%     n    = cat_counts(x, cats);
%     assert(all(n == [3; 1; 2; 1]));
%
% See Also:
%     histcounts, discretize, discretize_mex
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2016.

% get the number of bins
num_bins = length(cats);

% preallocate the output
n = zeros(num_bins, 1);

% loop through the bins and count the entries
for i = 1:num_bins
    n(i) = nnz(x == cats(i));
end