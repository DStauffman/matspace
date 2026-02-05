classdef test_zoom_ylim < matlab.unittest.TestCase

    % Tests the make_time_plot function with the following cases:
    %     TBD

    properties
        fig,
        ax,
        time,
        data,
        t_start,
        t_final,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig = figure(Name='Figure Title');
            self.ax = axes(self.fig);
            self.time = 1:0.1:10;
            self.data = self.time.^2;
            plot(self.ax, self.time, self.data);
            title(self.ax, "X vs Y");
            self.t_start = 3;
            self.t_final = 5.0000001;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_nominal(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=self.t_start, xmax=self.t_final);
            old_ylims = ylim(self.ax);
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, t_start=self.t_start, t_final=self.t_final);
            new_ylims = ylim(self.ax);
            self.verifyGreaterThan(old_ylims(2), new_ylims(2));
            self.verifyLessThan(old_ylims(1), new_ylims(1));
        end

        function test_no_zoom_out(self)
            old_ylims = ylim(self.ax);
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, pad=2.0, zoom="in")
            new_ylims = ylim(self.ax);
            self.verifyEqual(old_ylims(2), new_ylims(2))
            self.verifyEqual(old_ylims(1), new_ylims(1))
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, pad=2.0)
            new_ylims = ylim(self.ax);
            self.verifyLessThan(old_ylims(2), new_ylims(2))
            self.verifyGreaterThan(old_ylims(1), new_ylims(1))
        end

        function test_no_zoom_in(self)
            old_ylims = ylim(self.ax);
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, t_start=self.t_start, t_final=self.t_final, zoom="out")
            new_ylims = ylim(self.ax);
            self.verifyEqual(old_ylims(2), new_ylims(2))
            self.verifyEqual(old_ylims(1), new_ylims(1))
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, t_start=self.t_start, t_final=self.t_final, zoom="in")
            new_ylims = ylim(self.ax);
            self.verifyGreaterThan(old_ylims(2), new_ylims(2))
            self.verifyLessThan(old_ylims(1), new_ylims(1))
        end

        function test_bad_pad(self)
            self.verifyError(@() matspace.plotting.zoom_ylim(self.ax, self.time, self.data, pad=-10), '');
        end

        function test_no_pad(self)
            matspace.plotting.disp_xlimits(self.fig, xmin=self.t_start, xmax=self.t_final)
            old_ylims = ylim(self.ax);
            matspace.plotting.zoom_ylim(self.ax, self.time, self.data, t_start=self.t_start, t_final=self.t_final, pad=0)
            new_ylims = ylim(self.ax);
            self.verifyGreaterThan(old_ylims(2), new_ylims(2))
            self.verifyLessThan(old_ylims(1), new_ylims(1))
            self.verifyEqual(new_ylims(1), self.t_start^2)
            self.verifyEqual(new_ylims(2), self.t_final^2, RelTol=0.5e-4);
        end
    end
end