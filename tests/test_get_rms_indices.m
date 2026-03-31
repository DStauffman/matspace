classdef test_get_rms_indices < matlab.unittest.TestCase  %#ok<*PROP>

    % Tests the make_time_plot function with the following cases:
    %     Nominal
    %     TBD

    properties
        time_one,
        time_two,
        time_overlap,
        xmin,
        xmax,
        exp,
    end

    methods (TestMethodSetup)
        function initialize(self)
            self.time_one     = 0:10;
            self.time_two     = 2:12;
            self.time_overlap = 2:10;
            self.xmin         = 1;
            self.xmax         = 8;
            self.exp          = struct();
            self.exp.one      = [false,  true,  true,  true,  true,  true,  true,  true,  true, false, false];
            self.exp.two      = [ true,  true,  true,  true,  true,  true,  true, false, false, false, false];
            self.exp.overlap  = [ true,  true,  true,  true,  true,  true,  true, false, false];
            self.exp.pts      = [1, 8];
        end
    end

    methods (Test)
        function test_nominal(self)
            ix = matspace.plotting.get_rms_indices(self.time_one, self.time_two, self.time_overlap, xmin=self.xmin, xmax=self.xmax);
            fields = fieldnames(ix);
            for f = 1:length(fields)
                field = fields{f};
                self.verifyEqual(ix.(field), self.exp.(field), sprintf('Failed for field %s', field));
            end
        end

        function test_only_time_one(self)
            self.exp.two = false(1, 0);
            self.exp.overlap = false(1, 0);
            ix = matspace.plotting.get_rms_indices(self.time_one, [], [], xmin=self.xmin, xmax=self.xmax);
            fields = fieldnames(ix);
            for f = 1:length(fields)
                field = fields{f};
                self.verifyEqual(ix.(field), self.exp.(field), sprintf('Failed for field %s', field));
            end
        end

        function test_no_bounds(self)
            self.exp.one(:) = true;
            self.exp.two(:) = true;
            self.exp.overlap(:) = true;
            self.exp.pts = [0, 12];
            ix = matspace.plotting.get_rms_indices(self.time_one, self.time_two, self.time_overlap);
            fields = fieldnames(ix);
            for f = 1:length(fields)
                field = fields{f};
                self.verifyEqual(ix.(field), self.exp.(field), sprintf('Failed for field %s', field));
            end
        end

        function test_datetime(self)
            date_zero = datetime(2026, 1, 15, 9, 0, 0);
            time_one = date_zero + seconds(self.time_one);
            time_two = date_zero + seconds(self.time_two);
            time_overlap = date_zero + seconds(self.time_overlap);
            xmin = date_zero + seconds(self.xmin);
            xmax = date_zero + seconds(self.xmax);
            ix = matspace.plotting.get_rms_indices(time_one, time_two, time_overlap, xmin=xmin, xmax=xmax);
            self.exp.pts = date_zero + seconds(self.exp.pts);
            fields = fieldnames(ix);
            for f = 1:length(fields)
                field = fields{f};
                self.verifyEqual(ix.(field), self.exp.(field), sprintf('Failed for field %s', field));
            end
        end

        function test_bad_timezones(self)
            date_zero = datetime(2026, 1, 15, 10, 0, 0, TimeZone='UTC');
            time_one = date_zero + seconds(self.time_one);
            time_two = datetime('NaT', TimeZone='UTC');
            time_overlap = datetime('NaT', TimeZone='UTC');
            xmin = date_zero + seconds(self.xmin);
            xmax = date_zero + seconds(self.xmax);
            self.verifyError(@() matspace.plotting.get_rms_indices(time_one, datetime('NaT'), time_overlap, ...
                xmin=xmin, xmax=xmax), 'matspace:getRmsIndices:TimeZone');
            ix = matspace.plotting.get_rms_indices(time_one, time_two, time_overlap, xmin=xmin, xmax=xmax);
            self.exp.pts = date_zero + seconds(self.exp.pts);
            self.exp.two = false;
            self.exp.overlap = false;
            fields = fieldnames(ix);
            for f = 1:length(fields)
                field = fields{f};
                self.verifyEqual(ix.(field), self.exp.(field), sprintf('Failed for field %s', field));
            end
        end
    end
end