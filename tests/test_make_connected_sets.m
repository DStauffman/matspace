classdef test_make_connected_sets < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the make_connected_sets function with the following cases:
    %     Nominal
    %     Color by Quad
    %     Color by Magnitude
    %     Center Origin

    properties
        fig_hand,
        description,
        points,
        innovs,
        fig_visible,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.fig_hand    = gobjects(1, 0);
            self.description = 'Focal Plane Sightings';
            self.points      = 2 * (rand([2, 100]) - 1.0);
            self.innovs      = 0.1 * randn(size(self.points));
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
            self.fig_hand = matspace.plotting.make_connected_sets(self.description, self.points, ...
                self.innovs, FigVisible=self.fig_visible);
        end

        function test_color_by_direction(self)
            self.fig_hand = matspace.plotting.make_connected_sets(self.description, self.points, ...
                self.innovs, ColorBy='direction', FigVisible=self.fig_visible);
        end

        function test_color_by_magnitude(self)
            self.fig_hand = matspace.plotting.make_connected_sets(self.description, self.points, ...
                self.innovs, ColorBy="magnitude", FigVisible=self.fig_visible);
        end

        function test_center_origin(self)
            self.fig_hand = matspace.plotting.make_connected_sets(self.description, self.points, ...
                self.innovs, CenterOrigin=true, FigVisible=self.fig_visible);
        end

        function test_bad_inputs(self)
            self.verifyError(@() matspace.plotting.make_connected_sets(self.description, self.points, ...
                self.innovs, ColorBy="bad_option", FigVisible=self.fig_visible), '');
        end
    end
end