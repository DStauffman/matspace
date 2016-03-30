classdef test_icer < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the icer function with the following cases:
    %     nominal
    %     no domination
    %     reverse order
    %     single scalar input
    %     row vectors
    %     bad values (should error)
    %     bad sizes (should error)

    properties
        cost,
        qaly,
        inc_cost,
        inc_qaly,
        icer_out,
        order
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.cost     = [250e3; 750e3; 2.25e6; 3.75e6];
            self.qaly     = [20; 30; 40; 80];
            self.inc_cost = [250e3; 500e3; 3e6];
            self.inc_qaly = [20; 10; 50];
            self.icer_out = [12500; 50000; 60000];
            self.order    = [1; 2; nan; 3];
        end
    end

    methods (Test)
        function test_slide_example(self)
            [inc_cost, inc_qaly, icer_out, order] = icer(self.cost, self.qaly);
            self.verifyEqual(inc_cost, self.inc_cost, 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, self.inc_qaly, 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, self.icer_out, 'ICER mismatch.');
            self.verifyEqual(order, self.order, 'Order mismatch.');
        end

        function test_no_domination(self)
            ix = [1 2 4];
            [inc_cost, inc_qaly, icer_out, order] = icer(self.cost(ix), self.qaly(ix));
            self.verifyEqual(inc_cost, self.inc_cost, 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, self.inc_qaly, 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, self.icer_out, 'ICER mismatch.');
            self.verifyEqual(order, self.order(ix), 'Order mismatch.');
        end

        function test_reverse_order(self)
            ix = [4 3 2 1];
            [inc_cost, inc_qaly, icer_out, order] = icer(self.cost(ix), self.qaly(ix));
            self.verifyEqual(inc_cost, self.inc_cost, 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, self.inc_qaly, 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, self.icer_out, 'ICER mismatch.');
            self.verifyEqual(order, self.order(ix), 'Order mismatch.');
        end

        function test_single_input(self)
            ix = 1;
            [inc_cost, inc_qaly, icer_out, order] = icer(self.cost(ix), self.qaly(ix));
            self.verifyEqual(inc_cost, self.inc_cost(ix), 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, self.inc_qaly(ix), 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, self.icer_out(ix), 'ICER mismatch.');
            self.verifyEqual(order, self.order(ix), 'Order mismatch.');
        end

        function test_row_vectors(self)
            [inc_cost, inc_qaly, icer_out, order] = icer(self.cost(:)', self.qaly(:)');
            self.verifyEqual(inc_cost, self.inc_cost, 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, self.inc_qaly, 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, self.icer_out, 'ICER mismatch.');
            self.verifyEqual(order, self.order, 'Order mismatch.');
        end

        function test_bad_values(self)
            self.verifyError(@() icer([1 -2 3], [4 5 6]), '');
            self.verifyError(@() icer([1 2 3], [4 -5 6]), '');
        end

        function test_bad_input_sizes(self)
            self.verifyError(@() icer([], []), '');
            self.verifyError(@() icer([1 2 3], [4 5]), '');
        end
        
        function test_all_dominated_by_last(self)
            cost = [10; 20; 30; 1];
            qaly = [1; 2; 3; 100];
            [inc_cost, inc_qaly, icer_out, order] = icer(cost, qaly);
            self.verifyEqual(inc_cost, 1, 'Incremental cost mismatch.');
            self.verifyEqual(inc_qaly, 100, 'Incremental QALY mismatch.');
            self.verifyEqual(icer_out, 0.01, 'ICER mismatch.');
            self.verifyEqual(order, [nan; nan; nan; 1], 'Order mismatch.');
        end
    end
end