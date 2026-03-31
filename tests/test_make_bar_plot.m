classdef test_make_bar_plot < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the make_bar_plot function with the following cases:
    %     TBD

    properties
        fig_hand,
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
        color_map,
        use_mean,
        plot_zero,
        show_rms,
        ignore_empties,
        legend_loc,
        second_units,
        y_label,
        data_as_rows,
        extra_plotter,
        label_vert_lines,
        fig_ax,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand = gobjects(1, 0);
            self.description      = 'Test vs Time';
            self.time             = 2000:1/12:2005;
            self.data             = rand(5, length(self.time));
            mag                   = sum(self.data, 1);
            self.data             = 100 * self.data ./ mag;
            self.name             = '';
            self.elements         = strings(1, 0);
            self.units            = '%';
            self.time_units       = 'sec';
            self.start_date       = '';
            self.rms_xmin         = -inf;
            self.rms_xmax         = inf;
            self.disp_xmin        = -inf;
            self.disp_xmax        = inf;
            self.color_map        = matspace.plotting.colors.paired();
            self.use_mean         = true;
            self.plot_zero        = false;
            self.show_rms         = true;
            self.ignore_empties   = false;
            self.legend_loc       = 'best';
            self.second_units     = '';
            self.y_label          = '';
            self.data_as_rows     = true;
            self.extra_plotter    = [];
            self.label_vert_lines = true;
            self.fig_ax           = [];
            self.fig_visible = false;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig_hand);
        end
    end

    methods (Test)
        function test_nominal(self)
            self.fig_hand = matspace.plotting.make_bar_plot(...
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
                ColorMap=self.color_map, ...
                UseMean=self.use_mean, ...
                PlotZero=self.plot_zero, ...
                ShowRms=self.show_rms, ...
                IgnoreEmpties=self.ignore_empties, ...
                LegendLoc=self.legend_loc, ...
                SecondUnits=self.second_units, ...
                YLabel=self.y_label, ...
                DataAsRows=self.data_as_rows, ...
                ExtraPlotter=self.extra_plotter, ...
                LabelVertLines=self.label_vert_lines, ...
                FigAx=self.fig_ax, ...
                FigVisible=self.fig_visible);
            self.verifyNotEmpty(self.fig_hand);
        end
    end
end