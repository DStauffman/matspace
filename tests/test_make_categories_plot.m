classdef test_make_categories_plot < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the make_categories_plot function with the following cases:
    %     Nominal
    %     Minimal inputs
    %     Datashader

    properties
        fig_hand,
        description,
        time,
        data,
        cats,
        cat_names,
        name,
        elements,
        units,
        time_units,
        start_date,
        rms_xmin,
        rms_xmax,
        disp_xmin,
        disp_xmax,
        make_subplots,
        single_lines,
        color_map,
        use_mean,
        plot_zero,
        show_rms,
        legend_loc,
        second_units,
        legend_scale,  % need this?
        ylabel,
        data_as_rows,
        use_zoh,
        label_vert_lines,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand         = gobjects(1, 0);
            self.description      = 'Values vs Time';
            self.time             = -10:0.1:10;
            self.data             = self.time + cos(self.time);
            self.cats             = repmat(matspace.enum.MeasStatus.accepted, size(self.time));
            self.cats(50:100)     = matspace.enum.MeasStatus.rejected;
            self.cat_names        = dictionary(0, "rejected", 1, "accepted");
            self.name             = '';
            self.elements         = strings(1, 0);
            self.units            = '';
            self.time_units       = 'sec';
            self.start_date       = '';
            self.rms_xmin         = -inf;
            self.rms_xmax         = inf;
            self.disp_xmin        = -inf;
            self.disp_xmax        = inf;
            self.make_subplots    = true;
            self.single_lines     = false;
            self.color_map        = matspace.plotting.colors.paired();
            self.use_mean         = false;
            self.plot_zero        = false;
            self.show_rms         = true;
            self.legend_loc       = 'best';
            self.second_units     = 'unity';
            self.ylabel           = '';
            self.data_as_rows     = true;
            self.use_zoh          = false;
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
            self.fig_hand = matspace.plotting.make_categories_plot(...
                self.description, ...
                self.time, ...
                self.data, ...
                self.cats, ...
                CatNames=self.cat_names, ...
                Name=self.name, ...
                Elements=self.elements, ...
                Units=self.units, ...
                TimeUnits=self.time_units, ...
                StartDate=self.start_date, ...
                RmsXmin=self.rms_xmin, ...
                RmsXmax=self.rms_xmax, ...
                DispXmin=self.disp_xmin, ...
                DispXmax=self.disp_xmax, ...
                MakeSubplots=self.make_subplots, ...
                SingleLines=self.single_lines, ...
                ColorMap=self.color_map, ...
                UseMean=self.use_mean, ...
                PlotZero=self.plot_zero, ...
                ShowRms=self.show_rms, ...
                LegendLoc=self.legend_loc, ...
                SecondUnits=self.second_units, ...
                YLabel=self.ylabel, ...
                DataAsRows=self.data_as_rows, ...
                UseZoh=self.use_zoh, ...
                LabelVertLines=self.label_vert_lines, ...
                FigVisible=self.fig_visible);
        end

        function test_minimal(self)
            self.fig_hand = matspace.plotting.make_categories_plot(self.description, self.time, self.data, self.cats);
        end

        function test_datashader_cats(self)
            time = 1:10000;
            data = time + sin(time / pi / 100);
            cats = repmat(matspace.enum.MeasStatus.accepted, size(time));
            cats(500:1000) = matspace.enum.MeasStatus.rejected;
            self.fig_hand = matspace.plotting.make_categories_plot(self.description, time, data, cats, UseDatashader=true);
        end
    end
end