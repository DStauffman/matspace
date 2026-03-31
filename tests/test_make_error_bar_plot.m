classdef test_make_error_bar_plot < matlab.unittest.TestCase

    % Tests the make_error_bar_plot function with the following cases:
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
        description,
        time,
        data,
        mins,
        maxs,
        elements,
        units,
        time_units,
        start_date,
        rms_xmin,
        rms_xmax,
        disp_xmin,
        disp_xmax,
        single_lines,
        color_map,
        use_mean,
        plot_zero,
        show_rms,
        legend_loc,
        second_units,
        ylabel,
        data_as_rows,
        label_vert_lines,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand = gobjects(1, 0);
            self.description      = 'Random Data Error Bars';
            self.time             = 0:10;
            self.data             = [3; -2; 5] + rand(3, 11);
            self.mins             = self.data - 0.5 * randn(3, 11);
            self.maxs             = self.data + 1.5 * randn(3, 11);
            self.elements         = ["x", "y", "z"];
            self.units            = 'rad';
            self.time_units       = 'sec';
            self.start_date       = ['  t0 = ',char(datetime('now'))];
            self.rms_xmin         = 1;
            self.rms_xmax         = 10;
            self.disp_xmin        = -2;
            self.disp_xmax        = inf;
            self.single_lines     = false;
            self.color_map        = matspace.plotting.colors.tab10();
            self.use_mean         = false;
            self.plot_zero        = false;
            self.show_rms         = true;
            self.legend_loc       = 'best';
            self.second_units     = 'milli';
            self.ylabel           = '';
            self.data_as_rows     = true;
            self.label_vert_lines = true;
            self.fig_visible      = false;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig_hand);
        end
    end

    methods (Test)
        function test_nominal(self)
            self.fig_hand = matspace.plotting.make_error_bar_plot(...
                self.description, ...
                self.time, ...
                self.data, ...
                self.mins, ...
                self.maxs, ...
                Elements=self.elements, ...
                Units=self.units, ...
                TimeUnits=self.time_units, ...
                StartDate=self.start_date, ...
                RmsXMin=self.rms_xmin, ...
                RmsXMax=self.rms_xmax, ...
                DispXMin=self.disp_xmin, ...
                DispXMax=self.disp_xmax, ...
                SingleLines=self.single_lines, ...
                ColorMap=self.color_map, ...
                UseMean=self.use_mean, ...
                PlotZero=self.plot_zero, ...
                ShowRms=self.show_rms, ...
                LegendLoc=self.legend_loc, ...
                SecondUnits=self.second_units, ...
                YLabel=self.ylabel, ...
                DataAsRows=self.data_as_rows, ...
                LabelVertLines=self.label_vert_lines, ...
                FigVisible=self.fig_visible);
        end
    end
end