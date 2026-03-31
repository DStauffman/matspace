classdef test_plot_bar_breakdown < matlab.unittest.TestCase

    % Tests the plot_bar_breakdown function with the following cases:
    %     Nominal
    %     Defaults
    %     With label
    %     With opts
    %     With legend
    %     Null data
    %     Bad legend
    %     With Colormap

    properties
        fig_hand,
        time,
        data,
        description,
        elements,
        opts,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand = gobjects(1, 0);
            self.time = 0:1/12:5;
            num_bins = 5;
            self.data = rand(num_bins, length(self.time));
            mag = sum(self.data, 1);
            self.data = self.data ./ mag;
            self.description = "Plot bar testing";
            self.elements = ["Value 1", "Value 2", "Value 3", "Value 4", "Value 5"];
            self.opts = matspace.plotting.Opts();
            self.opts.show_plot = false;
            self.fig_visible = false;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig_hand);
        end
    end

    methods (Test)
        function test_normal(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                opts=self.opts, elements=self.elements, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_defaults(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_opts(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                opts=self.opts, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_elements(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                elements=self.elements, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_ignore_zeros(self)
            self.data(:, 2) = 0;
            self.data(:, 4) = nan;
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                IgnoreEmpties=true, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_null_data(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown("", self.time, [], FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 0);
        end

        function test_colormap(self)
            self.opts.colormap = matspace.plotting.colors.dark2();
            color_map = matspace.plotting.colors.paired();
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                Opts=self.opts, ColorMap=color_map, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_bad_elements(self)
            self.verifyError(@() matspace.plotting.plot_bar_breakdown(self.description, self.time, ...
                self.data, elements=self.elements(:, 1:end-1), FigVisible=self.fig_visible), '');
        end

        function test_single_point(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time(1), self.data(:, 1), ...
                FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_new_colormap(self)
            self.opts.colormap = sky(256);
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, self.data, ...
                opts=self.opts, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_datetime(self)
            dates = datetime(2020, 01, 11, 12, 00, 00) + seconds(0:120:7200);
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, dates, self.data, ...
                opts=self.opts, TimeUnits="datetime", FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end

        function test_data_as_rows(self)
            self.fig_hand = matspace.plotting.plot_bar_breakdown(self.description, self.time, ...
                self.data', opts=self.opts, elements=self.elements, DataAsRows=false, FigVisible=self.fig_visible);
            self.verifyEqual(length(self.fig_hand), 1);
        end
    end
end