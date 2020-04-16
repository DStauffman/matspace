function is_same = compare_two_structures(S1,S2,suppress_output,names)

% COMPARE_TWO_STRUCTURES  return true if they are same or false otherwise.
%
% Summary:
%     If they are not the same, try to diagnose the difference.
%     For fields that are double arrays and that have the same dimensions,
%     compute the RMS difference between the two. RMS difference is a single
%     scalar that is the RMS difference over all the dimensions.
%     Report the dimensions of fields having the same name but having
%     different dimensions. Writes this information to the Matlab command
%     window.
%
%     Structures statistics currently only work on the first level of the structure.
%
% Input:
%     S1              : (struct) input structure 1
%     S2              : (struct) input structure 2
%     suppress_output : (scalar) |opt| true/false flag to suppress command window output [bool]
%     names           : {1x2} of (row) |opt| strings specifying the names of the input structures [char]
%
% Output:
%     is_same         : (scalar) flag that is true if structures are the same [bool]
%                           (Also displays information to the command window)
%
% Prototype:
%     % test cases:
%     A1.f1 = 5;
%     A1.f2 = 7;
%     A2.f1 = 5;
%     A2.f2 = 7;
%     same  = matspace.utils.compare_two_structures(A1,A2);
%     % yields:
%     % same = true;
%     % 'A1' and 'A2' are the same.
%
%     A1.f1 = 5;
%     A1.f2 = 7;
%     A2.f1 = 6;
%     A2.f2 = 7;
%     same  = matspace.utils.compare_two_structures(A1,A2);
%     % yields:
%     % same = false;
%     % 'A1' and 'A2' are not the same.
%     % Field 'f1' differs.
%     % RMS difference = 1
%
%     A1.f1 = 5;
%     A1.f2 = [6,7];
%     A2.f1 = 6;
%     A2.f2 = 7;
%     matspace.utils.compare_two_structures(A1,A2)
%     % yields:
%     % same = false;
%     % 'A1' and 'A2' are not the same.
%     % Field 'f1' differs.
%     % RMS difference = 1
%     % Field 'f2' differs.
%     % Fields named 'f2' don't have the same dimensions.
%     % 'A1.f2' dimensions are [1 2]
%     % 'A2.f2' dimensions are [1 1]
%
% See Also:
%     isequaln
%
% Change Log:
%     1.  Originally created by Tom Trankle circa 2010.
%     2.  Adapted and expanded by David C. Stauffer circa 2011.
%     3.  Added to matspace library by David C. Stauffer in February 2016.
%     4.  Updated by David C. Stauffer in April 2020 to put into a package.

% Imports
import matspace.utils.compare_two_structures % calls itself recursively

% check for optional input and get names of incoming structures
switch nargin
    case 2
        suppress_output = false;
        struct_name1 = inputname(1);
        struct_name2 = inputname(2);
    case 3
        struct_name1 = inputname(1);
        struct_name2 = inputname(2);
    case 4
        struct_name1 = names{1};
        struct_name2 = names{2};
    otherwise
        error('matspace:UnexpectedNargin', 'Unexpected number of inputs: "%i"', nargin);
end

if isequaln(S1,S2)
    % If the two inputs are identical, just set output flag and exit.
    % This can get set true even if the inputs are not structures.
    is_same = true;
    if ~suppress_output
        disp(['''',struct_name1,''' and ''',struct_name2,''' are the same.']);
    end
else
    % set output to false
    is_same = false;
    if ~suppress_output
        disp(['''',struct_name1,''' and ''',struct_name2,''' are not the same.']);
        % loop through and display the differences
        if isstruct(S1) && isstruct(S2)
            names_1 = sort(fieldnames(S1));
            names_2 = sort(fieldnames(S2));
            % find indices of identical subfields
            have_same_fields = isequaln(names_1,names_2);
            if have_same_fields
                % if all fields are the same, then save the entire list
                common_field_names = names_1;
            else
                % Structures do not have the same fields, so report the difference in field names
                disp(['''',struct_name1,''' and ''',struct_name2,''' do not have the same fields.']);
                % extra fields in structure 1
                names_1_minus_names_2 = setdiff(names_1,names_2);
                if ~isempty(names_1_minus_names_2)
                    disp(['Fields in ''',struct_name1,''' that are not in ''',struct_name2,''' are:']);
                    disp(names_1_minus_names_2);
                end
                % extra fields in structure 2
                names_2_minus_names_1 = setdiff(names_2,names_1);
                if ~isempty(names_2_minus_names_1)
                    disp(['Fields in ''',struct_name2,''' that are not in ''',struct_name1,''' are:']);
                    disp(names_2_minus_names_1);
                end
                % save common fields to both structures
                common_field_names = intersect(names_1,names_2);
            end
            % Case for having same field names but the two structs are still
            % not equal. Diagnose the differences field-by-field
            for this_field_cell = common_field_names'
                this_field = this_field_cell{1};
                field_1 = S1.(this_field);
                field_2 = S2.(this_field);
                % Check for equality of this field and if not, then display them
                this_field_is_the_same = isequaln(field_1,field_2);
                if ~this_field_is_the_same
                    % Case for the two fields having same name but are not the same
                    disp(['Field ''',this_field,''' differs.']);
                    if (length(size(field_1)) == length(size(field_2))) && all(size(field_1) == size(field_2))
                        % Case for the two fields being the same size
                        if isfloat(field_1) && isfloat(field_2)
                            numerical_difference = field_1 - field_2;
                            squared_elements     = numerical_difference.^2;
                            % Call sum in while loop until a scalar results
                            sum_squared_elements = sum(squared_elements);
                            while ~isscalar(sum_squared_elements)
                                sum_squared_elements = sum(sum_squared_elements);
                            end
                            RMS_difference = realsqrt(sum_squared_elements)/numel(numerical_difference);
                            % display RMS difference
                            disp(['RMS difference = ',num2str(RMS_difference)]);
                        elseif isstruct(field_1) && isstruct(field_2)
                            compare_two_structures(field_1,field_2,suppress_output,{[struct_name1,'.',this_field],[struct_name2,'.',this_field]});
                        else
                            disp('But cannot compute RMS because a field is not a float');
                        end
                    else
                        % Case for two fields with the same name not having the same dimension
                        disp(['Fields named ''',this_field,''' don''t have the same dimensions.']);
                        disp(['''',struct_name1,'.',this_field,''' dimensions are ',mat2str(size(field_1))]);
                        disp(['''',struct_name2,'.',this_field,''' dimensions are ',mat2str(size(field_2))]);
                    end
                end
            end
        else
            % At least one input is not a structure
            disp('Two inputs are not the same but are not structures either.');
            disp('Cannot do field-by-field comparison.');
        end
    end
end