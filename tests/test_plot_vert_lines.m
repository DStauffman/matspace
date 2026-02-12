classdef test_plot_vert_lines < matlab.unittest.TestCase

    % Tests the make_time_plot function with the following cases:
    %     Nominal

    properties
        fig,
        ax,
        x,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig = figure(Name='Data', Visible='off', Theme='light');
            self.ax = axes(self.fig);
            plot(self.ax, 0:9, 0:9, DisplayName="Data");
            self.x = [2, 5];
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_nominal(self)
            matspace.plotting.plot_vert_lines(self.ax, self.x, ShowInLegend=false);
            legend(self.ax, 'show');
        end

        function test_no_legend(self)
            matspace.plotting.plot_vert_lines(self.ax, self.x, ShowInLegend=true);
            legend(self.ax, 'show');
        end

        function test_multiple_lines(self)
            labels = ["Line 1", "Line 2", "Line 3", "Line 4"];
            colormap = validatecolor(["r", "g", "b", "k"], 'multiple');
            matspace.plotting.plot_vert_lines(self.ax, [1, 2.5, 3.5, 8], ShowInLegend=true, Labels=labels, ColorMap=colormap);
            legend(self.ax, 'show');
        end

        function test_multiple_unlabeled(self)
            matspace.plotting.plot_vert_lines(self.ax, 0.5:6.5, ShowInLegend=false);
            legend(self.ax, 'show');
        end
    end
end