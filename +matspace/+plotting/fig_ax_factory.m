function [fig_ax] = fig_ax_factory(kwargs)

% Creates the figures and axes for use in a given plotting function.
%
% Parameters
% ----------
% NumFigs : int
%     Number of figures to produce
% NumAxes : int or (int, int)
%     Total number of axes
% SupTitle : str
%     Title to put over all axes
% Layout : str
%     Axes layout, from {'rows', 'cols', 'rowwise', 'colwise'}
% ShareX : bool
%     Whether to share the X axis
% PassThrough : bool
%     Whether to include everything and return a tuple of None's with the correct length
% Visible : str
%     Whether the plot is visible or not, from {'on', 'off'}
%
% Notes
% -----
% #.  Written by David C. Stauffer in February 2022.
%
% Examples
% --------
%     fig_ax = matspace.plotting.fig_ax_factory();
%     fig = fig_ax{1}{1};
%     ax = fig_ax{1}{2};
%     assert(isa(fig, 'matlab.ui.Figure'));
%     assert(isa(ax, 'matlab.graphics.axis.Axes'));
%
% Close plot
%     close(fig);

arguments
    kwargs.NumFigs (1, 1) double = -1
    kwargs.NumAxes {mustBeOneOrTwo} = 1
    kwargs.SupTitle {mustBeTextScalar} = ''
    kwargs.Layout {mustBeMember(kwargs.Layout, ["rows", "cols", "rowwise", "colwise"])} = 'rows'
    kwargs.ShareX (1, 1) logical = true
    kwargs.PassThrough (1, 1) logical = false
    kwargs.Visible {mustBeMember(kwargs.Visible, ["on", "off"])} = 'on'
end
num_figs    = kwargs.NumFigs;
num_axes    = kwargs.NumAxes;
suptitle    = kwargs.SupTitle;
layout      = kwargs.Layout;
sharex      = kwargs.ShareX;
passthrough = kwargs.PassThrough;
fig_visible = kwargs.Visible;

if isscalar(num_axes)
    is_1d = true;
    if strcmp(layout, 'rows')
        num_row = num_axes;
        num_col = 1;
    elseif strcmp(layout, 'cols')
        num_row = 1;
        num_col = num_axes;
    else
        error('Unexpected layout: "%s".', layout);
    end
else
    is_1d = false;
    if ~any(strcmp(layout, ["rowwise", "colwise"]))
        error('Unexpected layout: "%s".', layout);
    end
    assert(length(num_axes) == 2, "Expected a tuple with exactly two elements.");
    num_row = num_axes(1);
    num_col = num_axes(2);
end
if num_figs == -1
    num_figs = 1;
end
if passthrough
    fig_ax = cell(1, num_figs * num_row * num_col);
    return
end
figs = gobjects(1, 0);
axes = cell(1, 0);
for f = 1:num_figs
    fig = figure(Visible=fig_visible);
    ax = gobjects(1, num_row * num_col);
    c = 1;
    for i = 1:num_row
        for j = 1:num_col
            ax(c) = subplot(num_row, num_col, c);
            hold(ax(c), 'on');
            c = c + 1;
        end
    end
    if sharex
        linkaxes(ax, 'x');
    end
    if ~isempty(suptitle)
        if iscell(suptitle)
            this_title = suptitle{1};
        else
            this_title = suptitle;
        end
        sgtitle(fig, this_title);
        fig.Name = this_title;
    end
    figs(end + 1) = fig; %#ok<AGROW>
    axes{end + 1} = ax; %#ok<AGROW>
end
if is_1d
    assert(isscalar(num_axes));
    if num_axes == 1
        fig_ax = cell(1, num_figs);
        for f = 1:num_figs
            fig_ax{f} = {figs(f), axes{f}};
        end
    else
        fig_ax = cell(1, num_figs * num_axes);
        c = 1;
        for f = 1:num_figs
            for i = 1:num_axes
                fig_ax{c} = {figs(f), axes{f}(i)};
                c = c + 1;
            end
        end
    end
elseif layout == "rowwise"
    fig_ax = cell(1, num_figs * num_row * num_col);
    c = 1;
    for f = 1:num_figs
        for i = 1:num_row
            for j = 1:num_col
                fig_ax{c} = {figs(f), axes{f}(sub2ind(num_axes, i, j))};
                c = c + 1;
            end
        end
    end
elseif layout == "colwise"
    fig_ax = cell(1, num_figs * num_row * num_col);
    c = 1;
    for f = 1:num_figs
        for j = 1:num_col
            for i = 1:num_row
                fig_ax{c} = {figs(f), axes{f}(sub2ind(num_axes, i, j))};
                c = c + 1;
            end
        end
    end
end


%% Subfunctions - mustBeDoubleOrDatetime
function mustBeOneOrTwo(x)

if ~isscalar(x) && (isvector(x) && length(x) ~= 2)
    throwAsCaller(MException('matspace:plotting:BadVecLength','Input must be exactly one or two elements.'))
end