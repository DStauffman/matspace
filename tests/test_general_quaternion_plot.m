classdef test_general_quaternion_plot < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the general_difference_plot function with the following cases:
    %     TBD

    properties
        figs,
        description,
        time_one,
        time_two,
        quat_one,
        quat_two
        name_one,
        name_two,
        time_units,
        start_date,
        plot_components,
        rms_xmin,
        rms_xmax,
        disp_xmin,
        disp_xmax,
        fig_visible,
        make_subplots,
        single_lines,
        use_mean,
        plot_zero,
        show_rms,
        legend_loc,
        show_extra,
        truth_name,
        truth_time,
        truth_data,
        tolerance,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.description     = 'example';
            self.time_one        = 0:10;
            self.time_two        = 2:12;
            self.quat_one        = matspace.quaternions.quat_norm(rand(4,11));
            self.quat_two        = matspace.quaternions.quat_norm(self.quat_one(:, [3:11 1 2]) + 1e-5*rand(4,11));
            self.name_one        = 'test1';
            self.name_two        = 'test2';
            self.time_units      = 'sec';
            self.start_date      = ['  t(0) = ', datestr(now)];
            self.plot_components = true;
            self.rms_xmin        = 1;
            self.rms_xmax        = 10;
            self.disp_xmin       = -2;
            self.disp_xmax       = inf;
            self.fig_visible     = true;
            self.make_subplots   = true;
            self.single_lines    = false;
            self.use_mean        = false;
            self.plot_zero       = false;
            self.show_rms        = true;
            self.legend_loc      = 'Best';
            self.show_extra      = true;
            self.truth_name      = "Truth";
            self.truth_time      = [];
            self.truth_data      = [];
            self.tolerance       = 0;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.figs);
        end
    end

    methods (Test)
        function test_all_args(self)
            [figs, err] = matspace.plotting.general_quaternion_plot(self.description, self.time_one, ...
                self.time_two, self.quat_one, self.quat_two, 'NameOne', self.name_one, 'NameTwo', self.name_two, ...
                'TimeUnits', self.time_units, 'StartDate', self.start_date, 'RmsXmin', self.rms_xmin, ...
                'RmsXmax', self.rms_xmax, 'DispXmin', self.disp_xmin, 'DispXmax', self.disp_xmax, ...
                'PlotComp', self.plot_components, 'FigVisible', self.fig_visible, 'MakeSubplots', self.make_subplots, ...
                'SingleLines', self.single_lines, 'UseMean', self.use_mean, 'PlotZero', self.plot_zero, ...
                'ShowRms', self.show_rms, 'LegendLoc', self.legend_loc, 'ShowExtra', self.show_extra, ...
                'TruthName', self.truth_name, 'TruthTime', self.truth_time, 'TruthData', self.truth_data, ...
                'Tolerance', self.tolerance);
            self.figs = [self.figs, figs];
            self.verifyEqual(err.one, matspace.utils.nanrms(self.quat_one(:, 2:end), 2));
            self.verifyEqual(err.two, matspace.utils.nanrms(self.quat_two(:, 1:end-2), 2));
            [~, exp] = matspace.quaternions.quat_angle_diff(self.quat_one(:, 3:end), self.quat_two(:, 1:end-2));
            self.verifyEqual(err.diff, matspace.utils.nanrms(exp, 2));
        end
        
        function test_minimal_args(self)
            figs = matspace.plotting.general_quaternion_plot(self.description, self.time_one, zeros(1, 0), self.quat_one, zeros(4, 0));
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
            figs = matspace.plotting.general_quaternion_plot(self.description, time_one, time_two, ...
                self.quat_one, self.quat_two, 'NameOne', self.name_one, 'NameTwo', self.name_two, ...
                'TimeUnits', self.time_units, 'StartDate', self.start_date, 'RmsXmin', rms_xmin, ...
                'RmsXmax', rms_xmax, 'DispXmin', disp_xmin, 'DispXmax', disp_xmax, ...
                'PlotComp', self.plot_components, 'FigVisible', self.fig_visible, 'MakeSubplots', self.make_subplots, ...
                'SingleLines', self.single_lines, 'UseMean', self.use_mean, 'PlotZero', self.plot_zero, ...
                'ShowRms', self.show_rms, 'LegendLoc', self.legend_loc, 'ShowExtra', self.show_extra, ...
                'TruthName', self.truth_name, 'TruthTime', self.truth_time, 'TruthData', self.truth_data, ...
                'Tolerance', self.tolerance);
            self.figs = [self.figs, figs];
        end
    end
end