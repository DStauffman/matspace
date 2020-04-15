function [] = plot_classification(fig_hand, classification, caveat, test, inside_axes)

% PLOT_CLASSIFICATION  displays the classification in a box on each figure.
%
% Summary:
%     This function draws a box on the existing figure windows, with the option of printing
%     another box for testing purposes.
%
% Input:
%     fig_hand       : (1xN) vector of figure handles [num]
%     classification : (row) string specifying classification to use, from {'U','C','S','TS'} [char]
%     caveat         : (row) string specifying the extra caveats beyond the main classification [char]
%     test           : (true/false) flag to specify if this is a test or a real application [bool]
%     inside_axes    : (true/false) flag to specify whether box is inside the axis, or on the figure [bool]
%
% Output:
%     (NONE)
%
% Prototype:
%     f1 = figure;
%     plot([0 1], [0 1], '.-b');
%     plot_classification(f1, 'U');
%     f2 = figure;
%     plot(0, 0);
%     plot_classification(f2, 'S', '//MADE UP CAVEAT', true, false);
%     f3 = figure;
%     plot(0, 0);
%     plot_classification(f3, 'C', '', true, true);
%
%     % clean up
%     close([f1 f2 f3]);
%
% See Also:
%     setup_plots
%
% Change Log:
%     1.  Written by David C. Stauffer in Feb 2010.
%     2.  Updated by David C. Stauffer in Sep 2011 to not be effected by panning and zooming.
%     3.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     4.  Updated by David C. Stauffer in March 2020 to include optional caveats.
%     5.  Updated by David C. Stauffer in April 2020 to remove old markers and handle variable sizes
%         of text better.

%% check for optional inputs
switch nargin
    case 2
        caveat      = '';
        test        = false;
        inside_axes = false;
    case 3
        test        = false;
        inside_axes = false;
    case 4
        inside_axes = false;
    case 5
        % nop
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

% force conversion to newer figure objects
if isnumeric(fig_hand)
    convert_figs = true;
    warning('matspace:Utils:OldNumericFigure', ['Figures passed to plot_classification are in old ' ...
        'format, will be converted from numeric to gobject.']);
else
    convert_figs = false;
end

% simple check to exit if not using
if isempty(classification)
    return
end

%% loop through each figure
for i = 1:length(fig_hand)
    % force conversion to newer figure objects
    if convert_figs
        this_fig = figure(fig_hand(i));
    else
        this_fig = fig_hand(i);
    end
    % remove any pre-existing classification annotations
    remove_old_classifications(this_fig);
    % get the position of the axis within the figure
    ax  = get(this_fig, 'CurrentAxes');
    pos = get(ax, 'Position');
    % plot warning before trying to draw the other box
    if test
        w = 0.6;
        h = 0.1;
        annotation(this_fig, 'textbox' ,'Position', [pos(1)+pos(3)/2-w/2,pos(2)+pos(4)-h,w,h], ...
            'String', 'This plot classification is labeled for test purposes only', ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
            'FontSize', 8, 'FontWeight', 'Bold', 'Color', 'r', 'EdgeColor', 'r', 'LineWidth', 2, ...
            'Tag', 'ClassificationTest');
    end
    % get classification colors and strings
    switch classification
        case 'U'
            color    = [0 0 0];
            text_str = 'UNCLASSIFIED';
        case 'C'
            color    = [0 0 1];
            text_str = 'CONFIDENTIAL';
        case 'S'
            color    = [1 0 0];
            text_str = 'SECRET';
        case {'TS','T'}
            color    = [1 0.65 0];
            text_str = 'TOP SECRET';
        otherwise
            error('matspace:BadClassification', 'Unexpected value for classification: "%s".', ...
                classification);
    end
    text_color = color;
    % determine size of box and append any optional caveat(s)
    h = 0.05;
    if ~isempty(caveat)
        text_str = [text_str, caveat]; %#ok<AGROW>
        w = 0.6;
    else
        w = 0.3;
    end
    % allow other color options for certain caveats
    if contains(caveat, '//FAKE COLOR')
        color      = [0.0 0.8 0.0];
        text_color = [0.2 0.2 0.2];
    end
    % add classification box
    if inside_axes
        annotation(this_fig, 'textbox', 'Position', [pos(1)+pos(3)-w,pos(2),w,h], 'String', text_str, ...
            'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
            'FontSize', 8, 'FontWeight', 'Bold', 'Color', text_color, 'EdgeColor', color, ...
            'LineWidth', 2, 'Tag', 'ClassificationText');
    else
        annotation(this_fig, 'textbox', 'Position', [1-w,0,w,h], 'String', text_str,...
            'HorizontalAlignment', 'Right', 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
            'FontSize', 8, 'FontWeight', 'Bold', 'Color', text_color, 'EdgeColor', color, ...
            'LineWidth', 2, 'Tag', 'ClassificationText');
        annotation(this_fig, 'rectangle', 'Position', [0,0,1,1], 'Color', 'none', 'EdgeColor', color, ...
            'LineWidth',2, 'Tag', 'ClassificationBorder');
    end
end


function remove_old_classifications(this_fig)

% REMOVE_OLD_CLASSIFICATIONS  removes any pre-existing classification markings so that they can
%                             be replaced with new ones without clashing

% Find the axes that potentially contain the annotations
ax = findall(this_fig, 'Tag', 'scribeOverlay');
% then find their children (which might be the actual annotations)
anons = get(ax, 'Children');
if iscell(anons)
    % In R2019B this returns a cell array, where R2018B and older do not
    anons = vertcat(anons{:});
end
% check the tags for any labeled with Classification and delete them
ix = startsWith(arrayfun(@(x) x.Tag, anons, 'UniformOutput', false), 'Classification');
if any(ix)
    delete(anons(ix));
end