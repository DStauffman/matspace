function [fig] = plot_bac(gui_settings, legal_limit)

% PLOT_BAC  plots the BAC (blood alcohol content) over time
%
% Input:
%     gui_settings : (class) GUI settings, see GuiSettings for more information
%
% Output:
%     fig : (scalar) figure handle [Figure]
%
% Prototype:
%     gui_settings         = GuiSettings();
%     gui_settings.profile = 'Katie';
%     gui_settings.height  = 60;
%     gui_settings.weight  = 105;
%     gui_settings.gender  = 'F';
%     gui_settings.bmi     = 20.50622;
%     gui_settings.hr1     = 1;
%     gui_settings.hr2     = 1.5;
%     gui_settings.hr3     = 2.2;
%     gui_settings.hr4     = 0.5;
%     gui_settings.hr5     = 0;
%     gui_settings.hr6     = 0;
%     plot_bac(gui_settings);
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.

% hard-coded values
time_drinks = [1; 2; 3; 4; 5; 6];
time_out    = linspace(0, 12, 1000);
ratio2per   = 100;

% check for optional values
switch nargin
    case 1
        legal_limit = nan; % 0.08 / 100;
    case 2
        % nop
    otherwise
        error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%s"', nargin);
end

% pull out information from gui_settings
drinks      = [gui_settings.hr1; gui_settings.hr2; gui_settings.hr3; ...
    gui_settings.hr4; gui_settings.hr5; gui_settings.hr6];
body_weight = gui_settings.weight;
name        = gui_settings.profile;

% calculate the BAC
bac = ratio2per * calculate_bac(time_drinks, drinks, time_out, body_weight);

% plot the data
fig = figure('name', ['BAC vs. Time for ', name]);
ax = axes;  
plot(ax, time_out, bac, '.-', 'DisplayName', 'BAC');
hold('on');
if ~isnan(legal_limit)
    plot(ax, [time_out(1); time_out(end)], ratio2per*legal_limit*[1; 1], '--', 'DisplayName', 'Legal Limit', 'Color', 'red', 'LineWidth', 2);
end
title(get(fig,'name'));
xlabel('Time [hr]');
ylabel('BAC [%]');
grid('on');
legend('show');