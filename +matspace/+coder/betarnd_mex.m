function [r] = betarnd_mex(a,b,m,n) %#codegen

% BETARND_MEX  is a user version of betarnd that can be compiled.
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
%     r = matspace.coder.betarnd_mex(a,b,m,n);
%
% See Also:
%     betarnd, rand, randg
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2013.
%     2.  Added to matspace library in December 2015.
%     3.  Moved to package by David C. Stauffer in April 2020.
%     4.  Updated by David C. Stauffer in January 2021 to use internal version of randg based on
%         numpy implementation instead of relying on the statistics toolbox.
%
% Notes:
%     1.  Could be expanded to make m and n optional, plus additional size inputs or [m,n,...]
%         single option like in the original function.

% Generate gamma random values and take ratio of the first to the sum.
g1 = randg_mex(a,m,n); % could be Infs or NaNs
g2 = randg_mex(b,m,n); % could be Infs or NaNs

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

%% Subfunctions - binornd
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

%% Subfunctions - randg_mex
function [out] = randg_mex(shape, m, n)
out = zeros(m, n);
for i = 1:m
    for j = 1:n
        out(i, j) = random_standard_gamma(shape);
    end
end

%% Subfunctions - random_standard_gamma
function [out] = random_standard_gamma(shape)

if shape == 1.0
    out = random_standard_exponential();
elseif shape == 0.0
    out = 0.0;
elseif shape < 1.0
    while true
        U = rand();
        V = random_standard_exponential();
        if U <= 1.0 - shape
            X = U^(1./shape);
            if X <= V
                out = X;
                return
            end
        else
            Y = -log((1-U)./shape);
            X = (1.0 - shape + shape*Y) ^ (1./shape);
            if X <= (V + Y)
                out = X;
                return
            end
        end
    end
else
    b = shape - 1./3.;
    c = 1./sqrt(9*b);
    while true
        X = randn();  % do ----
        V = 1.0 + c*X;
        while (V <= 0.0) % while
            X = randn();
            V = 1.0 + c*X;
        end
        V = V*V*V;
        U = rand();
        if (U < 1.0 - 0.0331*(X*X)*(X*X))
            out = (b*V);
            return
        end
        if (log(U) < 0.5*X*X + b*(1. - V + log(V)))
            out = (b*V);
            return
        end
    end
end

%% Subfunctions - random_standard_exponential
function [out] = random_standard_exponential()
out = -log(1.0 - rand());