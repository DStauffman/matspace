classdef test_plot_classification < matlab.unittest.TestCase %#ok<*PROP>

    % Tests the plot_classification function with the following cases:
    %     normal mode
    %     Caveats
    %     Inside Axes
    %     Outside Figure
    %     Classified options with test banner (and replacements)
    %     Bad option (should error)

    properties
        fig,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig = figure;
            ax = axes(self.fig);
            plot(ax, [0 1], [0 1], '.-b');
        end
    end

    methods (TestMethodTeardown)
        function closeFigure(self)
            close(self.fig);
        end
    end

    methods (Test)
        function test_defaults(self)
            matspace.plotting.plot_classification(self.fig, 'U');
        end

        function test_no_classification(self)
            % start with a classification, and then remove it
            matspace.plotting.plot_classification(self.fig, 'U');
            matspace.plotting.plot_classification(self.fig, '');
        end

        function test_caveat(self)
            matspace.plotting.plot_classification(self.fig, 'U', 'caveat', '//TEXT STR');
        end

        function test_strings_and_extra_colors(self)
            matspace.plotting.plot_classification(self.fig, "U", "caveat", "//FAKE COLOR");
        end

        function test_inside(self)
            matspace.plotting.plot_classification(self.fig, 'U', test=false, location='axis');
        end

        function test_outside(self)
            matspace.plotting.plot_classification(self.fig, 'U', test=false, location='figure');
        end

        function test_custom_colors(self)
            matspace.plotting.plot_classification(self.fig, 'U', color=[1 0 1], text_color=[1 0 0]);
        end

        function test_options(self)
            opt = {'CUI', 'C', 'S', 'T', 'TS'};
            exp_text = {'CUI', 'CONFIDENTIAL', 'SECRET', 'TOP SECRET', 'TOP SECRET'};
            exp_color = {[0.492 0.117 0.609], [0 0 1], [1 0 0], [1 0.65 0], [1 0.65 0]};
            for i = 1:length(opt)
                matspace.plotting.plot_classification(self.fig, opt{i}, 'test', true);
                % check the colors and labels
                ax = findall(self.fig, 'Tag', 'scribeOverlay');
                anons = get(ax, 'Children');
                if iscell(anons)
                    anons = vertcat(anons{:});
                end
                for j = 1:length(anons)
                    a = anons(j);
                    if strcmp(a.Tag, 'ClassificationText')
                        self.verifyEqual(a.Color, exp_color{i});
                        self.verifyEqual(a.String, exp_text{i});
                    end
                end
            end
        end

        function test_bad_option(self)
            self.verifyError(@() matspace.plotting.plot_classification(self.fig, 'BadOption'), 'MATLAB:validators:mustBeMember');
        end
    end
end