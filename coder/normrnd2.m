function [r] = normrnd2(mu,sigma,m,n) %#codegen

% NORMRND2  is a user version of normrnd that can be compiled.
%
% Input:
%     mu .. : (scalar) mean
%     sigma : (scalar) standard deviation
%     m ... : (scalar) number of rows
%     n ... : (scalar) number of cols
%
% Output:
%     r ... : (MxN) random numbers based on the given mean and standard deviations
%
% Prototype:
%     mu = 0;
%     sigma = 1;
%     m = 100;
%     n = 1;
%     r = normrnd(mu,sigma,m,n);
%
% See Also:
%     normrnd, randn
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2013.
%     2.  Added to matspace library in December 2015.
%
% Notes:
%     1.  Could be expanded to make m and n optional, plus additional size inputs or [m,n,...]
%         single option like in the original function.

% Return NaN for elements corresponding to illegal parameter values.
sigma(sigma < 0) = NaN;

% Do the random number draw
r = randn(m,n) .* sigma + mu;