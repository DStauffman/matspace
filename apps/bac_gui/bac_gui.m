function varargout = bac_gui(varargin) %#ok<*DEFNU>

% BAC_GUI  is the m-file used to run the BAC_GUI.fig.
%
% Summary:
%     BAC_GUI, by itself, creates a new GUI or raises the existing singleton.
%
% Input:
%     varargin: optional GUI Callbacks for internal calling only
%
% Output:
%     gui_settings : (class)  GUI settings, see GuiSettings for more information
%     handles      : (struct) GUI handles, see get_gui_settings for more information
%
% Prototype:
%     bac_gui;
%
% See Also:
%     bac_gui.fig
%
% Change Log:
%     1.  Started by David C. Stauffer in May 2016 as a template for Katie to use on her project.

%% Create GUI Window
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bac_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @bac_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function bac_gui_OpeningFcn(hObject, ~, handles, varargin) %#ok<VANUS>
% --- Executes just before GUI is made visible.
if ~isappdata(hObject,'gui_settings')
    setappdata(hObject,'gui_settings',GuiSettings());
end
handles = update_gui(getappdata(hObject,'gui_settings'),handles);
if true
    % DCS: note that I don't like how this repeats logic here.  Try for a better solution in the future.
    % The problem is that the CreateFcn for the popup box runs before all the handles exist, so you have
    % to wait until later to update the GUI with the saved information for any profiles that were found.
    % potentially reload from a given profile name
    profiles  = get(handles.popup_profile, 'String');
    selection = get(handles.popup_profile, 'Value');
    [profile_found, gui_settings] = get_settings_from_name(profiles{selection});
    if profile_found
        setappdata(handles.figure_bac_gui, 'gui_settings', gui_settings);
    else
        error('bacGui:profileSelection', 'Profile "%s" was not found.', profiles{selection});
    end
    handles = update_gui(gui_settings, handles);
end
% Update handles structure
guidata(hObject,handles);


function varargout = bac_gui_OutputFcn(hObject, ~, handles)
% --- Outputs from this function are returned to the command line.
varargout{1}  = getappdata(hObject,'gui_settings');
varargout{2}  = orderfields(handles);


%% Plot Button
function button_plot_Callback(~, ~, handles)
% --- Executes on button press in button_plot.

% get the current gui_settings
gui_settings = getappdata(handles.figure_bac_gui, 'gui_settings');

% call the plotting function
legal_limit = 0.08/100;
fig = plot_bac(gui_settings, legal_limit);

% save the plot
print(fig, '-dpng', fullfile(get_gui_root(), [get(fig, 'name'), '.png']));


%% Save Button
function button_save_Callback(~, ~, handles)
% --- Executes on button press in button_save.

% get the current gui_settings
gui_settings = getappdata(handles.figure_bac_gui, 'gui_settings');

% save them to the given profile name
filename = fullfile(get_gui_root(), [strrep(gui_settings.profile, ' ', '_'), '.mat']);
save(filename, 'gui_settings');


%% Edit Box Callbacks
function edit_box_number_Callback(hObject, ~, handles, name)
% Callback for any edit box that should be a valid double

% get the current gui_settings
gui_settings = getappdata(handles.figure_bac_gui, 'gui_settings');
% get the proposed new value
new          = get(hObject,'String');
if isempty(new)
    % if the new value is empty, then use the token to update the gui_settings
    gui_settings.(name) = gui_settings.token;
else
    % check that the new value is valid, if so update it, else display the error
    value = str2double(new);
    if isnan(value)
        if gui_settings.(name) == gui_settings.token
            display_error(hObject, '');
        else
            display_error(hObject, gui_settings.(name));
        end
    else
        gui_settings.(name) = value;
    end
end
% update any new information back into the gui
setappdata(handles.figure_bac_gui, 'gui_settings', gui_settings);
% call the update function to calculate and update any derived fields (like BMI)
handles = update_gui(gui_settings, handles);
guidata(hObject,handles);


function popup_profile_CreateFcn(hObject, ~, handles)
% --- Executes during object creation, after setting all properties.

% find all the existing profiles
profiles = get_profiles();

% add the New+ option
if isempty(profiles)
    profiles = {'Default', 'New+'};
    filename = fullfile(get_gui_root(), 'Default.mat');
    gui_settings = GuiSettings(); %#ok<NASGU>
    save(filename, 'gui_settings');
else
    profiles{end+1} = 'New+';
end
set(hObject, 'String', profiles);
set(hObject, 'Value', 1);
guidata(hObject,handles);


%% Popup Box Callbacks
function popup_profile_Callback(hObject, ~, handles)
% --- Executes on selection change in popup_profile.

% get the current gui_settings
gui_settings = getappdata(handles.figure_bac_gui, 'gui_settings');
% decide which profile was selected
profiles  = get(hObject, 'String');
selection = get(hObject, 'Value');
if selection == length(profiles)
    % New+ was chosen, so make a new profile
    answer = inputdlg('Please enter the profile name:', 'Profile Name');
    if ~isempty(answer)
        % create a new default gui_settings
        gui_settings = GuiSettings();
        % fill in the name
        gui_settings.profile = answer{1};
        profiles{end} = answer{1};
        [~, sort_ix] = sort(profiles);
        set(hObject, 'String', vertcat(profiles(sort_ix), 'New+'));
        set(hObject, 'Value', sort_ix(end));
        handles = update_gui(gui_settings, handles);
    end
else
    % update the selection
    [profile_found, gui_settings] = get_settings_from_name(profiles{selection});
    if profile_found
        handles = update_gui(gui_settings, handles);
    else
        error('bacGui:profileSelection', 'Profile "%s" was not found.', profiles{selection});
    end
end
% update any new information back into the gui
setappdata(handles.figure_bac_gui, 'gui_settings', gui_settings);
guidata(hObject,handles);


%% Gender radio buttons
function radio_Callback(hObject, ~, handles)
% --- Executes on button press in radio group.

% get the current gui_settings
gui_settings = getappdata(handles.figure_bac_gui,'gui_settings');
% get the proposed new value
new          = get(hObject, 'Value');
if hObject == handles.radio_female
    if new
        gui_settings.gender = 'F';
    end
elseif hObject == handles.radio_male
    if new
        gui_settings.gender = 'M';
    end
end
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
% update any new information back into the gui
setappdata(handles.figure_bac_gui,'gui_settings',gui_settings);
guidata(hObject,handles);


%% Support functions - get_gui_root
function [gui_dir] = get_gui_root()
% Gets the root location of the GUI.

% get the fullpath name to this m file
path_name = mfilename('fullpath');

% find all the string separators
ix        = strfind(path_name,filesep);

% keep the path name up to the last file separator
gui_dir  = path_name(1:ix(end));


%% Support functions - get_settings_from_name
function [profile_found, gui_settings] = get_settings_from_name(name)
% Gets the gui_settings information from a given name

% initialize output
profile_found = false;
gui_settings = [];

% get the filename to try and load
filename = fullfile(get_gui_root(), [strrep(name, ' ', '_'), '.mat']);
if exist(filename, 'file')
    % load the file and see if it has a gui_settings object
    temp = load(filename, 'gui_settings');
    if isa(temp.gui_settings, 'GuiSettings')
        % if everything worked, then update outputs
        profile_found = true;
        gui_settings = temp.gui_settings;
    end
end


%% Support functions - get_profiles
function [profiles] = get_profiles()
% Gets the list of profiles by looking through all the .mat files in the GUI directory

% initialize the output
profiles = {};
% get the list of files to check
files = dir(get_gui_root());
% loop through the files
for i = 3:length(files)
    % alias this file
    this_file = files(i).name;
    % get the file extension
    [~, ~, ext] = fileparts(this_file);
    % see if this is a mat file
    if strcmp(ext,'.mat')
        % if it's a mat file, see if it has a gui_settings variable of the correct class
        temp = whos('-file', this_file, 'gui_settings');
        if ~isempty(temp) && strcmp(temp.class, 'GuiSettings')
            % if everything is good, then load it and save to the list
            temp2 = load(this_file, 'gui_settings');
            profiles{end+1} = temp2.gui_settings.profile; %#ok<AGROW>
        end
    end
end
% once the list is made, put it in alphabetical order before outputting
profiles = sort(profiles);