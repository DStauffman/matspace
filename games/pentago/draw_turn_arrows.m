function [] = draw_turn_arrows(handles)

% DRAW_TURN_ARROWS  draws the turn arrows on the GUI
%
% Input:
%     (TBD)
%
% Output:
%     None
%
% Prototype:
%     (TBD)
%
% Written by David Stauffer in Mar 2010.
%
% Note: this code is already embedded in the .fig file

% declare persistents
persistent right1
persistent right2
persistent right3
persistent right4
persistent left1
persistent left2
persistent left3
persistent left4

% get static globals
COLOR = get_static_globals({'COLOR'});

% load images from .png files into persistent variables
if isempty(right1)
    right1 = imread('right1.png','png','BackgroundColor',COLOR.button);
    right2 = imread('right2.png','png','BackgroundColor',COLOR.button);
    right3 = imread('right3.png','png','BackgroundColor',COLOR.button);
    right4 = imread('right4.png','png','BackgroundColor',COLOR.button);
    left1  = imread('left1.png', 'png','BackgroundColor',COLOR.button);
    left2  = imread('left2.png', 'png','BackgroundColor',COLOR.button);
    left3  = imread('left3.png', 'png','BackgroundColor',COLOR.button);
    left4  = imread('left4.png', 'png','BackgroundColor',COLOR.button);
end

% update button backgrounds to be arrow images
set(handles.button_1R,'CData',right1);
set(handles.button_2R,'CData',right2);
set(handles.button_3R,'CData',right3);
set(handles.button_4R,'CData',right4);
set(handles.button_1L,'CData',left1);
set(handles.button_2L,'CData',left2);
set(handles.button_3L,'CData',left3);
set(handles.button_4L,'CData',left4);