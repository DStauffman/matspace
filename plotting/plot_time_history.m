function [fig_hand] = plot_time_history(time1, data1, OPTS, varargin)

% PLOT_TIME_HISTORY  acts as a convenient wrapper to plotting a time history of some data.
%
% Summary:
%     This function can take in one or two time histories, with an optional description and unit
%     type associated with them.  If given two histories, it will find the overlapping points and
%     plot a difference between them.
%
% Input:
%     time1 ..... : (1xN) time points [years]
%     data1 ..... : (MxN) data points [num]
%     OPTS ...... : (class) optional plotting commands, see Opts.m for more information
%     varargin .. : (char, value) pairs for other options, from:
%                       'Time2'       : time points for series two, default is empty
%                       'Data2'       : data points for series two, default is empty
%                       'Description' : text to put on the plot titles, default is empty string
%                       'Type'        : type of data to use when converting axis scale, default is 'unity'
%                       'TruthTime'   : time points for truth data, default is empty
%                       'TruthData'   : data points for truth data, default is empty
%
% Output:
%     fig_hand .. : (scalar) figure handles [num]
%
% Prototype:
%     time   = 1:10;
%     data   = rand(5,length(time));
%     plot_time_history(time, data, [], 'Description', 'Random Data');
%
% See Also:
%     (None)
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.

%% hard-coded values and defaults
std_flag    = 1;
data_dim    = 1;
leg_format  = '%3.3f';
colors      = [0 0 1;0 0.8 0; 1 0 0; 0 0.8 0.8; 0.8 0 0.8; 0.8 0.8 0; 0 1 1; 1 0 1; 1 0.8 0; 0.375 0.375 0.5];
truth_color = [0 0 0];
% defaults, replaceable through varargin
time2       = [];
data2       = [];
description = '';
type        = 'unity';
truth_time  = [];
truth_data  = [];

%% Check for optional inputs
n = nargin;
switch n
    case {0, 1}
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
    case 2
        OPTS = Opts();
    otherwise
        % nop
end
if isempty(OPTS)
    OPTS = Opts();
end

%% Parse varargin
if n > 3
    if mod(n, 2) ~= 1
        error('dstauffman:UnexpectedNameValuePair', 'Expecting an even set of Name-Value pairs.');
    end
    for i=1:2:length(varargin)
        this_name  = varargin{i};
        this_value = varargin{i+1};
        switch lower(this_name)
            case 'time2'
                time2       = this_value;
            case 'data2'
                data2       = this_value;
            case 'description'
                description = this_value;
            case 'type'
                type        = this_value;
            case 'truthtime'
                truth_time  = this_value;
            case 'truthdata'
                truth_data  = this_value;
            otherwise
                error('dstauffman:UnexpectedNameValuePair', 'Unexpected Name of "%s".', this_name);
        end
    end
end

%% determine units based on type of data
% TODO: functionalize this?
switch type
    case 'unity'
        scale = 1;
        units = '';
    case 'population'
        scale = 1;
        units = '#';
    case 'percentage'
        scale = 100;
        units = '%';
    case 'per 100K'
        scale = 100000;
        units = 'per 100,000';
    case 'cost'
        scale = 1e-3;
        units = '$K''s';
    otherwise
        error('hesat:badPlottingType', 'Unknown data type for plot: "%s".', type);
end

%% Process for comparisons
% check for multiple comparisons mode
if iscell(OPTS.name_one)
    mult_comp_mode = true;
else
    mult_comp_mode = false;
end

% determine if creating a difference plot and/or using subplots
non_deg       = ~isempty(data1) && ~isempty(data2);
use_sub_plots = OPTS.sub_plots && non_deg;

% alias some OPTS information
if ~isempty(OPTS.name_one)
    temp  = OPTS.name_one;
else
    temp  = inputname(1);
end
if ~isempty(temp)
    if ~mult_comp_mode
        name1 = [temp,': '];
    end
else
    name1 = '';
end
if ~isempty(OPTS.name_two)
    temp  = OPTS.name_two;
else
    temp  = inputname(2);
end
if ~isempty(temp)
    name2 = [temp,': '];
else
    name2 = '';
end

%% calculate RMS indices
ix_rms_xmin1 = find(time1>=OPTS.rms_xmin,1,'first');
if isempty(ix_rms_xmin1)
    ix_rms_xmin1 = 1;
end
ix_rms_xmax1 = find(time1<=OPTS.rms_xmax,1,'last');
if isempty(ix_rms_xmax1)
    ix_rms_xmax1 = length(time1);
end
ix_rms_xmin2 = find(time2>=OPTS.rms_xmin,1,'first');
if isempty(ix_rms_xmin2)
    ix_rms_xmin2 = 1;
end
ix_rms_xmax2 = find(time2<=OPTS.rms_xmax,1,'last');
if isempty(ix_rms_xmax2)
    ix_rms_xmax2 = length(time2);
end

%% process non-deg data before trying to create any plots
if non_deg
    [nondeg_time,ix1,ix2]  = intersect(time1,time2);
    nondeg_data            = mean(data2(:,ix2),1) - mean(data1(:,ix1),1);
    ix_rms_xmin_nondeg     = find(nondeg_time>=OPTS.rms_xmin,1,'first');
    if isempty(ix_rms_xmin_nondeg)
        ix_rms_xmin_nondeg = 1;
    end
    ix_rms_xmax_nondeg     = find(nondeg_time<=OPTS.rms_xmax,1,'last');
    if isempty(ix_rms_xmax_nondeg)
        ix_rms_xmax_nondeg = length(nondeg_time);
    end
    nondeg_rms             = scale*rms(nondeg_data(:,ix_rms_xmin_nondeg:ix_rms_xmax_nondeg));
    if use_sub_plots
        fig_hand           = 0;
    else
        fig_hand           = [0 0];
    end
else
    fig_hand               = 0;
end

%% Plot data
% create figure
fig_hand(1) = figure('name',[description,' vs. Time']);

% set colororder
set(fig_hand(1),'DefaultAxesColorOrder',colors);

% get axes
if use_sub_plots
    ax1 = subplot(2,1,1);
else
    ax1 = axes;
end

% set hold on
hold on;

% plot data
if size(data1,data_dim) == 1
    % plot data
    h1        = plot(ax1,time1,scale*data1,'b.-');
    % calculate RMS for legend
    rms_data1 = scale*rms(data1(:,ix_rms_xmin1:ix_rms_xmax1));
else
    if ~mult_comp_mode
        % plot different cycles
        plot(ax1,time1,scale*data1,'-','Color',[0.7 0.7 0.7]);
        % plot the error bars
        temp      = scale*mean(data1,data_dim);
        errorbar(ax1,time1,temp,scale*std(data1,std_flag,data_dim),'c.-');
        % plot the mean results
        h1        = plot(ax1,time1,temp,'b.-');
        % calculate RMS for legend
        rms_data1 = rms(temp);
    else
        h1        = plot(ax1,time1,scale*data1,'.-');
        % calculate RMS for legend
        rms_data1 = rms(scale*data1,2);
    end
end
if size(data2,data_dim) == 1
    h2        = plot(ax1,time2,scale*data2,'.-','Color',[0 0.8 0]);
    rms_data2 = scale*rms(data2(:,ix_rms_xmin2:ix_rms_xmax2));
else
    plot(ax1,time2,scale*data2,'-','Color',[0.7 0.7 0.7]);
    temp      = scale*mean(data2,data_dim);
    errorbar(time2,temp,scale*std(data2,std_flag,data_dim),'g.-');
    h2        = plot(ax1,time2,temp,'.-','Color',[0 0.8 0]);
    rms_data2 = rms(temp);
end

% label plot
title(get(fig_hand(1),'name'));
xlabel('Time [year]');
ylabel([description,' [',units,']']);

% set display limits
xl = xlim;
if isfinite(OPTS.disp_xmin)
    xl(1) = max([xl(1),OPTS.disp_xmin]);
end
if isfinite(OPTS.disp_xmax)
    xl(2) = min([xl(2),OPTS.disp_xmax]);
end
xlim(xl);

% optionally plot truth for HIV prevalence
if strcmp(description,'HIV Prevalence') && ~all(isnan(truth_data))
    h3 = plot(truth_time,truth_data,'.','Color',truth_color,'MarkerFaceColor',truth_color,'DisplayName','Truth');
else
    h3 = [];
end

% turn on grid/legend
grid on;
if ~mult_comp_mode
    plot_handles = {h1,h2,h3};
    legend_names = {[name1,description,' (RMS: ',num2str(rms_data1,leg_format),')'],[name2,description,' (RMS: ',num2str(rms_data2,leg_format),')'],'Truth'};
    used_ix      = ~cellfun(@isempty,plot_handles);
    legend([plot_handles{used_ix}],legend_names(used_ix),'interpreter','none');
else
    plot_handles = [num2cell(h1(:)') {h3}];
    legend_names = [cellfun(@(x,y) [x,' (RMS: ',num2str(y,leg_format),')'],OPTS.name_one,num2cell(rms_data1(:)'),'UniformOutput',false),{'Truth'}];
    used_ix      = ~cellfun(@isempty,plot_handles);
    legend([plot_handles{used_ix}],legend_names(used_ix),'interpreter','none');
end

% plot RMS lines
plot_rms_lines(time1([ix_rms_xmin1 ix_rms_xmax1]),ylim);

% create differences plot
if non_deg
    title_name = [description,' Differences vs. Time'];
    if use_sub_plots
        ax2 = subplot(2,1,2);
        hold on;
        title(title_name);
    else
        fig_hand(2) = figure('name',title_name);
        ax2 = axes;
        hold on;
        title(title_name);
    end
    h3 = plot(ax2,nondeg_time,scale*nondeg_data,'r.-');
    
    % label plot
    xlabel('Time [year]');
    ylabel([description,' [',units,']']);

    % turn on grid/legend
    legend(h3,[description,' Difference (RMS: ',num2str(nondeg_rms,leg_format),')']);
    grid on;
    
    % plot RMS lines
    plot_rms_lines(time1([ix_rms_xmin1 ix_rms_xmax1]),ylim);
    
    % link to earlier plot
    linkaxes([ax1 ax2],'x');
end

% create figure controls
figmenu;

% setup plots
setup_plots(fig_hand,OPTS,'time');