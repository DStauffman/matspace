function [bins] = discretize2(x, edges) %#codegen

% DISCRETIZE2  is a compilable version of the built-in discretize function.
%
% Input:
%     x     : (Nx1) array of values to be discretized into bins
%     edges : (1xM) array of edges specifying the bins
%
% Output:
%     bins  : (Nx1) array of values specifying which bin the x values fall into.
%
% Prototype:
%     x     = [-1; 0; 5; 10; 12; 35];
%     edges = [0, 10, 20];
%     % built-in version
%     bins1 = discretize(x, edges);
%     % this version
%     bins2 = discretize2(x, edges);
%     assert(all(isequaln(bins1, bins2)));
%
% Notes:
%     1.  Values that don't go into any bin will return a bin of NaN.
%
% See Also:
%     discretize, histcounts, histcounts2
%
% Change Log:
%     1.  Written by David C. Stauffer in October 2016.

% count the number of bins that are greater than the current value and sum across.
bins = sum(bsxfun(@ge,x(:),edges(:)'),2);

% take care of values that fall outside the bins.
bins(bins < 1) = nan;
bins(bins >= length(edges)) = nan;