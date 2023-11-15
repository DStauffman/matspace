function [] = plot_classification(fig_hand, classification, kwargs)

% PLOT_CLASSIFICATION  displays the classification in a box on each figure.
%
% Summary:
%     This function draws a box on the existing figure windows, with the option of printing
%     another box for testing purposes.
%
% Input:
%     fig_hand        : (1xN) vector of figure handles [num]
%     classification  : (row) string specifying classification to use, from {'', 'U','CUI', 'C','S','TS'} [char]
%     kwargs          : 
%         .caveat     : (row) keywstring specifying the extra caveats beyond the main classification [char]
%         .test       : (true/false) flag to specify if this is a test or a real application [bool]
%         .location   : (row) string specifying where to put the label, from:
%                           'axis' or 'axes' - places it at the lower right corner of the axes
%                           'figure' - places it at  the lower right corner of the figure
%                           'left' - places it at  the lower left corner of the figure
%                           'top' - places it at  the upper left corner of the figure
%                           'top&bottom' - places it at the upper left and lower right corners of the figure
%                           'outside' - places it at  the lower left corner, outside of the figure boundary
%         .color      : keyword string or numeric RBG value (see plot) specifying the color to use for the border
%         .text_color : keyword string or numeric RBG value specifying the color to use for the text
%
% Output:
%     (NONE)
%
% Prototype:
%     f1 = figure;
%     plot([0 1], [0 1], '.-b');
%     matspace.plotting.plot_classification(f1, 'U');
%     f2 = figure;
%     plot(0, 0);
%     matspace.plotting.plot_classification(f2, "S", caveat="//MADE UP CAVEAT", test=true, location="axis");
%     f3 = figure;
%     plot(0, 0);
%     matspace.plotting.plot_classification(f3, 'C', 'test', true, 'location', 'figure', 'color', 'm');
%
%     % clean up
%     close([f1 f2 f3]);
%
% See Also:
%     matspace.plotting.setup_plots
%
% Notes:
%     1.  This function is intended to be fairly low level, and is best called via a wrapper
%         function that would define the common defaults for your use case.
%     2.  'TS' is the normal portion marking for Top Secret, but 'T' will also be recognized.
%     3.  Repeated calls on the same figure will wipe out any previously added labels before applying the new ones
%     4.  Using an empty string for classification will remove any previously added labels.
%
% Change Log:
%     1.  Written by David C. Stauffer in Feb 2010.
%     2.  Updated by David C. Stauffer in Sep 2011 to not be effected by panning and zooming.
%     3.  Incorporated by David C. Stauffer into matspace library in Nov 2016.
%     4.  Updated by David C. Stauffer in March 2020 to include optional caveats.
%     5.  Updated by David C. Stauffer in April 2020 to remove old markers and handle variable sizes
%         of text better, and then wrapped into a package.
%     6.  Updated by David C. Stauffer in August 2023 to support arguments and custom colors.

% Arguments
arguments
    fig_hand (1, :) matlab.ui.Figure
    classification {mustBeMember(classification, ["", "U", "CUI" "C", "S", "T", "TS"])}
    kwargs.caveat  = ''
    kwargs.test (1,1) logical = false
    kwargs.location {mustBeMember(kwargs.location, ["figure", "axes", "axis", "left", "top", "top&bottom", "outside"])} = 'figure'
    kwargs.color {mustBeColor} = ''
    kwargs.text_color {mustBeColor} = ''
end

% force conversion to newer figure objects
if isnumeric(fig_hand)
    convert_figs = true;
    warning('matspace:Utils:OldNumericFigure', ['Figures passed to plot_classification ' ...
        'are in old format, will be converted from numeric to gobject.']);
else
    convert_figs = false;
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
    % plot warning before trying to draw the other box, so it's clear that this is not actually
    % a classified figure
    if kwargs.test
        height = 0.1; % Height matters, width does not because it's determined automatically by the textbox
        annotation(this_fig, 'textbox', 'Position', [pos(1)+pos(3)/2, pos(2)+pos(4)-height, 0, height], ...
            'String', 'This plot classification is labeled for test purposes only', ...
            'HorizontalAlignment', 'Center', 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
            'FontSize', 8, 'FontWeight', 'Bold', 'Color', 'r', 'EdgeColor', 'r', 'LineWidth', 2, ...
            'Tag', 'ClassificationTest');
    end
    % get classification default colors and strings
    switch classification
        case ''
            continue
        case 'U'
            color    = [0.023 0.277 0.047];  % roughly xkcd: forest green (#06470c)
            text_str = 'UNCLASSIFIED';
        case 'CUI'
            color    = [0.492 0.117 0.609];  % roughly xkcd: purple  (#7e1e9c)
            text_str = 'CUI';
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
    % allow other color options for certain caveats
    if contains(kwargs.caveat, '//FAKE COLOR')
        color      = [0.0 0.8 0.0];
        text_color = [0.2 0.2 0.2];
    end
    % allow user to override via arguments
    if ~isempty(kwargs.color)
        color = kwargs.color;
    end
    if ~isempty(kwargs.text_color)
        text_color = kwargs.text_color;
    end
    % determine size of box and append any optional caveat(s)
    height = 0.05;
    if ~isempty(kwargs.caveat)
        text_str = strcat(text_str, kwargs.caveat); % strcat handles both char arrays and string objects
    end
    % add classification box
    add_border = true;
    horz_align = 'Right';
    switch kwargs.location
        case {'axes', 'axis'}
            text_pos   = [pos(1)+pos(3), pos(2), 0, height];
            add_border = false;
        case {'figure', 'top&bottom'}
            text_pos   = [1, 0, 0, height];
        case 'left'
            text_pos   = [0, 0, 0, height];
            horz_align = 'Left';
        case 'top'
            text_pos   = [0, 1-height, 0, height];
            horz_align = 'Left';
        case 'outside'
            text_pos   = [1, -height/2, 0, height];
        otherwise
            error('matspace:BadClassLocation', 'Bad location given: "%s"', location);
    end
    annotation(this_fig, 'textbox', 'Position', text_pos, 'String', text_str, ...
        'HorizontalAlignment', horz_align, 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
        'FontSize', 8, 'FontWeight', 'Bold', 'Color', text_color, 'EdgeColor', color, ...
        'LineWidth', 2, 'Tag', 'ClassificationText');
    if strcmp(kwargs.location, 'top&bottom')
        % draw a second label at the second location
        text_pos2   = [0, 1-height, 0, height];
        horz_align2 = 'Left';
        annotation(this_fig, 'textbox', 'Position', text_pos2, 'String', text_str, ...
            'HorizontalAlignment', horz_align2, 'VerticalAlignment', 'Middle', 'FitBoxToText', 'on', ...
            'FontSize', 8, 'FontWeight', 'Bold', 'Color', text_color, 'EdgeColor', color, ...
            'LineWidth', 2, 'Tag', 'ClassificationText');
    end

    if add_border
        % Note: don't use a rectangle, as Matlab draws this on a scribe layer over the top of the figure,
        % and consequently you cannot grab and reposition things like legends after the fact.
        %annotation(this_fig, 'rectangle', 'Position', [0,0,1,1], 'Color', 'none', 'EdgeColor', color, ...
        %    'LineWidth', 2, 'Tag', 'ClassificationBorder');
        annotation(this_fig, 'line', [0 0], [0 1], 'Color', color, 'LineWidth', 2, 'Tag', 'ClassificationBorder');
        annotation(this_fig, 'line', [0 1], [1 1], 'Color', color, 'LineWidth', 2, 'Tag', 'ClassificationBorder');
        annotation(this_fig, 'line', [1 1], [1 0], 'Color', color, 'LineWidth', 2, 'Tag', 'ClassificationBorder');
        annotation(this_fig, 'line', [1 0], [0 0], 'Color', color, 'LineWidth', 2, 'Tag', 'ClassificationBorder');
    end
end


function [] = remove_old_classifications(this_fig)

% REMOVE_OLD_CLASSIFICATIONS  removes any pre-existing classification markings so that they can be
%                             replaced with new ones without clashing

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


function mustBeColor(x)
% validates the grouping options
if ischar(x)
    return
end
if isstring(x)
    if length(x) == 1
        return
    end
    eidType = 'ssc:plot_classification:badColor';
    msgType = 'Output must be single string colorname.';
    throwAsCaller(MException(eidType, msgType));
end
if ~isnumeric(x)
    eidType = 'ssc:plot_classification:badColor';
    msgType = 'Output must be a valid color, either a char, string or numeric value.';
    throwAsCaller(MException(eidType, msgType));
end