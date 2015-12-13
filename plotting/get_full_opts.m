function [OPTS] = get_full_opts(overrides)

% GET_FULL_OPTS  lists all the possible options with the OPTS variable.
%
% Input:
%     overrides : (struct) existing OPTS variable to use to override the defaults
%
% Output:
%     OPTS ......... : (struct) full list of all possible fields
%         .case_name : (row) string specifying the name of the case to be plotted [char]
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
%     OPTS = get_full_opts();
%
% Change Log:
%     1.  Written by David C. Stauffer in September 2013.
%     2.  Added to DStauffman MATLAB library in December 2015.

% store OPTS defaults
OPTS.case_name = '';
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
if ~isstruct(overrides)
    return
end

% get the fields from the overrides and store them to OPTS
fields = fieldnames(overrides);
for i = 1:length(fields)
    OPTS.(fields{i}) = overrides.(fields{i});
end