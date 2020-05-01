classdef test_plot_monte_carlo < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the plot_monte_carlo function with the following cases:
    %     TBD

    properties
        figs,
        time,
        data,
        OPTS,
        time2,
        data2
        description,
        type,
        truth_time,
        truth_data,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.time        = 1:10;
            self.data        = 2*sin(self.time);
            self.OPTS        = matspace.plotting.Opts();
            self.time2       = -1:2:12;
            self.data2       = 1.5*sin(self.time2+1);
            self.description = 'Some Sine Waves';
            self.type        = 'unity'; %{'unity', 'population', 'percentage', 'per 100K', 'per 100,000', 'cost'}
            self.truth_time  = 3:3:15;
            self.truth_data  = 2.2*sin(self.truth_time);
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.figs);
        end
    end

    methods (Test)
        function test_nominal(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data);
        end

        function test_with_opts(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, self.OPTS);
        end

        function test_with_description(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Description', self.description);
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Description', 'LaTeX \delta_a^2');
        end

        function test_with_second_data_set(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'TimeTwo', self.time2, 'DataTwo', self.data2);
        end

        function test_with_empty_opts(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, [], 'TimeTwo', self.time2, 'DataTwo', self.data2);
        end

        function test_with_type(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Type', 'unity');
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Type', 'population');
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Type', 'percentage');
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Type', 'per 100K');
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'Type', 'cost');
        end

        function test_with_truth(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'TruthTime', self.truth_time, 'TruthData', self.truth_data);
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'TruthTime', self.truth_time, 'TruthData', self.truth_data, ...
                'Description', 'HIV Prevalence');
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, 'TruthTime', [], 'TruthData', []);
        end

        function test_with_no_rms(self)
            self.OPTS.show_rms = false;
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data);
            self.OPTS.show_rms = true;
        end

        function test_with_everything(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, self.OPTS, 'Type', 'percentage', ...
                'TimeTwo', self.time2, 'DataTwo', self.data2, 'TruthTime', self.truth_time, 'TruthData', self.truth_data, ...
                'Description', 'HIV Prevalence');
        end

        function test_with_different_lower_and_upper_case_names(self)
            self.figs(end+1) = matspace.plotting.plot_monte_carlo(self.time, self.data, self.OPTS, 'type', 'percentage', ...
                'timetwo', self.time2, 'DATATWO', self.data2, 'truthtime', self.truth_time, 'truthdata', self.truth_data, ...
                'DeScRiPtIoN', 'Letters!');
        end

        function test_with_missing_inputs(self)
            self.verifyError(@() matspace.plotting.plot_monte_carlo(0), 'MATLAB:minrhs');
        end

%         function test_with_bad_opts(self)
%             self.verifyError(@(self) matspace.plotting.plot_monte_carlo(self.time, self.data, struct('case_name', 'test')), 'MATLAB:invalidType', self);
%         end
%
%         function test_with_bad_values(self)
%             self.verifyError(@() matspace.plotting.plot_monte_carlo('time', 2*sin(1:10)), 'MATLAB:invalidType');
%         end
    end
end