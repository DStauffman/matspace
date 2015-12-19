function [fill_handle]=plot_piece(xc,yc,r,c,half)

% PLOT_PIECE  plots a piece on the board.
%
% Input:
%     xc   : (scalar) x center [num]
%     yc   : (scalar) y center [num]
%     r    : (scalar) radius [num]
%     c    : (1x3) RGB triplet color [num]
%     half : (true/false) optional flag for plotting half a piece [bool]
%
% Output:
%     fill_handle : handle to the piece [num]
%
% Prototype:
%     plot_piece(1,1,0.45,[1 1 1]);
%
% Written by David Stauffer in Jan 2010.

switch nargin
    case 4
        half = false;
    case 5
        % nop
    otherwise
        error('Unexpected number of inputs');
end

% theta angle to sweep out 2*pi
step = pi/24;
if half
    theta = [pi:step:2*pi pi];
else
    theta = 0:step:2*pi;
end

% x & y locations of circle
x = r*cos(theta) + xc;
y = r*sin(theta) + yc;

% plot piece
fill_handle = fill(x,y,c);