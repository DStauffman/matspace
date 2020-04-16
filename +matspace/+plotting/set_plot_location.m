function [] = set_plot_location(fig_hand,location)

% SET_PLOT_LOCATION  sets the plot location on the screen
%
% Summary:
%     This function sets the position argument of a figure to move plots wherever desired
%
% Input:
%     fig_hand : (1xN) list of figure handles [num]
%     location : (1x4) or (1x2) vector of position arguments [num]
%         ~ or ~ (row) string specifying location, from: {'full','fullscreen','huge','left','right','top','bottom','tile'} [char]
%
% Output:
%     (None)
%
% Prototype:
%     fig_hand = figure()
%     plot(0,0);
%     location = 'full';
%     matspace.plotting.set_plot_location(fig_hand,location);
%
% Notes:
%     1.  Expand to include a tile option in the future.
%
% Change Log:
%     1.  Written by David C. Stauffer in Sep 2014.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

% check for optional inputs
switch nargin
    case 0
        fig_hand = gcf;
        location = 'full';
    case 1
        location = 'full';
    case 2
        % nop
    otherwise
        error('Unexpected number of inputs.');
end

% parse possible commands
if ~isnumeric(location)
    % get screen size
    screen = get(0,'ScreenSize');
    hw     = floor(screen(3)/2);
    hh     = floor(screen(4)/2);
    switch location
        case {'default'}
            return
        case {'full','huge','fullscreen'}
            location    = screen;
        case {'left'}
            location    = screen;
            location(3) = hw;
        case {'right'}
            location    = screen;
            location(1) = hw;
            location(3) = hw;
        case {'top'}
            location = screen;
            location(2) = hh;
            location(4) = hh;
        case {'bottom'}
            location    = screen;
            location(4) = hh;
        case {'tile'}
            % TODO:
            error('Not yet implemented.');
        otherwise
            error('Unexpected option for location.');
    end
end

% allow just height and width, and set location to bottom left
if length(location) == 2
    location = [1, 1, location(:)'];
end

% set position/size
set(fig_hand,'position',location);