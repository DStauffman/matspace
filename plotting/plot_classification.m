function [] = plot_classification(fig_hand, classification, test)

% PLOT_CLASSIFICATION  displays the classification in a box on each figure.
%
% Summary:
%     This function draws a box on the existing figure windows, with the option of printing
%     another box for testing purposes.
%
% Input:
%     fig_hand       : (1xN) vector of figure handles [num]
%     classification : (row) string specifying classification to use, from {'U','C','S','TS'} [char]
%     test           : (true/false) flag to specify if this is a test or a real application [bool]
%
% Output:
%     (NONE)
%
% Prototype:
%     f1 = figure;
%     plot([0 1],[0 1],'.-b');
%     plot_classification(f1,'U');
%     f2 = figure;
%     plot(0,0);
%     plot_classification(f2,'S',1);
%
%     % clean up
%     close([f1 f2]);
%
% See Also:
%     setup_plots
%
% Change Log:
%     1.  Written by David Stauffer in Feb 2010.
%     2.  Updated by David Stauffer in Sep 2011 to not be effected by panning and zooming.
%     3.  Incorporated by David C. Stauffer into DStauffman library in Nov 2016.

%% check for optional inputs
switch nargin
    case 2
        test = false;
    case 3
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

%% loop through each figure
for i = 1:length(fig_hand)
    % get the position of the axis within the figure
    ax  = get(fig_hand(i),'CurrentAxes');
    pos = get(ax,'Position');
    % plot warning before trying to draw the other box
    if test
        w = 0.6;
        h = 0.1;
        annotation(fig_hand(i),'textbox','Position',[pos(1)+pos(3)/2-w/2,pos(2)+pos(4)-h,w,h],...
            'String','This plot classification is labeled for test purposes only',...
            'HorizontalAlignment','Center','VerticalAlignment','Middle',...
            'FontSize',8,'FontWeight','Bold','Color','r','EdgeColor','r','LineWidth',2);
    end
    % add classification box
    switch classification
        case 'U'
            color    = [0 0 0];
            text_str = 'UNCLASSIFIED';
        case 'C'
            color    = [0 0 1];
            text_str = 'CONFIDENTIAL';
        case 'S'
            color    = [1 0 0];
            text_str = 'SECRET';
        case {'TS','T'}
            color    = [1 0.65 0];
            text_str = 'TOP SECRET';
        otherwise
            error('dstauffman:BadClassification', 'Unexpected value for classification: "%s".', ...
                classification);
    end
    w = 0.2;
    h = 0.1;
    annotation(fig_hand(i),'textbox','Position',[pos(1)+pos(3)-w,pos(2),w,h],'String',text_str,...
        'HorizontalAlignment','Center','VerticalAlignment','Middle',...
        'FontSize',8,'FontWeight','Bold','Color',color,'EdgeColor',color,'LineWidth',2);
end