classdef test_plot_states < matlab.unittest.TestCase

    % Tests the make_difference_plot function with the following cases:
    %     Single Kf structure
    %     Comparison
    %     Comparison with mismatched states
    %     Error output

    properties
        fig_hand,
        gnd1,
        gnd2,
        opts,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.gnd1 = struct(name='GARSE', num_points=31, num_states=9, active=1:9);
            self.gnd2 = struct(name='GBARS', num_points=61, num_states=8, active=[1, 2, 3, 4, 6, 7, 8, 9]);
            self.gnd1.time = 0:30;
            self.gnd2.time = -10:50;
            self.gnd1.state = ones(9, 31);
            self.gnd2.state = repmat(0.99, 8, 61);
            self.opts = matspace.plotting.Opts();
            self.opts.show_plot = false;
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig_hand);
        end
    end

    methods (Test)
        function test_single(self)
            %with patch("lmspace.plotting.aerospace.logger") as mock_logger:
            self.fig_hand = matspace.plotting.gnds.plot_states(self.gnd1, [], Opts=self.opts);
            % mock_logger.log.assert_any_call(LogLevel.L4, "Plotting %s plots ...", "State Estimates")
            % mock_logger.log.assert_called_with(LogLevel.L4, "... done.")
        end

        function test_comp(self)
            %with patch("lmspace.plotting.aerospace.logger") as mock_logger:
            self.fig_hand = matspace.plotting.gnds.plot_states(self.gnd1, self.gnd2, Opts=self.opts);
            % mock_logger.log.assert_any_call(LogLevel.L4, "Plotting %s plots ...", "State Estimates")
            % mock_logger.log.assert_called_with(LogLevel.L4, "... done.")
        end

        function test_errs(self)
            % with patch("lmspace.plotting.aerospace.logger") as mock_logger:
            [self.fig_hand, err] = matspace.plotting.gnds.plot_states(self.gnd1, self.gnd2, Opts=self.opts);
            % mock_logger.log.assert_any_call(LogLevel.L4, "Plotting %s plots ...", "State Estimates")
            % mock_logger.log.assert_called_with(LogLevel.L4, "... done.")
            self.verifyEqual(fieldnames(err), {'state'});
        end

        function test_groups(self)
            groups = {[0, 1, 2], [3, 4, 5], [6, 7, 8]};
            % with patch("lmspace.plotting.aerospace.logger") as mock_logger:
            self.fig_hand = matspace.plotting.gnds.plot_states(self.gnd1, self.gnd2, Groups=groups, Opts=self.opts);
            % mock_logger.log.assert_any_call(LogLevel.L4, "Plotting %s plots ...", "State Estimates")
            % mock_logger.log.assert_called_with(LogLevel.L4, "... done.")
        end
    end
end