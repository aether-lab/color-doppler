
ax = 'short';

input_file_dir = sprintf('/Users/matthewgiarra/Desktop/grasshopper_data/%s_axis', ax);

output_file_path = fullfile(input_file_dir, sprintf('velocities_%s_axis.mat', ax));

% Get the names of the files
file_list = dir([input_file_dir '/*_data.mat']);

valid_nums = [];

% Number of files
num_files = length(file_list);

% Flow direction
% -1 means negative is toward the head.
flow_dir = -1;

% for k = 1 : num_files
%    file_name = file_list(k).name;
%    if regexpi(file_name, '_1_data.mat')
%        valid_nums(end + 1) = k;
%    end
%     
% end

num_valid = num_files;


for k = 1 : num_valid
   
    file_name = file_list(k).name;

    fprintf(1, 'loading file: %s\n', file_name);

    % Build the input file path
    input_file_path = fullfile(input_file_dir, file_name);

    % Load the input file
    load(input_file_path)
    
    % Print the series description
    fprintf(1, '%s\n\n', Data.SeriesDescription);
   
    
end




