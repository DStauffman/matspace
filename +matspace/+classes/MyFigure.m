classdef MyFigure < matlab.ui.Figure

    % Custom Figure with sorting based on Number

    methods
        function obj = MyFigure(varargin)
            obj@matlab.ui.Figure(varargin)
        end

        function [obj, idx] = sort(obj, varargin)
            % Sort Figure array with respect to 'Number' property
            [~,idx] = sort([obj.Number], varargin{:});
            obj = obj(idx);
        end
    end
end