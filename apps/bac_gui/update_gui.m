function [handles] = update_gui(gui_settings,handles)

% UPDATE_GUI  updates the GUI handles based on the current GUI settings.
%
% Input:
%     gui_settings : (class) GUI settings, see GuiSettings for more information
%     handles      : (struct) GUI handels, see get_gui_settings for more information
%
% Output:
%     (None)
%
% Prototype:
%     [gui_settings,handles] = bac_gui;
%     gui_settings.height    = 66;
%     handles                = update_gui(gui_settings,handles);
%     guidata(handles.figure_bac_gui,handles);
%
% See Also:
%     bac_gui.m, GuiSettings.m
%
% Change Log:
%     1.  Written by David C. Stauffer in May 2016.

% alias the token
token = gui_settings.token;

% profile - No Op

% height
if gui_settings.height == token
    set(handles.edit_height, 'String', '');
else
    set(handles.edit_height, 'String', num2str(gui_settings.height));
end

% weight
if gui_settings.weight == token
    set(handles.edit_weight, 'String', '');
else
    set(handles.edit_weight, 'String', num2str(gui_settings.weight));
end

% bmi
if gui_settings.bmi == token
    if gui_settings.weight ~= token && gui_settings.height ~= token
        gui_settings.bmi = calculate_bmi(gui_settings.height, gui_settings.weight, ...
            gui_settings.gender, gui_settings.bmi_conv);
        set(handles.edit_bmi, 'String', num2str(gui_settings.bmi));
    else
        set(handles.edit_bmi, 'String', '');
    end
else
    set(handles.edit_bmi, 'String', num2str(gui_settings.bmi));
end

% gender
switch gui_settings.gender
    case 'F'
        set(handles.radio_female, 'Value', 1);
        set(handles.radio_male,   'Value', 0);
    case 'M'
        set(handles.radio_female, 'Value', 0);
        set(handles.radio_male,   'Value', 1);
    otherwise
        error('bacGui:badGender', 'Unexpected value for gender.');
end

% drinks per hour
set(handles.edit_hr1, 'String', num2str(gui_settings.hr1));
set(handles.edit_hr2, 'String', num2str(gui_settings.hr2));
set(handles.edit_hr3, 'String', num2str(gui_settings.hr3));
set(handles.edit_hr4, 'String', num2str(gui_settings.hr4));
set(handles.edit_hr5, 'String', num2str(gui_settings.hr5));
set(handles.edit_hr6, 'String', num2str(gui_settings.hr6));

% update the copy of gui_settings that is in handles
setappdata(handles.figure_bac_gui, 'gui_settings', gui_settings);