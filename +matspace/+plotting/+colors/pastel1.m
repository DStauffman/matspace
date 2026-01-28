function [colors] = pastel1()

% PASTEL1  is the Pastel1 colormap from Python matplotlib.
%
% Input:
%     (None)
%
% Output
%     colors : (3x9) table of colors that are useful to plot with
%
% Prototype:
%     colors = matspace.plotting.colors.pastel1();
%     % plotting example:
%     surf(peaks);
%     colormap('matspace.plotting.colors.pastel1');
%     colorbar;
%
% See Also:
%     matspace.plotting.colors.get_python_colormap, colormap
%
% Change Log:
%     1.  Written by David C. Stauffer in January 2026.

% matspace.plotting.colors.get_python_colormap('Pastel1')
colors = [...
     0.984313725490196         0.705882352941177         0.682352941176471
     0.701960784313725         0.803921568627451         0.890196078431372
                   0.8          0.92156862745098         0.772549019607843
     0.870588235294118         0.796078431372549         0.894117647058824
     0.996078431372549         0.850980392156863         0.650980392156863
                     1                         1                       0.8
     0.898039215686275         0.847058823529412         0.741176470588235
     0.992156862745098         0.854901960784314         0.925490196078431
     0.949019607843137         0.949019607843137         0.949019607843137];