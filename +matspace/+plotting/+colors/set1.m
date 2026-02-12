function [colors] = set1()

% SET1  is the Set1 colormap from Python matplotlib.
%
% Input:
%     (None)
%
% Output
%     colors : (9x3) table of colors that are useful to plot with
%
% Prototype:
%     colors = matspace.plotting.colors.set1();
%     assert(all(size(colors) == [9 3]));
%     assert(min(colors, [], 'all') >= 0);
%     assert(max(colors, [], 'all') <= 1);
%     % plotting example:
%     s = surf(peaks);
%     colormap('matspace.plotting.colors.set1');
%     colorbar;
%
%     % Close plot
%     close(s.Parent.Parent);
%
% See Also:
%     matspace.plotting.colors.get_python_colormap, colormap
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2026.

% matspace.plotting.colors.get_python_colormap('Set1')
colors = [...
     0.894117647058824         0.101960784313725         0.109803921568627
     0.215686274509804         0.494117647058824          0.72156862745098
     0.301960784313725         0.686274509803922         0.290196078431373
     0.596078431372549         0.305882352941176          0.63921568627451
                     1         0.498039215686275                         0
                     1                         1                       0.2
     0.650980392156863         0.337254901960784         0.156862745098039
     0.968627450980392         0.505882352941176         0.749019607843137
                   0.6                       0.6                       0.6];