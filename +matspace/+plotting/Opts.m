classdef Opts

    % OPTS  defines the class for all the possible plotting options.
    %
    % Input:
    %     overrides : (struct) existing OPTS instance or similar struct to use to override the defaults
    %
    % Output:
    %     OPTS ......... : (class) plotting options
    %         .case_name : (row) string specifying the name of the case to be plotted [char]
    %         .date_zero : (1x6) datevec (or datetime) of t = 0 time [year month day hour minute second]
    %         .save_plot : (scalar) true/false flag for whether to save the plots [bool]
    %         .save_path : (row) string specifying the location for the plots to be saved [char]
    %         .show_plot : (scalar) true/false flag to show the plots or only save to disk [bool]
    %         .show_link : (scalar) true/false flag to show a link to the folder where the plots were saved [bool]
    %         .plot_type : (row) string specifying the type of plot to save to disk, from {'png','jpg','fig','emf'} [char]
    %         .sub_plots : (scalar) true/false flag specifying whether to plot as subplots or separate figures [bool]
    %         .sing_line : (scalar) true/false flag specifying to only plot one line per axes, using subplots as necessary [bool]
    %         .plot_locs : (row) string specifying plot location, from: {'full','fullscreen','huge','left','right','top','bottom','tile'} [char]
    %         .disp_xmin : (scalar) minimum time to display on plot [sec]
    %         .disp_xmax : (scalar) maximum time to display on plot [sec]
    %         .rms_xmin  : (scalar) minimum time from which to begin RMS calculations [sec]
    %         .rms_xmax  : (scalar) maximum time from which to end RMS calculations [sec]
    %         .show_rms  : (scalar) true/false flag for whether to show the RMS in the legend [bool]
    %         .use_mean  : (scalar) true/false flag for using mean instead of RMS for legend calculations [bool]
    %         .lab_vert  : (scalar) true/false flag for whether to label the RMS/Mean line in the legend [bool]
    %         .show_zero : (scalar) true/false flag for whether to show Y=0 on the plot axis [bool]
    %         .quat_comp : (scalar) true/false flag to plot quaternion component differences or just the angle [bool]
    %         .show_xtra : (scalar) true/false flag to show extra points in one vector or the other when plotting differences [bool]
    %         .time_base : (row) string specifying the base units of time, typically from {'sec', 'months'} [char]
    %         .time_unit : (row) string specifying the time unit for the x axis, from {'', 'sec', 'min', 'hr', 'day', 'month', 'year'} [char]
    %         .colormap  : (row) string specifying the name of the colormap to use [char]
    %         .leg_spot  : (row) string specifying the location of the legend, from {'north', 'south', 'east', 'west',
    %             'northeast', 'northwest', 'southeast', 'southwest', 'northoutside', 'southoutside', 'eastoutside',
    %             'westoutside', 'northeastoutside', 'northwestoutside', 'southeastoutside', 'southwestoutside',
    %             'best', 'bestoutside'} [char]
    %         .classify  : (row) string specifying the classification level to put on plots [char]
    %         .names     : (1xN) of (string) specifying the name of the data structures to be plotted [char]
    %
    % Prototype:
    %     OPTS = matspace.plotting.Opts();
    %
    % Change Log:
    %     1.  Written by David C. Stauffer in September 2013.
    %     2.  Added to matspace library in December 2015.
    %     3.  Updated by David C. Stauffer in January 2018 to use string array for names.
    %     4.  Updated by David C. Stauffer in April 2020 to put into a package.

    properties
        case_name,
        date_zero,
        save_plot,
        save_path,
        show_plot,
        show_link,
        plot_type,
        sub_plots,
        sing_line,
        plot_locs,
        disp_xmin,
        disp_xmax,
        rms_xmin,
        rms_xmax,
        show_rms,
        use_mean,
        lab_vert,
        show_zero,
        quat_comp,
        show_xtra,
        time_base,
        time_unit,
        colormap,
        leg_spot,
        classify,
        names,
    end

    methods
        function OPTS = Opts(overrides)
            % check optional inputs
            switch nargin
                case 0
                    overrides = struct();
                case 1
                    % if already a class instance, then just pass it through unmodified
                    if isa(overrides, 'matspace.plotting.Opts')
                        OPTS = overrides;
                        return
                    elseif isstruct(overrides) || isempty(overrides)
                        % nop
                    else
                        error('matspace:UnexpectedType', 'Unexpected input type.');
                    end
                otherwise
                    error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
            end
            % build new output class with defaults
            OPTS.case_name = '';
            OPTS.date_zero = [];
            OPTS.save_plot = false;
            OPTS.save_path = pwd;
            OPTS.show_plot = true;
            OPTS.show_link = false;
            OPTS.plot_type = 'png';
            OPTS.sub_plots = true;
            OPTS.sing_line = false;
            OPTS.plot_locs = 'default';
            OPTS.disp_xmin = -inf;
            OPTS.disp_xmax = inf;
            OPTS.rms_xmin  = -inf;
            OPTS.rms_xmax  = inf;
            OPTS.show_rms  = true;
            OPTS.use_mean  = false;
            OPTS.lab_vert  = true;
            OPTS.show_zero = false;
            OPTS.quat_comp = false;
            OPTS.show_xtra = true;
            OPTS.time_base = 'sec'; % Nominally seconds or years, time when no scaling done
            OPTS.time_unit = ''; % Time unit to display plots in, potentially scaling from the base
            OPTS.colormap  = '';
            OPTS.leg_spot  = 'best';
            OPTS.classify  = '';
            OPTS.names     = "";

            % get the fields from the overrides and store them to OPTS
            if ~isempty(overrides)
                fields = fieldnames(overrides);
                for i = 1:length(fields)
                    OPTS.(fields{i}) = overrides.(fields{i});
                end
            end
        end

        function [name] = get_names(self, ix)
            % Get the specified name from the list.
            if length(self.names) >= ix
                name = self.names{ix};
            else
                name = '';
            end
        end

        function [name_one, name_two] = get_name_one_and_two(self, kwargs)
            % Get the first and second names from kwargs, or class names, or this opts structure.
            arguments
                self
                kwargs.NameOne {mustBeTextScalar}
                kwargs.NameTwo {mustBeTextScalar}
                kwargs.Kf1 {mustBeStructOrEmpty} = []
                kwargs.Kf2 {mustBeStructOrEmpty} = []
            end
            if isempty(kwargs.Kf1)
                name_one = self.get_names(1);
            elseif ~isfield(kwargs.Kf2, 'Name') || isempty(kwargs.Kf1.Name)
                name_one = self.get_names(1);
            else
                name_one = kwargs.Kf1.Name;
            end
            if isempty(kwargs.Kf2)
                name_two = self.get_names(2);
            elseif ~isfield(kwargs.Kf2, 'Name') || isempty(kwargs.Kf2.Name)
                name_two = self.get_names(2);
            else
                name_two = kwargs.Kf2.Name;
            end
        end

        function [start_date] = get_date_zero_str(self, date)
            % Gets a string representation of date_zero, typically used to print on an X axis.
            %
            % Returns
            % -------
            % start_date : str
            %     String representing the date of time zero.
            %
            % Examples
            % --------
            %     opts = matspace.plotting.Opts();
            %     opts.date_zero = datetime(2019, 4, 1, 18, 0, 0);
            %     assert(strcmp(opts.get_date_zero_str(), ' t(0) = 01-Apr-2019 18:00:00 Z');
            TIMESTR_FORMAT = 'dd-MMM-uuuu HH:mm:ss';
            if nargin == 1 || isempty(date)
                if isempty(self.date_zero) || isnat(self.date_zero)
                    start_date = '';
                else
                    start_date = ['  t(0) = ',char(self.date_zero, TIMESTR_FORMAT),' Z'];
                end
            elseif isa(date, 'datetime')
                start_date = ['  t(0) = ',char(date, TIMESTR_FORMAT),' Z'];
            else
                temp_date = datetime(date);
                start_date = ['  t(0) = ',char(temp_date, TIMESTR_FORMAT),' Z'];
            end
        end

        function [disp_xmin, disp_xmax, rms_xmin, rms_xmax] = get_time_limits(self)
            % Returns the display and RMS limits in the current time units.

            import matspace.plotting.convert_time_units

            function [new_value] = convert(value)
                if ~isempty(value) && isfinite(value)
                    new_value = convert_time_units(value, self.time_base, self.time_unit);
                else
                    new_value = value;
                end
            end

            if strcmp(self.time_base, 'datetime')
                disp_xmin = self.disp_xmin;
                disp_xmax = self.disp_xmax;
                rms_xmin  = self.rms_xmin;
                rms_xmax  = self.rms_xmax;
                return
            end

            disp_xmin = convert(self.disp_xmin);
            disp_xmax = convert(self.disp_xmax);
            rms_xmin  = convert(self.rms_xmin);
            rms_xmax  = convert(self.rms_xmax);
        end

        function [obj] = convert_dates(obj, time_units)
            % Potentially convert times to dates
            import matspace.plotting.convert_time_to_date
            if strcmp(obj.time_unit, time_units)
                % no conversion needed
                return
            end
            if strcmp(time_units, 'datetime')
                obj.time_base = 'datetime';
                obj.time_unit = 'datetime';
                time_units = 'sec';
            else
                obj.time_unit = time_units;
            end
            obj.disp_xmin = convert_time_to_date(obj.disp_xmin, obj.date_zero, time_units);
            obj.disp_xmax = convert_time_to_date(obj.disp_xmax, obj.date_zero, time_units);
            obj.rms_xmin  = convert_time_to_date(obj.rms_xmin,  obj.date_zero, time_units);
            obj.rms_xmax  = convert_time_to_date(obj.rms_xmax,  obj.date_zero, time_units);
        end

        function [non_defaults] = pprint_non_defaults(obj)
            % Displays only the non-default values within the structure

            % Imports
            import matspace.plotting.Opts
            % create default for comparison
            Nom = Opts();
            % get the fields to compare
            fields = fieldnames(Nom);
            % initialize a structure to hold the non-defaults
            non_defaults = [];
            % loop through the fields
            for i = 1:length(fields)
                % alias this field
                this_field = fields{i};
                % determine how to compare
                if ischar(Nom.(this_field))
                    % if text, do a string comparison
                    if ~strcmp(obj.(this_field), Nom.(this_field))
                        non_defaults.(this_field) = obj.(this_field);
                    end
                else
                    % otherwise, do a numeric comparsion, which can be a vector (but not 2D matrix)
                    if any(obj.(this_field) ~= Nom.(this_field))
                        non_defaults.(this_field) = obj.(this_field);
                    end
                end
            end
            % display the resulting structure using built-in matlab options
            disp(non_defaults);
        end
    end
end


%% Custom validator functions
function mustBeStructOrEmpty(x)
    if ~isempty(x) && ~isstruct(x)
        throwAsCaller(MException('matspace:Opts:BadKf','Input must be empty or a GND structure.'))
    end
end