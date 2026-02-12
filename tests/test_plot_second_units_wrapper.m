classdef test_plot_second_units_wrapper < matlab.unittest.TestCase

    % Tests the make_time_plot function with the following cases:
    %     TBD

    properties
        description,
        y_label,
        fig,
        ax,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.description = 'Values over time';
            self.y_label = 'Value [rad]';
            self.fig = figure(Name='Values over time', Visible='off', Theme='light');
            self.ax = axes(self.fig);
            plot(self.ax, [1, 5, 10], [1e-6, 3e-6, 2.5e-6], ".-");
            ylabel(self.ax, self.y_label);
            title(self.ax, self.description);
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_none_char(self)
            matspace.plotting.plot_second_units_wrapper(self.ax, '');
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax), 1);
        end

        function test_none_string(self)
            matspace.plotting.plot_second_units_wrapper(self.ax, "");
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax), 1);
        end

        function test_none_empty(self)
            matspace.plotting.plot_second_units_wrapper(self.ax, []);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax), 1);
        end

        function test_int(self)
            second_units = 100;
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 2);
            yyaxis right;
            self.verifyEqual(self.ax.YLabel.String, '');
            yyaxis left;
        end

        function test_float(self)
            second_units = 100.0;
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 2);
            yyaxis right;
            self.verifyEqual(self.ax.YLabel.String, '');
            yyaxis left;
        end

        function test_zero(self)
            second_units = 0.0;
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 1);
            second_units = {"new", 0};
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 1);
        end

        function test_nan(self)
            second_units = nan;
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 1);
            second_units = {"new", nan};
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 1);
        end

        function test_full_replace(self)
            second_units = {"Better Units [µrad]", 1e6};
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.verifyEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 2);
            yyaxis right;
            self.verifyEqual(self.ax.YLabel.String, 'Better Units [µrad]');
            yyaxis left;
        end

        function test_units_only(self)
            second_units = {"mrad", 1e3};
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.assertEqual(self.ax.YLabel.String, self.y_label);
            self.verifyEqual(length(self.ax.YAxis), 2);
            yyaxis right;
            self.verifyEqual(self.ax.YLabel.String, 'Value [mrad]');
            yyaxis left;
        end

        function test_no_units(self)
            ylabel(self.ax, "Value");
            second_units = {"New Value", 1e3};
            matspace.plotting.plot_second_units_wrapper(self.ax, second_units);
            self.assertEqual(self.ax.YLabel.String, 'Value');
            self.verifyEqual(length(self.ax.YAxis), 2);
            yyaxis right;
            self.verifyEqual(self.ax.YLabel.String, 'New Value');
            yyaxis left;
        end
    end
end