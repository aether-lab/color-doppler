function [mean_flow_velocity, time_minutes, data_str] = ...
    calculate_grasshopper_flow_velocity(input_file_path, output_file_path)

% Load the input file
load(input_file_path)

% Read the velocity
vel_array = Data.Velocity;

% Read the series description
trial_name = Data.SeriesDescription;

% Read the acquisition number
image_comments = Data.ImageComments;

% Extract the acquisition number
acq_number_loc = regexpi(Data.ImageComments, 'acquisition');

% Acquisition number
acquisition_string = Data.ImageComments(acq_number_loc : end);

% Read the time (in minutes)
time_minutes = (Data.Time / 60)';

% Number and shapes of regions
num_regions = size(vel_array, 3);
        
% Allocate the mean flow rate
mean_flow_velocity = zeros(num_regions, 1);
   
% Loop over all the regions
for k = 1 : num_regions
    
   % Inform the user
%    fprintf(1, 'On region %d of %d...\n', k, num_regions);
    
   % Extract the velocity slice
   vel_slice = vel_array(:, :, k);
   
   % Calculate the mean velocity
   mean_flow_velocity(k) = nanmean(vel_slice(:));
   
end

% Data strings
data_str.Acquisition = acquisition_string;
data_str.TrialName = trial_name;

% Save the outputs if an output file path is specified.
if nargin == 2
    save(output_file_path, 'mean_flow_velocity', ...
        'time_minutes', 'trial_name', ...
        'acquisition_string');
end

end
