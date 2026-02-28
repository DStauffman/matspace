classdef ColorMap

    % ColorMap  class for easier setting of colormaps.
    % 
    % Input:
    %     cmap : (3, N) colormap to wrap
    %     wrap : string specifying how to wrap the colormap, by holding at the last value, or cycling through
    %            from {'hold', 'wrap'}
    % 
    % Prototype:
    %     cm = matspace.plotting.colors.ColorMap(matspace.plotting.colors.paired());
    %     time = 0:0.1:10;
    %     fig = figure();
    %     ax = axes(fig);
    %     hold(ax, 'on');
    %     plot(ax, time, sin(time), color=cm.get_color(1));
    %     plot(ax, time, cos(time), color=cm.get_color(2));
    %     legend(ax, ["Sin", "Cos"]);
    % 
    %     % Close plot
    %     close(fig);
    % 
    % Change Log:
    %     1.  Written by David C. Stauffer in July 2015.
    %     2.  Translated into Matlab by David C. Stauffer in February 2026.

    properties
        cmap,
        wrap,
    end

    methods
        function self = ColorMap(cmap, kwargs)
            % check optional inputs
            arguments (Input)
                cmap = dark2();
                kwargs.Last (1, 1) string {mustBeMember(kwargs.Last, ["hold", "wrap"])} = "hold"
            end
            last = kwargs.Last;
            % imports
            import matspace.plotting.colors.dark2
            % store properties
            if isa(cmap, 'matspace.plotting.colors.ColorMap')
                self.cmap = cmap.cmap;
                self.wrap = cmap.wrap;
                return
            elseif isempty(cmap)
                self.cmap = dark2();
            elseif isnumeric(cmap) && size(cmap, 2) == 3
                self.cmap = cmap;
            else
                error('Unsupported format');  % TODO: suppport validatecolor char names?
            end
            switch last
                case 'hold'
                    self.wrap = false;
                case 'wrap'
                    self.wrap = true;
                otherwise
                    error('Invalid command.');
            end
        end
    
        function [color] = get_color(self, value)
            % Get the color based on the scalar value.
            num_values = size(self.cmap, 1);
            if value > num_values
                if self.wrap
                    value = modd(value, num_values);
                else
                    value = num_values;
                end
            end
            color = self.cmap(value, :);
        end

        % TODO: set custom display properties
    end
end