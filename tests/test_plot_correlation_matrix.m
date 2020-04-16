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
        figs,
        data,
        labels,
        opts,
        sym,
    end

    methods (TestMethodSetup)
        function initialize(self)
            num = 10;
            self.figs   = [];
            self.data   = rand(10, 10);
            self.data   = bsxfun(@rdivide,self.data,realsqrt(sum(self.data.^2,1)));
            self.labels = {'a','b','c','d','e','f','g','h','i','j'};
            self.opts   = struct();
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
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.figs);
        end
    end

    methods (Test)
        function test_normal(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, self.labels);
        end

        function test_bad_labels(self)
            self.verifyError(@() matspace.plotting.plot_correlation_matrix(self.data, {'a'}), 'matspace:BadLabelSize');
        end

        function test_bad_nargin1(self)
            self.verifyError(@() matspace.plotting.plot_correlation_matrix(), 'matspace:UnexpectedNargin');
        end

        function test_bad_nargin2(self)
            self.verifyError(@() matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'BadPairing'), 'matspace:UnexpectedNameValuePair');
        end

        function test_bad_nargin3(self)
            self.verifyError(@() matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'BadKey', 10), 'matspace:UnexpectedNameValuePair');
        end

        function test_nonsquare(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data(1:5, 1:3), {self.labels(1:3), ...
                self.labels(1:5)});
        end

        function test_default_labels(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data(1:5, 1:3));
        end

        function test_all_args(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, self.labels, self.opts, ...
                'CMin', 0, 'CMax', 1, 'LowerOnly', true, 'ColorMap', 'cool', ...
                'MatrixName', 'Correlation Matrix', 'PlotBorder', true, 'LabelValues', false);
        end

        function test_symmetric(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.sym);
        end

        function test_symmetric_all(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.sym, {}, [], 'LowerOnly', false);
        end

        function test_above_one(self)
            large_data = self.data * 1000;
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels);
        end

        function test_above_one_part2(self)
            large_data = self.data * 1000;
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels, [], 'cmax', 2000);
        end

        function test_below_one(self)
            large_data = 1000*(self.data - 0.5);
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels);
        end

        function test_below_one_part2(self)
            large_data = 1000*(self.data - 0.5);
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels, [], 'cmin', -2);
        end

        function test_within_minus_one(self)
            large_data = self.data - 0.5;
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels);
        end

        function test_within_minus_one_part2(self)
            large_data = self.data - 0.5;
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(large_data, self.labels, [], 'cmin', -1, 'cmax', 1);
        end

        function test_colormap(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'colormap', 'parula');
        end

        function test_matrix_name(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'MatrixName', 'Not a Correlation Matrix');
        end

        function test_plot_border(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'PlotBorder', false);
        end

        function test_label_values(self)
            self.figs(end+1) = matspace.plotting.plot_correlation_matrix(self.data, {}, [], 'LabelValues', true);
        end
    end
end