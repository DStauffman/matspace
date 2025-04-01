classdef test_plot_phases < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the plot_phases function with the following cases:
    %     normal mode
    %     Caveats
    %     Inside Axes
    %     Outside Figure
    %     Classified options with test banner (and replacements)
    %     Bad option (should error)

    properties
        fig,
        ax,
        time,
        dates,
        data,
        times,
        times2,
        labels,
        colorlists,
        colors,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig = figure('name', 'Sine Wave');
            self.ax = axes(self.fig);
            self.time = 0:100;
            self.dates = datetime(2025, 3, 31, 12, 0, 0) + seconds(self.time);
            self.data = cos(self.time/10);
            self.times = [5 20 30 50; 10 30 35 70];
            self.times2 = [60 80 90; 70 85 100];
            self.labels = ["Part 1", "Phase 2", "Watch Out", "Final"];
            self.colorlists = matspace.plotting.get_color_lists();
            self.colors = self.colorlists.quat;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_multi_phases(self)
            % multi phases
            plot(self.ax, self.time, self.data, '.-', 'DisplayName', 'Waves');
            matspace.plotting.plot_phases(self.ax, self.times, self.colors, self.labels);
        end

        function test_single_phase(self)
            % single phase, repeated
            plot(self.ax, self.time, self.data, '.-', 'DisplayName', 'Waves');
            matspace.plotting.plot_phases(self.ax, self.times2, self.colorlists.default{1}, 'Monitor');
            legend(self.ax, 'show');
        end

        function test_caveat(self)
            % multi-phases datetime
            plot(self.ax, self.dates, self.data, '.-', 'DisplayName', 'Waves');
            time_as_dates = self.dates(1) + seconds(self.times);
            matspace.plotting.plot_phases(self.ax, time_as_dates, self.colors, self.labels);
        end

        function test_strings_and_extra_colors(self)
            % single phase datetime
            plot(self.ax, self.dates, self.data, '.-', 'DisplayName', 'Waves');
            time_as_dates = self.dates(1) + seconds(self.times2);
            matspace.plotting.plot_phases(self.ax, time_as_dates, self.colorlists.default{1}, 'Monitor');
            legend(self.ax, 'show');
        end
    end
end