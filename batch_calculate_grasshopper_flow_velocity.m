
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

for k = 1 : num_files
   file_name = file_list(k).name;
   if regexpi(file_name, '_1_data.mat')
       valid_nums(end + 1) = k;
   end
    
end

num_valid = length(valid_nums);

% Initialize an output structure
FlowData = {};

for k = 1 : num_valid
   
    file_name = file_list(valid_nums(k)).name;

    fprintf(1, 'loading file: %s\n', file_name);

    % Build the input file path
    input_file_path = fullfile(input_file_dir, file_name);

    % Calculate the velocities
    [mean_flow_vel, time_minutes, data_strings] = ...
    calculate_grasshopper_flow_velocity(input_file_path);

    % Update the structure
    FlowData{k}.File = file_name;
    FlowData{k}.Velocity = flow_dir * mean_flow_vel;
    FlowData{k}.Time = time_minutes;

    % Add units
    FlowData{k}.Units.Time = 'minutes';
    FlowData{k}.Units.Velocity = 'mm/s';  
    
    % Add data strings
    FlowData{k}.TrialName = data_strings.TrialName;
    FlowData{k}.Acquisition = data_strings.Acquisition;
    
end

% Save the output structure
save(output_file_path, 'FlowData', '-v7.3');




