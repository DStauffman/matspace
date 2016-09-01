function [bac] = calculate_bac(time_drinks, drinks, time_out, body_weight)

% CALCULATE_BAC  calculates a BAC (Blood Alcohol Content) over time
%
% Input:
%     time_drinks : (Mx1) time the drinks were consumed [hour]
%     drinks .... : (Mx1) number of standard drinks consumed [standard drinks]
%     time_out .. : (Nx1) time vector to calculate BAC as output [hour]
%
% Output:
%     bac : (1xN) blood alcohol content over time [ndim]
%
% Prototype:
%     time_drinks = [1; 2; 3; 4; 5; 6];
%     drinks      = [1; 1.5; 2.2; 0.5; 0; 0];
%     time_out    = linspace(0, 12)';
%     body_weight = 105;
%     bac = calculate_bac(time_drinks, drinks, time_out, body_weight);
%
% Notes:
%     1.  One standard drink is a 1 oz 100 proof, 5 oz of wine, or 12 oz of regular beer.
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.

% hard-coded values
drink_weight_conv = 0.0375; % converts standard drinks consumed per pound to BAC
burn_up = 0.00015; % alcohol content burned up per hour

% potentially expand time and data vectors
if time_drinks(1) > time_out(1)
    time_drinks = [time_out(1); time_drinks(:)];
    drinks = [0; drinks(:)];
end
if time_drinks(end) < time_out(end)
    time_drinks(end+1) = inf;
    drinks(end+1) = drinks(end);
end

% find the cumulative amount of drinks consumed
cum_drinks = cumsum(drinks);

% find the BAC assuming no alcohol was converted
bac_init = cum_drinks / body_weight * drink_weight_conv;

% interpolate the BAC to the desired time, still assuming no alcohol was converted
bac_interp = interp1q(time_drinks(:), bac_init(:), time_out(:));

% subtract off the amount that was converted by the body in the given time
bac = max(bac_interp - burn_up * time_out(:), 0);