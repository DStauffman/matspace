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
%     x     = [nan; 0; 1e-7; 1; 250; 499; 500; 1e6];
%     edges = [eps, 200, 350, 500];
%     % built-in version
%     [n1,edges, bin] = histcounts(x, edges);
%     % this version
%     n2 = histcounts2(x, edges);
%     assert(all(n1(:) == n2));
%
% See Also:
%     histcounts, discretize, discretize2
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