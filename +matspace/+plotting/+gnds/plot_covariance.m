function [fig_hand, err] = plot_covariance(kf1, kf2, varargin)

% Plots the Kalman Filter square root diagonal variance value.
% 
% Input:
% kf1 : class Kf
%     Kalman filter output
% kf2 : class Kf, optional
%     Second filter output for potential comparison
% truth : class Kf, optional
%     Third filter output that is considered truth
% opts : class Opts, optional
%     Plotting options
% skip_setup_plots : bool, optional, default is False
%     Whether to skip the setup_plots step
% groups : iterable of ints
%     How to group plots based on state numbers
% fields : dict[str, str], optional
%     Fields to plot, default is covar and Covariance
% **kwargs : dict
%     Additional keyword arguments to override plotting options or pass to lower level plot function
%
% Output:
% fig_hand : list of class matplotlib.figure.Figure
%     Figure handles
% err : dict
%     Numerical outputs of comparison
%
% Prototype:
%     num_points = 11;
%     num_states = 6;
%
%     kf1        = [];  % Kf();
%     kf1.name   = 'KF1';
%     kf1.time   = 1:num_points;
%     kf1.covar  = 1e-6 * zeros(num_states, num_points);
%     kf1.active = [1, 2, 3, 4, 8, 12];
%
%     kf2        = [];  % Kf();
%     kf2.name   = 'KF2';
%     kf2.time   = kf1.time;
%     kf2.covar  = kf1.covar + 1e-9 * rand(size(kf1.covar));
%     kf2.active = kf1.active;
%
%     opts = matspace.plotting.Opts();
%     opts.case_name = 'test_plot';
%     opts.sub_plots = true;
%     groups = {1:3, 4:4:32};
% 
%     fig_hand = matspace.plotting.gnds.plot_covariance(kf1, kf2, Opts=opts, Groups=groups);
% 
%     % Close plots
%     close(fig_hand);
%
% Change Log:
%     1.  Written by David C. Stauffer in February 2026.

%% Imports
import matspace.plotting.colors.get_nondeg_colorlists
import matspace.plotting.gnds.minimize_names
import matspace.plotting.make_difference_plot
import matspace.plotting.Opts
import matspace.plotting.private.fun_is_bool
import matspace.plotting.private.fun_is_dict
import matspace.plotting.private.fun_is_gnd
import matspace.plotting.private.fun_is_groups
import matspace.plotting.private.fun_is_log_level
import matspace.plotting.private.fun_is_opts
import matspace.plotting.private.kwargs_pop
import matspace.plotting.setup_plots

%% Parser
% Argument parser
p = inputParser;
p.KeepUnmatched = true;
addRequired(p, 'Kf1', @fun_is_gnd);
addRequired(p, 'Kf2', @fun_is_gnd);
addParameter(p, 'Opts', Opts(), @fun_is_opts);
addParameter(p, 'Truth', [], @fun_is_gnd);
addParameter(p, 'SkipSetupPlots', false, @fun_is_bool);
addParameter(p, 'Groups', [], @fun_is_groups);
addParameter(p, 'Fields', '', @fun_is_dict);
addParameter(p, 'LogLevel', 10, @fun_is_log_level);
% do parse
parse(p, kf1, kf2, varargin{:});
% create some convenient aliases
opts             = p.Results.Opts;
truth            = p.Results.Truth;  %#ok<NASGU> - Allowed to keep API consistent
skip_setup_plots = p.Results.SkipSetupPlots;
groups           = p.Results.Groups;
fields           = p.Results.Fields;
log_level        = p.Results.LogLevel;
unmatched        = p.Unmatched;

% check optional inputs
if isempty(kf1)
    kf1 = struct('time', []);  % Kf();
end
if isempty(kf2)
    kf2 = struct('time', []);  % Kf();
end
if isempty(fields)
    fields = dictionary('covar', 'Covariance');
end

% TODO: allow different sets of states in the different structures

% aliases and defaults
num_chan = 0;
all_keys = keys(fields);
for i = 1:length(all_keys)
    key = all_keys{i};
    if isfield(kf1, key) && ~isempty(kf1.(key))
        temp = size(kf1.(key), 1);
    elseif isfield(kf2, key) && ~isempty(kf2.(key))
        temp = size(kf2.(key), 1);
    else
        temp = 0;
    end
    num_chan = max([num_chan temp]);
end
if isfield(kf1, 'chan') && ~isempty(kf1.chan)
    elements = kf1.chan;
elseif isfield(kf2, 'chan') && ~isempty(kf2.chan)
    elements = kf2.chan;
else
    elements = "Channel " + string(1:num_chan);
end
[elements,     unmatched] = kwargs_pop(unmatched, 'Elements', elements);
[units,        unmatched] = kwargs_pop(unmatched, 'Units', 'mixed');
[second_units, unmatched] = kwargs_pop(unmatched, 'SecondUnits', 'micro');
if isempty(groups)
    groups = num2cell(1:num_chan);
end

% determine if converting units
is_date_1 = isdatetime(kf1.time);
is_date_2 = isdatetime(kf2.time);
is_date_o = strcmp(opts.time_unit, "datetime");

% make local copy of opts that can be modified without changing the original
this_opts = Opts(opts);
% allow opts to convert as necessary
if is_date_1 || (is_date_2 && ~is_date_o)
    this_opts = this_opts.convert_dates('datetime');
elseif is_date_o && ~is_date_1 && ~is_date_2
    this_opts = this_opts.convert_dates('sec');
end
% opts overrides
[this_opts.case_name, unmatched] = kwargs_pop(unmatched, 'CaseName', this_opts.case_name);
[this_opts.save_plot, unmatched] = kwargs_pop(unmatched, 'SavePlot', this_opts.save_plot);
[this_opts.save_path, unmatched] = kwargs_pop(unmatched, 'save_path', this_opts.save_path);
[this_opts.classify,  unmatched] = kwargs_pop(unmatched, 'classify', this_opts.classify);

% alias opts
[time_units,   unmatched] = kwargs_pop(unmatched, 'TimeUnits', this_opts.time_base);
[start_date,   unmatched] = kwargs_pop(unmatched, 'StartDate', this_opts.get_date_zero_str());
[rms_xmin,     unmatched] = kwargs_pop(unmatched, 'RmsXmin', this_opts.rms_xmin);
[rms_xmax,     unmatched] = kwargs_pop(unmatched, 'RmsXmax', this_opts.rms_xmax);
[disp_xmin,    unmatched] = kwargs_pop(unmatched, 'DispXmin', this_opts.disp_xmin);
[disp_xmax,    unmatched] = kwargs_pop(unmatched, 'DispXmax', this_opts.disp_xmax);
[sub_plots,    unmatched] = kwargs_pop(unmatched, 'MakeSubplots', this_opts.sub_plots);
[single_lines, unmatched] = kwargs_pop(unmatched, 'SingleLines', this_opts.sing_line);
[use_mean,     unmatched] = kwargs_pop(unmatched, 'UseMean', this_opts.use_mean);
[lab_vert,     unmatched] = kwargs_pop(unmatched, 'LabelVertLines', this_opts.lab_vert);
[plot_zero,    unmatched] = kwargs_pop(unmatched, 'PlotZero', this_opts.show_zero);
[show_rms,     unmatched] = kwargs_pop(unmatched, 'ShowRms', this_opts.show_rms);
[legend_loc,   unmatched] = kwargs_pop(unmatched, 'LegendLoc', this_opts.leg_spot);
[show_extra,   unmatched] = kwargs_pop(unmatched, 'ShowExtra', this_opts.show_xtra);
[fig_visible,  unmatched] = kwargs_pop(unmatched, 'FigVisible', this_opts.show_plot);
[name_one,     unmatched] = kwargs_pop(unmatched, 'NameOne', '');
[name_two,     unmatched] = kwargs_pop(unmatched, 'NameTwo', '');
[name_one, name_two] = this_opts.get_name_one_and_two(NameOne=name_one, NameTwo=name_two);

% initialize outputs
fig_hand = gobjects(1, 0);
err = [];

% call wrapper functions for most of the details
all_keys = keys(fields);
for k = 1:length(all_keys)
    field = all_keys{k};
    description = fields(field);
    if log_level >= 4
        fprintf(1, 'Plotting %s plots ...\n', description);
    end
    err.(field) = dictionary();
    for ix = 1:length(groups)
        states = groups{ix};
        if ischar(units) || (isstring(units) && isscalar(units))
            this_units = units;
        else
            this_units = units{ix};
        end
        if (isstring(second_units) && length(second_units) > 1) || (~isstring(second_units) && ~ischar(second_units) && isvector(second_units))
            this_2units = second_units{ix};
        else
            this_2units = second_units;
        end
        this_ylabel = [char(description),' [',char(this_units),']'];
        if isfield(kf1, 'active') && ~isempty(kf1.active)
            [this_state_nums1, this_state_rows1, found_rows1] = intersect(kf1.active, states);
        else
            this_state_nums1 = [];
        end
        if isfield(kf2, 'active') && ~isempty(kf2.active)
            [this_state_nums2, this_state_rows2, found_rows2] = intersect(kf2.active, states);
        else
            this_state_nums2 = [];
        end
        this_state_nums = union(this_state_nums1, this_state_nums2);
        if isfield(kf1, field) && ~isempty(this_state_nums1)
            data_one = kf1.(field)(this_state_rows1, :);
        else
            data_one = [];
        end
        if isfield(kf2, field) && ~isempty(this_state_nums2)
            data_two = kf2.(field)(this_state_rows2, :);
        else
            data_two = [];
        end
        have_data1 = ~isempty(data_one) && any(~isnan(data_one), 'all');
        have_data2 = ~isempty(data_two) && any(~isnan(data_two), 'all');
        if have_data1 && numel(this_state_nums1) < numel(this_state_nums)
            temp = nan(numel(this_state_nums), size(data_one, 2));
            temp(found_rows1, :) = data_one;
            data_one = temp;
        end
        if have_data2 && numel(this_state_nums2) < numel(this_state_nums)
            temp = nan(numel(this_state_nums), size(data_two, 2));
            temp(found_rows2, :) = data_two;
            data_two = temp;
        end
        if have_data1 || have_data2
            if isempty(elements)
                state_names = string(this_state_nums);
                this_elements = [];
                colormap = [];
            else
                state_names = elements;
                this_elements = elements(this_state_nums);
                colormap = get_nondeg_colorlists(length(this_elements));
            end
            this_description = description + " for State " + minimize_names(state_names);
            unmatched_args = namedargs2cell(unmatched);
            [out_figs, out_err] = make_difference_plot(...
                this_description, ...
                kf1.time, ...
                data_one, ...
                kf2.time, ...
                data_two, ...
                unmatched_args{:}, ...
                NameOne=name_one, ...
                NameTwo=name_two, ...
                Elements=this_elements, ...
                Units=this_units, ...
                TimeUnits=time_units, ...
                StartDate=start_date, ...
                RmsXmin=rms_xmin, ...
                RmsXmax=rms_xmax, ...
                DispXmin=disp_xmin, ...
                DispXmax=disp_xmax, ...
                MakeSubplots=sub_plots, ...
                UseMean=use_mean, ...
                LabelVertLines=lab_vert, ...
                PlotZero=plot_zero, ...
                ShowRms=show_rms, ...
                SingleLines=single_lines, ...
                LegendLoc=legend_loc, ...
                ShowExtra=show_extra, ...
                SecondUnits=this_2units, ...
                YLabel=this_ylabel, ...
                ColorMap=colormap,...
                FigVisible=fig_visible);
            fig_hand = [fig_hand, out_figs]; %#ok<AGROW>
            err.(field){['Group ',num2str(ix)]} = out_err;
        end
    end
    if log_level >= 4
        fprintf(1, "... done.\n");
    end
end

% Setup plots
if ~skip_setup_plots
    setup_plots(fig_hand, this_opts);
end
if isempty(fig_hand) && log_level >= 5
    msg = "No " + strjoin(values(fields),"/") + " data was provided, so no plots were generated.";
    fprintf(1, '%s\n', msg);
end