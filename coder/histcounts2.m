function [n] = histcounts2(x, edges) %#codegen

% HISTCOUNTS2  is a compilable version of the built-in histcounts function.
%
% Input:
%     x     : (Nx1) array of values to be counted into bins [num]
%     edges : (1xM) array of edge values specifying the bins [num]
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
num_bins = length(edges)-1;

% preallocate the output
n = zeros(num_bins, 1);

% loop through the bins and count the entries
for i = 1:num_bins
    if i < num_bins
        n(i) = nnz(x >= edges(i) & x < edges(i+1));
    else
        % this else block is unnecessary, but is here solely to match bulit-in function behavior
        n(i) = nnz(x >= edges(i) & x <= edges(i+1));
    end
end