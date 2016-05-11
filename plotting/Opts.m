classdef Opts
    
    % OPTS  defines the class for all the possible plotting options.
    %
    % Input:
    %     overrides : (struct) existing OPTS instance or similar struct to use to override the defaults
    %
    % Output:
    %     OPTS ......... : (class) plotting options
    %         .case_name : (row) string specifying the name of the case to be plotted [char]
    %         .plot_type : (row) string specifying the type of plot to save to disk, from {'png','jpg','fig','emf'} [char]
    %         .save_path : (row) string specifying the location for the plots to be saved [char]
    %         .save_plot : (scalar) true/false flag for whether to save the plots [bool]
    %         .sub_plots : (scalar) true/false flag specifying whether to plot as subplots or separate figures [bool]
    %         .disp_xmin : (scalar) minimum time to display on plot [months]
    %         .disp_xmax : (scalar) maximum time to display on plot [months]
    %         .rms_xmin  : (scalar) minimum time from which to begin RMS calculations [months]
    %         .rms_xmax  : (scalar) maximum time from which to end RMS calculations [months]
    %         .name_one  : (row) string specifying the name of the first data structure to be plotted [char]
    %         .name_two  : (row) string specifying the name of the second data structure to be plotted [char]
    %         .plot_true : (row) string specifying which truth data to plot [char]
    %
    % Prototype:
    %     OPTS = Opts();
    %
    % Change Log:
    %     1.  Written by David C. Stauffer in September 2013.
    %     2.  Added to DStauffman MATLAB library in December 2015.
    
    properties
        case_name,
        plot_type,
        save_path,
        save_plot,
        sub_plots,
        disp_xmin,
        disp_xmax,
        rms_xmin,
        rms_xmax,
        name_one,
        name_two,
        plot_true
    end
    
    methods
        function OPTS = Opts(overrides)
            % store OPTS defaults
            OPTS.case_name = '';
            OPTS.plot_type = 'png';
            OPTS.save_path = [pwd filesep];
            OPTS.save_plot = false;
            OPTS.sub_plots = true;
            OPTS.disp_xmin = -inf;
            OPTS.disp_xmax = inf;
            OPTS.rms_xmin  = -inf;
            OPTS.rms_xmax  = inf;
            OPTS.name_one  = '';
            OPTS.name_two  = '';
            OPTS.plot_true = 'none';
            
            % break out early if no fields in overrides to process
            if nargin == 0 || ~isstruct(overrides) || ~isa(overrides, 'OPTS')
                return
            end

            % get the fields from the overrides and store them to OPTS
            fields = fieldnames(overrides);
            for i = 1:length(fields)
                OPTS.(fields{i}) = overrides.(fields{i});
            end
        end
    end
end