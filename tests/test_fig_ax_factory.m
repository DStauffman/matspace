classdef test_fig_ax_factory < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the make_time_plot function with the following cases:
    %     TBD

    properties
        fig_ax,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_visible = 'off';
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            for f = 1:length(self.fig_ax)
                fig_ax = self.fig_ax{f};
                if ~isempty(fig_ax)
                    this_fig = fig_ax{1};
                    if f == 1
                        last_fig = this_fig;
                    end
                    if this_fig ~= last_fig
                        close(last_fig);
                    end
                    last_fig = this_fig;
                end
            end
            if ~isempty(self.fig_ax)
                close(last_fig);
            end
        end
    end

    methods (Test)
        function test_1d_rows(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumAxes=4, Layout='rows', ...
                ShareX=true, Visible=self.fig_visible);
            self.verifyEqual(length(self.fig_ax), 4)
            % TODO: figure out how to test rows and sharex
        end

        function test_1d_cols(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumAxes=4, Layout='cols', ...
                ShareX=false, Visible=self.fig_visible);
            self.verifyEqual(length(self.fig_ax), 4)
            % TODO: figure out how to test rows and sharex
        end

        function test_1d_bad_layout(self)
            self.verifyError(@() matspace.plotting.fig_ax_factory(NumAxes=4, Layout='rowwise'), '');
        end

        function test_multi_figures(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumFigs=2, NumAxes=1, Visible=self.fig_visible);
            self.verifyEqual(length(self.fig_ax), 2);
            self.verifyNotEqual(self.fig_ax{1}, self.fig_ax{2});
        end

        function test_2d(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumAxes=[2, 3], ...
                Layout='rowwise', ShareX=true, Visible=self.fig_visible);
            self.verifyEqual(length(self.fig_ax), 6);
        end

        function test_2d_colwise(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumAxes=[3, 2], ...
                Layout='colwise', ShareX=false, Visible=self.fig_visible);
            self.verifyEqual(length(self.fig_ax), 6);
        end

        function test_2d_bad_layout(self)
            self.verifyError(@() matspace.plotting.fig_ax_factory(NumAxes=[4, 4], Layout='rows'), '');
        end

        function test_suptitle(self)
            self.fig_ax = matspace.plotting.fig_ax_factory(NumAxes=[1, 2], ...
                Layout='rowwise', SupTitle='Test Title', Visible=self.fig_visible);
            title(self.fig_ax{1}{2}, 'Title 1');
            title(self.fig_ax{2}{2}, 'Title 2');
            self.verifyEqual(length(self.fig_ax), 2);
            this_fig = self.fig_ax{1}{1};
            sgt = findobj(this_fig, 'Type', 'subplottext');
            % Get the screen size [left bottom width height]
            screen_size = get(0, 'ScreenSize');
            % Check if width and height are non-zero to determine if you have a display
            HAVE_DISPLAY = all(screen_size(3:4) > 0);
            if HAVE_DISPLAY
                self.verifyEqual(this_fig.Name, 'Test Title');
            end
            self.verifyEqual(sgt.String, 'Test Title');
        end

        function test_passthrough(self)
            fig_ax = matspace.plotting.fig_ax_factory(NumAxes=3, PassThrough=true, ...
                Visible=self.fig_visible);
            self.verifyEqual(length(fig_ax), 3);
            for i = 1:3
                self.verifyTrue(isempty(fig_ax{i}));
            end
        end
    end
end