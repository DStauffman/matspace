classdef Opts

    % OPTS  defines the class for all the possible plotting options.
    %
    % Input:
    %     overrides : (struct) existing OPTS instance or similar struct to use to override the defaults
    %
    % Output:
    %     OPTS ......... : (class) plotting options
    %         .case_name : (row) string specifying the name of the case to be plotted [char]
    %         .date_zero : (1x6) datevec of t = 0 time [year month day hour minute second]
    %         .save_plot : (scalar) true/false flag for whether to save the plots [bool]
    %         .save_path : (row) string specifying the location for the plots to be saved [char]
    %         .show_plot : (scalar) true/false flag to show the plots or only save to disk [bool]
    %         .plot_type : (row) string specifying the type of plot to save to disk, from {'png','jpg','fig','emf'} [char]
    %         .sub_plots : (scalar) true/false flag specifying whether to plot as subplots or separate figures [bool]
    %         .disp_xmin : (scalar) minimum time to display on plot [months]
    %         .disp_xmax : (scalar) maximum time to display on plot [months]
    %         .rms_xmin  : (scalar) minimum time from which to begin RMS calculations [months]
    %         .rms_xmax  : (scalar) maximum time from which to end RMS calculations [months]
    %         .show_rms  : (scalar) true/false flag for whether to show the RMS in the legend [bool]
    %         .use_mean  : (scalar) true/false flag for using mean instead of RMS for legend calculations [bool]
    %         .show_zero : (scalar) true/false flag for whether to show Y=0 on the plot axis [bool]
    %         .quat_comp : (scalar) true/false flag to plot quaternion component differences or just the angle [bool]
    %         .time_base : (row) string specifying the base units of time, typically from {'sec', 'months'} [char]
    %         .time_unit : (row) string specifying the time unit for the x axis, from {'', 'sec', 'min', 'hr', 'day'} [char]
    %         .vert_fact : (row) string specifying the vertical factor to apply to the Y axis, [char]
    %             from: {'yotta','zetta','exa','peta','tera','giga','mega','kilo','hecto','deca',
    %             'unity','deci','centi','milli', 'micro','nano','pico','femto','atto','zepto','yocto'}
    %         .colormap  : (row) string specifying the name of the colormap to use [char]
    %         .names     : (1xN) of (string) specifying the name of the data structures to be plotted [char]
    %
    % Prototype:
    %     OPTS = Opts();
    %
    % Change Log:
    %     1.  Written by David C. Stauffer in September 2013.
    %     2.  Added to DStauffman MATLAB library in December 2015.
    %     3.  Updated by David C. Stauffer in January 2018 to use string array for names.
    properties
        case_name,
        date_zero,
        save_plot,
        save_path,
        show_plot,
        plot_type,
        sub_plots,
        disp_xmin,
        disp_xmax,
        rms_xmin,
        rms_xmax,
        show_rms,
        use_mean,
        show_zero,
        quat_comp,
        time_base,
        time_unit,
        vert_fact,
        colormap,
        names,
    end
    
    methods
        function OPTS = Opts(overrides)
            % store OPTS defaults
            OPTS.case_name = '';
            OPTS.date_zero = [];
            OPTS.save_plot = false;
            OPTS.save_path = pwd;
            OPTS.show_plot = true;
            OPTS.plot_type = 'png';
            OPTS.sub_plots = true;
            OPTS.disp_xmin = -inf;
            OPTS.disp_xmax = inf;
            OPTS.rms_xmin  = -inf;
            OPTS.rms_xmax  = inf;
            OPTS.show_rms  = true;
            OPTS.use_mean  = false;
            OPTS.show_zero = true;
            OPTS.quat_comp = false;
            OPTS.time_base = 'sec'; % Nominally seconds or years, time when no scaling done
            OPTS.time_unit = ''; % Time unit to display plots in, potentially scaling from the base
            OPTS.vert_fact = '';
            OPTS.colormap  = '';
            OPTS.names     = string(''); % just "" in R2017B, but doesn't work in R2016B

            % break out early if no fields in overrides to process
            switch nargin
                case 0
                    return
                case 1
                    if ~isstruct(overrides) && ~isa(overrides, 'Opts')
                        error('dstauffman:UnexpectedType', 'Unexpected input type.');
                    end
                otherwise
                    error('dstauffman:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
            end

            % get the fields from the overrides and store them to OPTS
            fields = fieldnames(overrides);
            for i = 1:length(fields)
                OPTS.(fields{i}) = overrides.(fields{i});
            end
        end

        function [non_defaults] = plot_non_defaults(obj)
            % Displays only the non-default values within the structure

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