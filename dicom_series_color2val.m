file_dir = '~/Desktop/MNG_Z_morio';

file_name = 'MNG_2_086_B';

% File extension
input_file_ext = '.dcm';

% Output file extension
output_file_ext = '.tiff';

frame_start = 1;

frame_end = 1000;

frame_step = 1;

% Color bar extents
color_bar_range = [-28.9, 28.9];

% Frame numbers
frame_numbers = frame_start : frame_step : frame_end;

% Count the number of frames
number_of_frames = length(frame_numbers);

% Allocate the mean velocity array
mean_velocity = zeros(number_of_frames, 1); 

% Construct the path to the dicom file
input_file_path = fullfile(file_dir, [file_name, input_file_ext]);

% Find the color bar
% color_bar_data = dicom_find_color_bar(input_file_path);

% Find the ROI
% dicom_roi_extents = dicom_find_doppler_roi(input_file_path);
dicom_roi_extents = [535, 327, 76, 80];

% Loop over all the frames
parfor k = 1 : number_of_frames
    
    % Inform the user
    fprintf(1, 'On frame %d of %d...\n', k, number_of_frames);
    
    % Load the k'th dicom slice
    dicom_slice = double(dicomread(input_file_path, 'frames', frame_numbers(k)));
    
    % Extract the velocity field
    vel_field = dicom_color2val(dicom_slice, color_bar_data,...
    color_bar_range, dicom_roi_extents);

    % Calculate the average velocity
    mean_velocity(k) = nanmean(vel_field(:));
    
end
