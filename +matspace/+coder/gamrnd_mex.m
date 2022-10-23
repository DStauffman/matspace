function [r] = gamrnd_mex(a,b,m,n) %#codegen

% GAMRND_MEX  is a user version of gamrnd that can be compiled.
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
%     r = matspace.coder.gamrnd_mex(a,b,m,n);
%
% See Also:
%     gamrnd, rand, randg
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2021 to use internal version of randg based on
%         numpy implementation instead of relying on the statistics toolbox.
%     2.  Split into its own function by David C. Stauffer in October 2022.
%
% Notes:
%     1.  Could be expanded to make m and n optional, plus additional size inputs or [m,n,...]
%         single option like in the original function.
%     2.  Now that there is a gamma and beta version, the subfunctions should be split out.

% Generate gamma random values with a scale of one, and then scale the results
r = b * randg_mex(a,m,n);

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