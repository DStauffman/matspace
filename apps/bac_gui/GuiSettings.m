classdef GuiSettings
    
    %% GuiSettings  is a class of settings used by the bac_gui.
    %
    % Input:
    %     handles .............  : |opt| (struct) GUI handles
    %         .button_plot       : [1x1 UIControl] button handle
    %         .edit_bmi          : [1x1 UIControl] bmi edit box handle
    %         .edit_height       : [1x1 UIControl] height edit box handle
    %         .edit_hr1          : [1x1 UIControl] hr1 edit box handle
    %         .edit_hr2          : [1x1 UIControl] hr2 edit box handle
    %         .edit_hr3          : [1x1 UIControl] hr3 edit box handle
    %         .edit_hr4          : [1x1 UIControl] hr4 edit box handle
    %         .edit_hr5          : [1x1 UIControl] hr5 edit box handle
    %         .edit_hr6          : [1x1 UIControl] hr6 edit box handle
    %         .edit_weight       : [1x1 UIControl] weight edit box handle
    %         .figure_bac_gui    : [1x1 Figure] figure handle
    %         .panel_consumption : [1x1 Panel] consumption panel handle
    %         .panel_profile     : [1x1 Panel] profile panel handle
    %         .popup_profile     : [1x1 UIControl] profile popup handle
    %         .radio_female      : [1x1 UIControl] female radio button handle
    %         .radio_male        : [1x1 UIControl] male radio button handle
    %         .text_bmi          : [1x1 UIControl] bmi text handle
    %         .text_height       : [1x1 UIControl] height text handle
    %         .text_hr1          : [1x1 UIControl] hr1 text handle
    %         .text_hr2          : [1x1 UIControl] hr2 text handle
    %         .text_hr3          : [1x1 UIControl] hr3 text handle
    %         .text_hr4          : [1x1 UIControl] hr4 text handle
    %         .text_hr5          : [1x1 UIControl] hr5 text handle
    %         .text_hr6          : [1x1 UIControl] hr6 text handle
    %         .text_profile      : [1x1 UIControl] profile text handle
    %         .text_weight       : [1x1 UIControl] weight text handle
    %         (gui_settings)     : (property) (class) copy of the gui_settings, see output below
    %         (token)            : (property) (scalar) token value to represent an unused box [num]
    %
    % Output:
    %     obj ............ : (class) GUI settings
    %         .name : (row) string specifying the name of the profile [char]
    %         .height : (scalar) height [inches]
    %         .weight : (scalar) weight [pounds]
    %         .gender : (scalar) gender, from {'F', 'M'} [char]
    %         .bmi    : (scalar) body mass index [kg/m^2]
    %         .hr1    : (scalar) Standard alcohol consumed in hour 1 [drinks]
    %         .hr2    : (scalar) Standard alcohol consumed in hour 2 [drinks]
    %         .hr3    : (scalar) Standard alcohol consumed in hour 3 [drinks]
    %         .hr4    : (scalar) Standard alcohol consumed in hour 4 [drinks]
    %         .hr5    : (scalar) Standard alcohol consumed in hour 5 [drinks]
    %         .hr6    : (scalar) Standard alcohol consumed in hour 6 [drinks]
    %
    % Prototype:
    %     % method 1
    %     gui_settings1           = GuiSettings();
    %     % method 2
    %     [gui_settings2,handles] = bac_gui();
    %     gui_settings3           = GuiSettings();
    %     gui_settings3           = gui_settings3.get_gui_settings(handles);
    %     compare_two_structures(gui_settings1,gui_settings2);
    %     compare_two_structures(gui_settings2,gui_settings3);
    %
    % See Also:
    %     bac_gui.m, update_gui.m
    %
    % Change Log:
    %     1.  Written by David Stauffer in May 2016.
    
    properties
        % public properties of class
        profile
        height
        weight
        gender
        age
        bmi
        hr1
        hr2
        hr3
        hr4
        hr5
        hr6
    end
    properties (Constant=true,Hidden=true)
        % constants for use within the class
        token       = -1;
        bmi_conv    = 703.0704; % converts from lb/in^2 to kg/m^2
    end
    
    methods
        function obj = GuiSettings(handles)
            %% class constructor method
            % header information is defined for the overall classdef and not duplicated here
            
            switch nargin
                case 0
                    % set defaults for no input case
                    obj.profile     = 'Default';
                    obj.height      = GuiSettings.token;
                    obj.weight      = GuiSettings.token;
                    obj.gender      = 'F';
                    obj.age         = GuiSettings.token;
                    obj.bmi         = GuiSettings.token;
                    obj.hr1         = 0;
                    obj.hr2         = 0;
                    obj.hr3         = 0;
                    obj.hr4         = 0;
                    obj.hr5         = 0;
                    obj.hr6         = 0;
                case 1
                    obj = set_from_handles(handles);
                otherwise
                    error('bacGui:badNargin', 'Unexpected number of inputs.');
            end
        end
        
        function obj = get_gui_settings(obj,handles)
            %% GET_GUI_SETTINGS  gets the current gui settings based on the handles from the GUI.
            %
            % Summary:
            %     This method loops through all the properties of the gui handles structure, and updates the
            %     corresponding properties of the GuiSettings class instance.
            %
            % Input:
            %     obj     : (GuiSettings class) instance that is calling this method, described in detail above
            %     handles : (struct) handles object created by the bac_gui, described in detail above
            %
            % Output:
            %     obj     : (GuiSettings class) with updated properties
            %
            % Prototype:
            %     [gui_settings, handles] = bac_gui();
            %     gui_settings            = gui_settings.get_gui_settings(handles);
            %
            % See Also:
            %     bac_gui
            %
            % Change Log:
            %     1.  Written by David Stauffer in May 2016.
            
            % check hard-coded values for consistency with handles
            if GuiSettings.token ~= getappdata(handles.figure_bac_gui, 'token')
                error('bacGui:badToken', 'Unexpected token in handles.');
            end
            % update gui setting from handles
            obj.profile     = get(handles.popup_profile, 'String');
            temp            = get(handles.edit_height, 'String');
            if isempty(temp)
                obj.height  = GuiSettings.token;
            else
                obj.height  = str2double(temp);
            end
            temp            = get(handles.edit_weight, 'String');
            if isempty(temp)
                obj.weight  = GuiSettings.token;
            else
                obj.weight  = str2double(temp);
            end
            temp            = get(handles.edit_age, 'String');
            if isempty(temp)
                obj.age     = GuiSettings.token;
            else
                obj.age     = str2double(temp);
            end
            temp            = get(handles.edit_bmi, 'String');
            if isempty(temp)
                obj.bmi     = GuiSettings.token;
            else
                obj.bmi     = str2double(temp);
            end
            obj.hr1         = str2double(get(handles.edit_hr1, 'String'));
            obj.hr2         = str2double(get(handles.edit_hr2, 'String'));
            obj.hr3         = str2double(get(handles.edit_hr3, 'String'));
            obj.hr4         = str2double(get(handles.edit_hr4, 'String'));
            obj.hr5         = str2double(get(handles.edit_hr5, 'String'));
            obj.hr6         = str2double(get(handles.edit_hr6, 'String'));
        end
    end
end