function [] = disp_xlimits(fig_or_axis, kwargs)

% Set the xlimits to the specified xmin and xmax.
% 
% Parameters
% ----------
% fig_or_axis : matlpotlib.pyplot.Axes or matplotlib.pyplot.Figure or list of them
%     List of figures/axes to process
% xmin : scalar
%     Minimum X value
% xmax : scalar
%     Maximum X value
% 
% Notes
% -----
% #.  Written by David C. Stauffer in August 2015.
% #.  Modified by David C. Stauffer in May 2020 to come out of setup_plots and into lower level
%     routines.
% 
% Examples
% --------
%     fig = figure(Name='Figure Title');
%     ax = axes(fig);
%     x = 0:0.1:10;
%     y = sin(x);
%     plot(ax, x, y);
%     title(ax, "X vs Y");
%     xmin = 2;
%     xmax = 5;
%     matspace.plotting.disp_xlimits(fig, xmin, xmax);
% 
% Close plot
%     close(fig)

arguments
    fig_or_axis
    kwargs.xmin (1, 1) {mustBeDoubleOrDatetime} = -inf;
    kwargs.xmax (1, 1) {mustBeDoubleOrDatetime} = inf;
end
xmin = kwargs.xmin;
xmax = kwargs.xmax;

% loop through items and collect axes
ax = gobjects(1, 0);
for i = 1:length(fig_or_axis)
    this = fig_or_axis(i);
    if isa(this, 'matlab.ui.Figure')
        axes = findall(this, 'type', 'axes');
        ax = [ax, axes]; %#ok<AGROW>
    elseif isa(this, 'matlab.graphics.axis.Axes')
        ax(end + 1) = this; %#ok<AGROW>
    else
        error('Unexpected item that is neither a figure nor axes.');
    end
end
% loop through axes
for i = 1:length(ax)
    this_axis = ax(i);
    % get xlimits for this axis
    %  this_axis.autoscale()
    xlims = xlim(this_axis);
    old_xmin = xlims(1);
    old_xmax = xlims(2);
    % set the new limits
    if ~isinf(xmin) && (isdatetime(xmin) && ~isnat(xmin))
        new_xmin = max([xmin, old_xmin]);
    else
        new_xmin = old_xmin;
    end
    if ~isinf(xmax) && (isdatetime(xmax) && ~isnat(xmax))
        new_xmax = min([xmax, old_xmax]);
    else
        new_xmax = old_xmax;
    end
    % check for bad conditions
    if isinf(new_xmin) || (isnumeric(new_xmin) && isnan(new_xmin)) || (isdatetime(new_xmin) && isnat(new_xmin))
        new_xmin = old_xmin;
    end
    if isinf(new_xmax) || (isnumeric(new_xmax) && isnan(new_xmax)) || (isdatetime(new_xmax) && isnat(new_xmax))
        new_xmax = old_xmax;
    end
    % modify xlimits
    xlim(this_axis, [new_xmin, new_xmax]);
end


%% Subfunctions - mustBeDoubleOrDatetime
function mustBeDoubleOrDatetime(x)

if ~isnumeric(x) && ~isdatetime(x)
    throwAsCaller(MException('matspace:plotting:BadTimeValue','Input must be numeric or datetime.'))
end