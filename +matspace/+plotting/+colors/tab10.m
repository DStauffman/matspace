function [colors] = tab10()

% TAB10  is the tab10 colormap from Python matplotlib.
%
% Input:
%     (None)
%
% Output
%     colors : (10x3) table of 10 colors that are useful to plot with
%
% Prototype:
%     colors = matspace.plotting.colors.tab10();
%     assert(all(size(colors) == [10 3]));
%     assert(min(colors, [], 'all') >= 0);
%     assert(max(colors, [], 'all') <= 1);
%     % plotting example:
%     s = surf(peaks);
%     colormap('matspace.plotting.colors.tab10');
%     colorbar;
%
%     % Close plot
%     close(s.Parent.Parent);
%
% See Also:
%     matspace.plotting.colors.get_python_colormap, colormap
%
% Change Log:
%     1.  Copied from matplotlib's colormap of the same name by David C. Stauffer in February 2019.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

colors = [...
      0.12156862745098         0.466666666666667         0.705882352941177
                     1         0.498039215686275        0.0549019607843137
     0.172549019607843         0.627450980392157         0.172549019607843
      0.83921568627451         0.152941176470588         0.156862745098039
     0.580392156862745         0.403921568627451         0.741176470588235
     0.549019607843137         0.337254901960784         0.294117647058824
     0.890196078431372         0.466666666666667          0.76078431372549
     0.498039215686275         0.498039215686275         0.498039215686275
     0.737254901960784         0.741176470588235         0.133333333333333
    0.0901960784313725         0.745098039215686         0.811764705882353];