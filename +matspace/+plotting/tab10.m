function [colors] = tab10()

% TAB10  is the tab10 colormap from Python matplotlib.
%
% Input:
%     (None)
%
% Output
%     colors : (3x10) table of 10 colors that are useful to plot with
%
% Prototype:
%     colors = matspace.plotting.tab10();
%     % plotting example:
%     surf(peaks);
%     colormap('matspace.plotting.tab10');
%     colorbar;
%
% See Also:
%     matspace.plotting.viridis, parula, jet, hsv, colormap
%
% Change Log:
%     1.  Copied from matplotlib's colormap of the same name by David C. Stauffer in February 2019.
%     2.  Updated by David C. Stauffer in April 2020 to put into a package.

colors = [...
    0.12156862745098039, 0.4666666666666667,  0.7058823529411765;
    1.00000000000000000, 0.4980392156862745,  0.054901960784313725;
    0.17254901960784313, 0.6274509803921569,  0.17254901960784313;
    0.8392156862745098,  0.15294117647058825, 0.1568627450980392;
    0.5803921568627451,  0.403921568627451,   0.7411764705882353;
    0.5490196078431373,  0.33725490196078434, 0.29411764705882354;
    0.8901960784313725,  0.4666666666666667,  0.7607843137254902;
    0.4980392156862745,  0.4980392156862745,  0.4980392156862745;
    0.7372549019607844,  0.7411764705882353,  0.13333333333333333;
    0.09019607843137255, 0.7450980392156863,  0.8117647058823529];