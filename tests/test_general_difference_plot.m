classdef test_general_difference_plot < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the general_difference_plot function with the following cases:
    %     TBD

    properties
        figs,
        description,
        time_one,
        time_two,
        data_one,
        data_two
        name_one,
        name_two,
        elements,
        units,
        time_units,
        leg_scale,
        start_date,
        plot_components,
        rms_xmin,
        rms_xmax,
        disp_xmin,
        disp_xmax,
        fig_visible,
        make_subplots,
        single_lines,
        color_list,
        colororder,
        use_mean,
        plot_zero,
        show_rms,
        legend_loc,
        show_extra,
        second_y_scale,
        y_label,
        truth_name,
        truth_time,
        truth_data,
        tolerance,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.description    = 'example';
            self.time_one       = 0:10;
            self.time_two       = 2:12;
            self.data_one       = rand(2,11)*1e-6;
            self.data_two       = self.data_one(:,[3:11 1 2]) - 0.5e-7*rand(2,11);
            self.name_one       = 'test1';
            self.name_two       = 'test2';
            self.elements       = {'x','y'};
            self.units          = 'rad';
            self.time_units     = 'sec';
            self.leg_scale      = 'micro';
            self.start_date     = ['  t(0) = ', datestr(now)];
            self.rms_xmin       = 1;
            self.rms_xmax       = 10;
            self.disp_xmin      = -2;
            self.disp_xmax      = inf;
            self.fig_visible    = true;
            self.make_subplots  = true;
            self.single_lines   = false;
            color_lists    = matspace.plotting.get_color_lists();
            self.colororder     = [cell2mat(color_lists.dbl_diff); cell2mat(color_lists.two)];
            self.use_mean       = false;
            self.plot_zero      = false;
            self.show_rms       = true;
            self.legend_loc     = 'Best';
            self.show_extra     = true;
            self.second_y_scale = nan;
            self.y_label        = 'Value [rad]';
            self.truth_name     = "Truth";
            self.truth_time     = [];
            self.truth_data     = [];
            self.tolerance      = 0;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.figs);
        end
    end

    methods (Test)
        function test_all_args(self)
            [figs, err] = matspace.plotting.general_difference_plot(self.description, self.time_one, ...
                self.time_two, self.data_one, self.data_two, 'NameOne', self.name_one, 'NameTwo', self.name_two, ...
                'Elements', self.elements, 'Units', self.units, 'TimeUnits', self.time_units, ...
                'LegendScale', self.leg_scale, 'StartDate', self.start_date, 'RmsXmin', self.rms_xmin, ...
                'RmsXmax', self.rms_xmax, 'DispXmin', self.disp_xmin, 'DispXmax', self.disp_xmax, ...
                'FigVisible', self.fig_visible, 'MakeSubplots', self.make_subplots, 'SingleLines', self.single_lines, ...
                'ColorOrder', self.colororder, 'UseMean', self.use_mean, 'PlotZero', self.plot_zero, ...
                'ShowRms', self.show_rms, 'LegendLoc', self.legend_loc, 'ShowExtra', self.show_extra, ...
                'SecondYScale', self.second_y_scale, 'YLabel', self.y_label, 'TruthName', self.truth_name, ...
                'TruthTime', self.truth_time, 'TruthData', self.truth_data, 'Tolerance', self.tolerance);
            self.figs = [self.figs, figs];
            % verify err?
        end

        function test_minimal_args(self)
            figs = matspace.plotting.general_difference_plot(self.description, self.time_one, zeros(1,0), ...
                self.data_one, zeros(size(self.data_one, 1), 0));
            self.figs = [self.figs, figs];
        end

        function test_datetime(self)
            date_zero = datetime('now');
            dt        = duration(0, 1, 0); % 1 minute
            time_one  = date_zero + dt * self.time_one;
            time_two  = date_zero + dt * self.time_two;
            rms_xmin       = date_zero + 1*dt;
            rms_xmax       = date_zero + 10*dt;
            disp_xmin      = date_zero - 2*dt;
            disp_xmax      = NaT;
            figs = matspace.plotting.general_difference_plot(self.description, time_one, time_two, ...
                self.data_one, self.data_two, 'NameOne', self.name_one, 'NameTwo', self.name_two, ...
                'Elements', self.elements, 'Units', self.units, 'TimeUnits', self.time_units, ...
                'LegendScale', self.leg_scale, 'StartDate', self.start_date, 'RmsXmin', rms_xmin, ...
                'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
                'FigVisible', self.fig_visible, 'MakeSubplots', self.make_subplots, 'SingleLines', self.single_lines, ...
                'ColorOrder', self.colororder, 'UseMean', self.use_mean, 'PlotZero', self.plot_zero, ...
                'ShowRms', self.show_rms, 'LegendLoc', self.legend_loc, 'ShowExtra', self.show_extra, ...
                'SecondYScale', self.second_y_scale, 'YLabel', self.y_label, 'TruthName', self.truth_name, ...
                'TruthTime', self.truth_time, 'TruthData', self.truth_data, 'Tolerance', self.tolerance);
            self.figs = [self.figs, figs];
        end
    end
end