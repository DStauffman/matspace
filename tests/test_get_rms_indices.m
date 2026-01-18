classdef test_get_rms_indices < matlab.unittest.TestCase %#ok<*PROP>

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
            self.time_one       = 0:10;
            self.time_two       = 2:12;
            self.time_overlap   = 2:10;
            self.xmin           = 1;
            self.xmax           = 8;
            self.exp            = dictionary();
            self.exp{'one'}     = [false,  true,  true,  true,  true,  true,  true,  true,  true, false, false];
            self.exp{'two'}     = [ true,  true,  true,  true,  true,  true,  true, false, false, false, false];
            self.exp{'overlap'} = [ true,  true,  true,  true,  true,  true,  true, false, false];
            self.exp{'pts'}     = [1, 8];
        end
    end

    methods (Test)
        function test_nominal(self)
            ix = matspace.plotting.get_rms_indices(self.time_one, self.time_two, self.time_overlap, xmin=self.xmin, xmax=self.xmax);
            all_keys = keys(ix);
            for k = 1:length(all_keys)
                key = all_keys(k);
                self.verifyEqual(ix{key}, self.exp{key}, sprintf('Failed for key %s', key));
            end
        end

        function test_only_time_one(self)
            self.exp{'two'} = false(1, 0);
            self.exp{'overlap'} = false(1, 0);
            ix = matspace.plotting.get_rms_indices(self.time_one, [], [], xmin=self.xmin, xmax=self.xmax);
            all_keys = keys(ix);
            for k = 1:length(all_keys)
                key = all_keys(k);
                self.verifyEqual(ix{key}, self.exp{key}, sprintf('Failed for key %s', key));
            end
        end

        function test_no_bounds(self)
            self.exp{'one'}(:) = true;
            self.exp{'two'}(:) = true;
            self.exp{'overlap'}(:) = true;
            self.exp{'pts'} = [0, 12];
            ix = matspace.plotting.get_rms_indices(self.time_one, self.time_two, self.time_overlap);
            all_keys = keys(ix);
            for k = 1:length(all_keys)
                key = all_keys(k);
                self.verifyEqual(ix{key}, self.exp{key}, sprintf('Failed for key %s', key));
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
            self.exp{'pts'} = date_zero + seconds(self.exp{'pts'});
            all_keys = keys(ix);
            for k = 1:length(all_keys)
                key = all_keys(k);
                self.verifyEqual(ix{key}, self.exp{key}, sprintf('Failed for key %s', key));
            end
        end
    end
end