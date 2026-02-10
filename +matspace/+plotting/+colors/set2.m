function [colors] = set2()

% SET2  is the Set2 colormap from Python matplotlib.
%
% Input:
%     (None)
%
% Output
%     colors : (8x3) table of colors that are useful to plot with
%
% Prototype:
%     colors = matspace.plotting.colors.set2();
%     assert(all(size(colors) == [8 3]));
%     assert(min(colors, 'all') >= 0);
%     assert(max(colors, 'all') <= 1);
%     % plotting example:
%     surf(peaks);
%     colormap('matspace.plotting.colors.set2');
%     colorbar;
%
% See Also:
%     matspace.plotting.colors.get_python_colormap, colormap
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2026.

% matspace.plotting.colors.get_python_colormap('Set2')
colors = [...
                   0.4          0.76078431372549         0.647058823529412
     0.988235294117647         0.552941176470588         0.384313725490196
     0.552941176470588         0.627450980392157         0.796078431372549
     0.905882352941176         0.541176470588235         0.764705882352941
     0.650980392156863         0.847058823529412         0.329411764705882
                     1         0.850980392156863         0.184313725490196
     0.898039215686275         0.768627450980392         0.580392156862745
     0.701960784313725         0.701960784313725         0.701960784313725];