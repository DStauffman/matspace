function [costs] = predict_cost(board)

% PREDICT_COSTS  predicts the cost from all locations on the board to the final square.
%
% Input:
%     board : (MxN) board layout
%
% Output:
%     costs : (MxN) predicted cost to finish
%
% Notes
%     1.  Written by David C. Stauffer in December 2015.
%
% Prototype:
%     board    = repmat(PIECE_.null, 2,5);
%     board(1) = PIECE_.start;
%     board(9) = PIECE_.final;
%     costs    = predict_cost(board);
%     assert(all(all(costs == [2 1.5 1 0.5 0; 2 1.5 1 1 0.5])));

% get the board size
[m, n] = size(board);

% find the final position
temp = find(board == PIECE_.final);
if length(temp) ~= 1
    error('dstauffman:knight:FinalPos', 'There must be only exactly one final position.');
end
[x_fin, y_fin] = ind2sub([m, n], temp);

% build a grid of points to evaluate
[X, Y] = meshgrid(1:m, 1:n);
x_dist = abs(X' - repmat(x_fin,m,n)); % explicit repmat for the compiler
y_dist = abs(Y' - repmat(y_fin,m,n)); % explicit repmat for the compiler

mask  = x_dist > y_dist;
costs = max(x_dist/2, y_dist) .* mask + max(x_dist, y_dist/2) .* ~mask;