classdef test_disp_xlimits < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the make_time_plot function with the following cases:
    %     Normal use
    %     Null action
    %     Only xmin
    %     Only xmax
    %     Multiple figures

    properties
        fig,
        xmin,
        xmax,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig = figure;
            self.xmin = 2;
            self.xmax = 5;
            x = 0:0.1:10;
            y = sin(x);
            ax = axes(self.fig);
            plot(ax, x, y);
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_normal(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=self.xmin, xmax=self.xmax);
        end

        function test_null_action(self)
            matspace.plotting.disp_xlimits(self.fig);
        end

        function test_just_xmin(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=self.xmin);
        end

        function test_just_xmax(self)
            matspace.plotting.disp_xlimits(self.fig, xmax=self.xmax);
        end

        function test_multiple_figs(self)
            matspace.plotting.disp_xlimits([self.fig, self.fig], xmin=self.xmin, xmax=self.xmax);
        end

        function test_inf(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=-inf);
            matspace.plotting.disp_xlimits(self.fig, xmax=inf);
        end

        function test_nat(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=NaT, xmax=self.xmax);
            matspace.plotting.disp_xlimits(self.fig, xmax=NaT, xmin=self.xmin);
        end

        function test_datetime(self)
            ax = gca(self.fig);
            x = datetime(2026, 1, 15, 9, 0, 0) + seconds(0:0.1:10);
            y = sin(0:0.1:10);
            plot(ax, x, y);
            matspace.plotting.disp_xlimits(self.fig, xmin=inf, xmax=datetime(2026, 1, 15, 9, 0, 5));
        end
    end
end