function [r] = betarnd2(a,b,m,n) %#codegen

% BETARND2  is a user version of betarnd that can be compiled.
%
% Input:
%     a : (scalar) alpha shaping parameter for beta function
%     b : (scalar) beta shaping parameter for beta function
%     m : (scalar) number of rows
%     n : (scalar) number of cols
%
% Output:
%     r : (MxN) random numbers based on the given alpha and beta
%
% Prototype:
%     a = 1;
%     b = 1;
%     m = 100;
%     n = 1;
%     r = betarnd(a,b,m,n);
%
% See Also:
%     betarnd, rand, randg
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2013.
%     2.  Added to matspace library in December 2015.
%
% Notes:
%     1.  Could be expanded to make m and n optional, plus additional size inputs or [m,n,...]
%         single option like in the original function.

coder.extrinsic('randg');

% declare variable type for the compiler
g1 = zeros(m,n);
g2 = zeros(m,n);

% Generate gamma random values and take ratio of the first to the sum.
g1 = randg(a,m,n); % could be Infs or NaNs
g2 = randg(b,m,n); % could be Infs or NaNs

r = g1 ./ (g1 + g2);

% For a and b both very small, we often get 0/0.  Since the distribution is
% essentially a Bernoulli(a/(a+b)), we can replace those NaNs.
t = (g1==0 & g2==0);
if any(t)
    p = a ./ (a+b);
    if ~isscalar(p)
        p = p(t);
    end
    r(t) = binornd(1,p(:),sum(t(:)),1);
end

%% Subfunctions
function r = binornd(n,p,c,d)

if isscalar(p)
    p_full = p * ones(c,d);
else
    p_full = p;
end

r = zeros(c,d);
for i = 1:max(n(:))
    k = find(n >= i);
    r(k) = r(k) + (rand(size(k)) < p_full(k));
end
r(p_full < 0 | 1 < p_full | n < 0 | round(n) ~= n) = NaN;