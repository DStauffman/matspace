classdef test_make_time_plot < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the make_time_plot function with the following cases:
    %     TBD

    properties
        fig,
        description,
        time,
        data,
        name,
        elements,
        units,
        time_units,
        start_date,
        rms_xmin,
        rms_xmax,
        disp_xmin,
        disp_xmax,
        fig_visible,
        single_lines,
        color_map,
        use_mean,
        plot_zero,
        show_rms,
        legend_loc,
        second_units,
        legend_scale,
        ylabel,
        data_as_rows,
        extra_plotter,
        use_zoh,
        label_vert_lines,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.description      = 'Values vs Time';
            self.time             = 0:0.1:10;
            self.data             = self.time + cos(self.time);
            self.name             = '';
            self.elements         = strings(1, 0);
            self.units            = '';
            self.time_units       = 'sec';
            self.start_date       = '';
            self.rms_xmin         = -inf;
            self.rms_xmax         = inf;
            self.disp_xmin        = -inf;
            self.disp_xmax        = inf;
            self.single_lines     = false;
            color_lists           = matspace.plotting.colors.get_color_lists();
            self.color_map        = color_lists.dbl_diff;
            self.use_mean         = false;
            self.plot_zero        = false;
            self.show_rms         = true;
            self.legend_loc       = 'best';
            self.second_units     = '';
            self.legend_scale     = '';
            self.ylabel           = '';
            self.data_as_rows     = true;
            self.extra_plotter    = [];
            self.use_zoh          = false;
            self.label_vert_lines = true;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_simple(self)
            self.fig = matspace.plotting.make_time_plot(self.description, self.time, self.data);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_nominal(self)
            self.fig = matspace.plotting.make_time_plot(...
                self.description, ...
                self.time, ...
                self.data, ...
                Name=self.name, ...
                Elements=self.elements, ...
                Units=self.units, ...
                TimeUnits=self.time_units, ...
                StartDate=self.start_date, ...
                RmsXmin=self.rms_xmin, ...
                RmsXmax=self.rms_xmax, ...
                DispXmin=self.disp_xmin, ...
                DispXmax=self.disp_xmax, ...
                SingleLines=self.single_lines, ...
                ColorMap=self.color_map, ...
                UseMean=self.use_mean, ...
                PlotZero=self.plot_zero, ...
                ShowRms=self.show_rms, ...
                LegendLoc=self.legend_loc, ...
                SecondUnits=self.second_units, ...
                LegendScale=self.legend_scale, ...
                YLabel=self.ylabel, ...
                DataAsRows=self.data_as_rows, ...
                ExtraPlotter=self.extra_plotter, ...
                UseZoh=self.use_zoh, ...
                LabelVertLines=self.label_vert_lines ...
            );
            self.verifyEqual(length(self.fig), 1);
        end

        function test_scalars(self)
            self.fig = matspace.plotting.make_time_plot('', 0, 0);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_0d(self)
            self.fig = matspace.plotting.make_time_plot('', 5, 10.0);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_list1(self)
            data = {self.data, self.data + 0.5, self.data + 1.0};
            self.fig = matspace.plotting.make_time_plot(self.description, self.time, data);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_list2(self)
            time = {self.time, self.time(1:end-1)};
            data = {self.data, 2 * self.data(1:end-1)};
            self.fig = matspace.plotting.make_time_plot(self.description, time, data);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_row_vectors(self)
            data = [self.data; sin(self.time)];
            self.fig = matspace.plotting.make_time_plot(self.description, self.time, data);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_col_vectors(self)
            data = [self.data', sin(self.time)'];
            self.fig = matspace.plotting.make_time_plot(self.description, self.time, data, DataAsRows=false);
            self.verifyEqual(length(self.fig), 1);
        end

        function test_datetimes(self)
            time = datetime("2021-06-01T00:00:00") + seconds(self.time);
            self.fig = matspace.plotting.make_time_plot(...
                self.description, ...
                time, ...
                self.data, ...
                name=self.name, ...
                Elements=self.elements, ...
                Units=self.units, ...
                TimeUnits="datetime", ...
                StartDate="", ...
                RmsXmin=time(6), ...
                RmsXmax=time(26), ...
                DispXmin=time(2), ...
                DispXmax=time(end-2), ...
                SingleLines=self.single_lines, ...
                ColorMap=self.color_map, ...
                UseMean=self.use_mean, ...
                PlotZero=self.plot_zero, ...
                ShowRms=self.show_rms, ...
                LegendLoc=self.legend_loc, ...
                SecondUnits=self.second_units, ...
                YLabel=self.ylabel, ...
                DataAsRows=self.data_as_rows, ...
                ExtraPlotter=self.extra_plotter, ...
                UseZoh=self.use_zoh, ...
                LabelVertLines=self.label_vert_lines ...
            );
            self.verifyEqual(length(self.fig), 1);
        end

        function test_strings(self)
            time = 1:100;
            data = repmat("open", [1, 100]);
            data(10:20) = "closed";
            data_cat = categorical(data);
            self.fig = matspace.plotting.make_time_plot(self.description, time, data_cat, ShowRms=false);
            self.verifyEqual(length(self.fig), 1);
        end

        % function test_datashader(self)
        %     time = linspace(0.0, 1000.0, 1e6);
        %     data = rand(1, 1e6);
        %     self.fig = matspace.plotting.make_time_plot(self.description, time, data, UseDatashader=true);
        %     self.verifyEqual(length(self.fig), 1);
        % end

        % function test_datashader_dates(self)
        %     temp = linspace(0, 1000, 1e6);
        %     time = datetime("2021-06-01T00:00:00") + seconds(temp);
        %     data = rand(1, 1e6);
        %     self.fig = matspace.plotting.make_time_plot(self.description, time, data, TimeUnits='numpy', UseDatashader=true);
        %     self.verifyEqual(length(self.fig), 1);
        % end

        % function test_datashader_strings(self)
        %     time = linspace(0, 1000, 1e4);
        %     data = repmat("open", [1 1e4]);
        %     data(1000:2000) = "closed";
        %     self.fig = matspace.plotting.make_time_plot(self.description, time, data, ShowRms=false, UseDatashader=true);
        %     self.verifyEqual(length(self.fig), 1);
        % end
    end
end