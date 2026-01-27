classdef test_plot_correlation_matrix < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the plot_correlation_matrix function with the following cases:
    %     normal mode
    %     bad labels (should raise error)
    %     bad nargin x3 (should raise errors)
    %     non-square inputs
    %     default labels
    %     all arguments passed in
    %     symmetric matrix, lower only
    %     symmetrix matrix, plot whole thing
    %     coloring with values above 1 (x2)
    %     coloring with values below -1 (x2)
    %     coloring with values in -1 to 1 instead of 0 to 1 (x2)
    %     non default colormap
    %     non default matrix name
    %     non default plot border
    %     non default label values

    properties
        fig_hand,
        data,
        labels,
        units,
        opts,
        sym,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            num = 10;
            self.data   = matspace.utils.unit(rand(num, num), 1);
            self.labels = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j"];
            self.units  = 'percentage';
            self.opts   = matspace.plotting.Opts;
            self.opts.case_name = 'Testing Correlation';
            self.sym = self.data;
            for j = 1:num
                for i = 1:num
                    if i == j
                        self.sym(i, j) = 1;
                    elseif i > j
                        self.sym(i, j) = self.data(j, i);
                    end
                end
            end
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
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, self.labels, ...
                FigVisible=self.fig_visible);
        end

        function test_nonsquare(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data(1:5, 1:3), {self.labels(1:3), ...
                self.labels(1:5)}, FigVisible=self.fig_visible);
        end

        function test_default_labels(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data(1:5, 1:3), FigVisible=self.fig_visible);
        end

        function test_type(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, strings(1, 0), self.units);
        end

        function test_all_args(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, self.labels, self.units, ...
                Opts=self.opts, MatrixName='Correlation Matrix', CMin=0, CMax=1, XLabel='', YLabel='', ...
                PlotLowerOnly=false, LabelValues=true, XLabRot=180, ColorMap=cool, ...
                PlotBorder=true, LegendScale='micro', FigVisible=self.fig_visible, SkipSetupPlots=false);
        end

        function test_symmetric(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.sym, FigVisible=self.fig_visible);
        end

        function test_symmetric_all(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.sym, PlotLowerOnly=false, ...
                FigVisible=self.fig_visible);
        end

        function test_above_one(self)
            large_data = self.data * 1000;
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, ...
                FigVisible=self.fig_visible);
        end

        function test_above_one_part2(self)
            large_data = self.data * 1000;
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, cmax=2000, ...
                FigVisible=self.fig_visible);
        end

        function test_below_one(self)
            large_data = 1000*(self.data - 0.5);
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, ...
                FigVisible=self.fig_visible);
        end

        function test_below_one_part2(self)
            large_data = 1000*(self.data - 0.5);
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, cmin=-2, ...
                FigVisible=self.fig_visible);
        end

        function test_within_minus_one(self)
            large_data = self.data - 0.5;
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, ...
                FigVisible=self.fig_visible);
        end

        function test_within_minus_one_part2(self)
            large_data = self.data - 0.5;
            self.fig_hand = matspace.plotting.plot_correlation_matrix(large_data, self.labels, cmin=-1, ...
                cmax=1, FigVisible=self.fig_visible);
        end

        function test_xlabel(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, self.labels, ...
                XLabel='Testing Label', FigVisible=self.fig_visible);
        end

        function test_ylabel(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, YLabel='Testing Label', ...
                FigVisible=self.fig_visible);
        end

        function test_x_label_rotation(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, self.labels, XLabRot=0, ...
                FigVisible=self.fig_visible);
        end

        function test_colormap(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, colormap=parula, ...
                FigVisible=self.fig_visible);
        end

        function test_matrix_name(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, ...
                MatrixName='Not a Correlation Matrix', FigVisible=self.fig_visible);
        end

        function test_plot_border(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, PlotBorder=false, ...
                FigVisible=self.fig_visible);
        end

        function test_nans(self)
            self.data(1, 1) = nan;
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, self.labels, ...
                FigVisible=self.fig_visible);
        end

        function test_bad_labels(self)
            self.verifyError(@() matspace.plotting.plot_correlation_matrix(self.data, "a"), 'matspace:BadLabelSize');
        end

        function test_label_values(self)
            self.fig_hand = matspace.plotting.plot_correlation_matrix(self.data, LabelValues=true, ...
                FigVisible=self.fig_visible);
        end
    end
end