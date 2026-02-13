function [] = zoom_ylim(ax, time, data, kwargs)

% Zooms the Y-axis to the data for the given time bounds, with an optional pad.
%
% Input:
%     ax      : Figure axes
%     time    : (N, ) Time history
%     data    : (N, ) or (N, M) Data history
%     kwargs  :
%         TStart  : (scalar) Starting time to zoom data to
%         TFinal  : (scalar) Final time to zoom data to
%         channel : (scalar) |opt| Column within 2D data to look at
%         pad     : (scalar) Amount of pad, as a percentage of delta range, to show around the plot bounds
%         zoom    : str, Whether to zoom in only, or out only, or both, from {"in", "out", "both"}
%
% Output:
%     (None)
%
% Prototype:
%     fig = figure(Name='Figure Title');
%     ax = axes(fig);
%     time = 1:0.1:10;
%     data = time .^ 2;
%     plot(ax, time, data);
%     title(ax, "X vs Y");
%
%     % Zoom X-axis and show how Y doesn't rescale
%     t_start = 3;
%     t_final = 5.0001;
%     matspace.plotting.disp_xlimits(fig, t_start, t_final);
%
%     % Force Y-axis to rescale to data
%     matspace.plotting.zoom_ylim(ax, time, data, TStart=t_start, TFinal=t_final, pad=0);
%
%     % Close plot
%     close(fig);
%
% Notes:
%     1.  Written by David C. Stauffer in August 2019.

arguments
    ax (1, 1) matlab.graphics.axis.Axes
    time
    data
    kwargs.TStart (1, 1) {mustBeDoubleOrDatetime} = -inf
    kwargs.TFinal (1, 1) {mustBeDoubleOrDatetime} = inf
    kwargs.Channel (1, 1) double = 0
    kwargs.Pad (1, 1) double = 0.1
    kwargs.Zoom {mustBeTextScalar} = "both"
end

t_start = kwargs.TStart;
t_final = kwargs.TFinal;
channel = kwargs.Channel;
pad     = kwargs.Pad;
zoom    = kwargs.Zoom;

if isempty(time) && isempty(data) && isempty(findobj(ax, Type='line'))
    warning("No data found on plot, so nothing was zoomed.")
    return
end

% If not given, find time/data from the plot itself
if isempty(time)
    lines = findobj(ax, Type='line');
    for i = 1:length(lines)
        all_xdata = get(lines(i), 'XData');
        if i == 1
            time = all_xdata(:);
        else
            time = [time(:); all_xdata(:)];
        end
    end
end
if isempty(data)
    lines = findobj(ax, Type='line');
    for i = 1:length(lines)
        all_ydata = get(lines(i), 'YData');
        if i == 1
            data = all_ydata(:);
        else
            data = [data(:); all_ydata(:)];
        end
    end
end
% exit if the plotted data are not numeric
if ~isnumeric(data)
    return
end
% find the relevant time indices
ix_time = (time >= t_start) & (time <= t_final);
% exit if no data is in this time window
if ~any(ix_time)
    warning("No data matched the given time interval.");
    return
end
% pull out the minimums/maximums from the data
if channel == 0
    if isvector(data)
        this_ymin = min(data(ix_time));
        this_ymax = max(data(ix_time));
    else
        this_ymin = min(data(ix_time, :));
        this_ymax = max(data(ix_time, :));
    end
else
    this_ymin = min(data(ix_time, channel));
    this_ymax = max(data(ix_time, channel));
end
% optionally pad the bounds
if pad < 0.0
    error("The pad cannot be negative.");
end
if pad > 0.0
    delta = this_ymax - this_ymin;
    this_ymax = this_ymax + pad * delta;
    this_ymin = this_ymin - pad * delta;
end
% check for the case where the data is constant and the limits are the same
if this_ymin == this_ymax
    if this_ymin == 0
        % data is exactly zero, show from -1 to 1
        this_ymin = -1;
        this_ymax = 1;
    else
        % data is constant, pad by given amount or 10% if pad is zero
        if pad < 0.0
            pad= 0.1;
        end
        this_ymin = (1 - pad) * this_ymin;
        this_ymax = (1 + pad) * this_ymax;
        if this_ymin > this_ymax
            [this_ymax, this_ymin] = deal(this_ymin, this_ymax);
        end
    end
end
% get the current limits
temp_ylims = ylim(ax);
old_ymin = temp_ylims(1);
old_ymax = temp_ylims(2);
% compare the new bounds to the old ones and update as appropriate based on zoom option
switch zoom
    case "in"
        if this_ymin > old_ymin && isfinite(this_ymin)
            bottom = this_ymin;
        else
            bottom = nan;
        end
        if this_ymax < old_ymax && isfinite(this_ymax)
            top = this_ymax;
        else
            top = nan;
        end
    case "out"
        if this_ymin < old_ymin && isfinite(this_ymin)
            bottom = this_ymin;
        else
            bottom = nan;
        end
        if this_ymax > old_ymax && isfinite(this_ymax)
            top = this_ymax;
        else
            top = nan;
        end
    case "both"
        if this_ymin ~= old_ymin && isfinite(this_ymin)
            bottom = this_ymin;
        else
            bottom = nan;
        end
        if this_ymax ~= old_ymax && isfinite(this_ymax)
            top = this_ymax;
        else
            top = nan;
        end
    otherwise
        error('Unexpected value for zoom of "%s". Expect "in", "out", or "both".', zoom);
end
if ~isnan(bottom) || ~isnan(top)
    if isnan(bottom)
        bottom = old_ymin;
    end
    if isnan(top)
        top = old_ymax;
    end
    ylim(ax, [bottom, top]);
end


%% Subfunctions - mustBeDoubleOrDatetime
function mustBeDoubleOrDatetime(x)

if ~isnumeric(x) && ~isdatetime(x)
    throwAsCaller(MException('matspace:plotting:BadTimeValue','Input must be numeric or datetime.'))
end