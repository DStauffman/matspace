classdef test_plot_time_history < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the make_time_plot function with the following cases:
    %     Nominal
    %     Defaults
    %     With label
    %     With type
    %     With Opts
    %     With legend
    %     No data
    %     Ignore all zeros
    %     Bad legend
    %     Show zero

    properties
        fig_hand,
        description,
        time,
        row_data,
        col_data,
        units,
        opts,
        elements,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.description    = 'Plot description';
            self.time           = 2000:0.1:2010;
            num_channels        = 5;
            self.row_data       = rand(length(self.time), num_channels);
            mag                 = sum(self.row_data, 2);
            self.row_data       = 10 * self.row_data ./ mag;
            self.col_data       = self.row_data';
            self.units          = 'percentage';
            self.opts           = matspace.plotting.Opts();
            self.opts.show_plot = false;
            self.elements       = ["Value 1", "Value 2", "Value 3", "Value 4", "Value 5"];
            self.fig_visible    = false;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig_hand);
        end
    end

    methods (Test)
        function test_nominal(self)
            self.fig_hand = matspace.plotting.plot_time_history(self.description, self.time, ...
                self.row_data, opts=self.opts, DataAsRows=false);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_defaults(self)
            self.fig_hand = matspace.plotting.plot_time_history('', self.time, self.col_data, ...
                FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_with_units(self)
            self.fig_hand = matspace.plotting.plot_time_history(self.description, self.time, ...
                self.col_data, Units=self.units, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_with_opts(self)
            self.fig_hand = matspace.plotting.plot_time_history(self.description, self.time, ...
                self.col_data, Opts=self.opts);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_no_data(self)
            self.fig_hand = matspace.plotting.plot_time_history('', self.time, [], FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_ignore_zeros(self)
            self.fig_hand = matspace.plotting.plot_time_history(self.description, self.time, ...
                self.col_data, IgnoreEmpties=true, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_ignore_zeros2(self)
            self.col_data(1, :) = 0;
            self.col_data(3, :) = 0;
            self.fig_hand = matspace.plotting.plot_time_history(self.description, self.time, ...
                self.col_data, IgnoreEmpties=true, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_ignore_zeros3(self)
            self.col_data(:) = 0;
            self.fig_hand = matspace.plotting.plot_time_history('All Zeros', self.time, ...
                self.col_data, IgnoreEmpties=true, FigVisible=self.fig_visible);
            self.verifyEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 0);
        end

        function test_0d(self)
            self.fig_hand = matspace.plotting.plot_time_history('Zero', 0, 0, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_1d(self)
            self.fig_hand = matspace.plotting.plot_time_history('Line', 1:5, 1:5, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_bad_3d(self)
            bad_data = rand(size(self.time, 1), 4, 5);
            self.verifyError(@() matspace.plotting.plot_time_history(self.description, self.time, ...
                bad_data, opts=self.opts), '');
        end

        function test_datetime(self)
            dates = datetime(2020, 01, 11, 12, 00, 00) + milliseconds(0:10:1000);
            self.opts.rms_xmin = NaT;
            self.opts.rms_xmax = datetime('nat', TimeZone='UTC');
            self.opts.disp_xmin = datetime('nat', TimeZone='UTC');
            self.opts.disp_xmax = NaT;
            self.fig_hand = matspace.plotting.plot_time_history(self.description, dates, self.col_data, ...
                Opts=self.opts, TimeUnits='datetime');
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_lists0(self)
            time = 1:100;
            data = {zeros(1, 100), ones(1, 100)};
            self.fig_hand = matspace.plotting.plot_time_history('', time, data, FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_lists1(self)
            time = 1:10;
            data = {rand(1, 10), 5 * rand(1, 10)};
            elements = ["Item 1", "5 Times"];
            self.fig_hand = matspace.plotting.plot_time_history(self.description, time, data, Opts=self.opts, ...
                Elements=elements);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_lists2(self)
            time = {1:5, 1:10};
            data = {[0.0, 0.1, 0.2, 0.3, 0.5], 1:10};
            self.fig_hand = matspace.plotting.plot_time_history(self.description, time, data, Opts=self.opts);
            self.verifyNotEmpty(self.fig_hand);
            self.verifyEqual(length(self.fig_hand), 1);
        end
    end
end