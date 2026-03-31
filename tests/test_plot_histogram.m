classdef test_plot_histogram < matlab.unittest.TestCase

    % Tests the plot_histogram function with the following cases:
    %     Nominal
    %     All inputs
    %     Datetimes

    properties
        fig_hand,
        description,
        data,
        bins,
        counts,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand = gobjects(1, 0);
            self.description = 'Histogram';
            self.data = [0.5, 3.3, 1.0, 1.5, 1.5, 1.75, 2.5, 2.5];
            self.bins = [0.0, 1.0, 2.0, 3.0, 5.0, 7.0];
            self.counts = [0.1, 0.2, 0.25, 0.15, 0.3];
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
            self.fig_hand = matspace.plotting.plot_histogram(self.description, self.data, self.bins, ...
                FigVisible=self.fig_visible);
        end
    
        function test_with_opts(self)
            opts = matspace.plotting.Opts();
            self.fig_hand = matspace.plotting.plot_histogram(...
                self.description,...
                self.data,...
                self.bins,...
                opts=opts,...
                color='k',...
                xlabel='Text',...
                ylabel='Num',...
                SecondYLabel='Dist',...
                FigVisible=self.fig_visible);
        end
    
        function test_datetimes(self)
            date_zero = datetime(2021, 2, 1);
            data_np = date_zero + seconds(self.data);
            bins_np = date_zero + seconds(self.bins);
            % TODO: would prefer to handle this case better
            self.fig_hand = matspace.plotting.plot_histogram(self.description, data_np, bins_np, FigVisible=self.fig_visible);
        end
    
        function test_infs(self)
            self.fig_hand = matspace.plotting.plot_histogram(self.description, self.data, [-inf -1 0 1 inf], ...
                FigVisible=self.fig_visible);
        end
    
        function test_int_cats(self)
            data_int = uint32([3, 3, 5, 8, 2, 2, 2]);
            bins_int = uint32([1, 2, 3, 4, 5]);
            self.fig_hand = matspace.plotting.plot_histogram(self.description, data_int, bins_int, ...
                UseExactCounts=true, FigVisible=self.fig_visible);
        end
    
        function test_string_cats(self)
            data_str = repmat("yes", 1, 10);
            data_str(3) = "no";
            data_str(9) = "no";
            data_str(6) = "unknown";
            bins_str = ["yes", "no"];
            self.fig_hand = matspace.plotting.plot_histogram(self.description, data_str, bins_str, ...
                UseExactCounts=true, FigVisible=self.fig_visible);
        end
    
        function test_missing_data(self)
            % TODO: make error: self.verifyError(@() matspace.plotting.plot_histogram(self.description, self.data, [3, 10, 15]), '');
            self.fig_hand = matspace.plotting.plot_histogram(self.description, self.data, [3, 10, 15]);
        end
    
        function test_missing_exacts(self)
            self.fig_hand = matspace.plotting.plot_histogram(self.description, [1 1 1 2 3 3 3], ...
                [0 3 6], UseExactCounts=true, FigVisible=self.fig_visible);
        end
    
        function test_counts_replacement1(self)
            self.fig_hand = matspace.plotting.plot_histogram(self.description, [], self.bins, ...
                counts=self.counts, FigVisible=self.fig_visible);
        end
    
        function test_counts_replacement2(self)
            self.fig_hand = matspace.plotting.plot_histogram(self.description, [], self.bins, ...
                counts=self.counts, SecondYLabel='%', ShowCdf=true, CdfRoundToBin=true, FigVisible=self.fig_visible);
        end
    
        function test_counts_replacement3(self)
            self.verifyError(@() matspace.plotting.plot_histogram(self.description, [], self.bins, ...
                counts=self.counts, ShowCdf=true, FigVisible=self.fig_visible), '');
        end
    
        function test_counts_replacement4(self)
            self.fig_hand = matspace.plotting.plot_histogram(self.description, [], [-inf 0 inf], ...
                counts=[0.2 0.5 0.3], FigVisible=self.fig_visible);
        end
    end
end