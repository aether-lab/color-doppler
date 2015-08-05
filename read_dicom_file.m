file_dir = '~/Desktop/MNG_Z_morio';

file_name = 'MNG_2_086_B';

% File extension
input_file_ext = '.dcm';

% Output file extension
output_file_ext = '.tiff';

frame_start = 10;

frame_end = 10;

frame_step = 1;

% Frame numbers
frame_numbers = frame_start : frame_step : frame_end;

% Count the number of frames
number_of_frames = length(frame_numbers);

% Construct the path to the dicom file
input_file_path = fullfile(file_dir, [file_name, input_file_ext]);

% Output directory
output_dir = fullfile('~/Desktop/z_morio_videos', file_name);

% Create the output dir if it doesn't exist
if ~exist(output_dir, 'dir')
   mkdir(output_dir); 
end

% Load the images
for k = 1 : number_of_frames
   
    % Construct the output file name
    output_file_name = sprintf('%s_%06d%s', ...
        file_name, k, output_file_ext);
    
    % Construct the output file path
    output_file_path = fullfile(output_dir, output_file_name);
    
    % Load the k'th frame from the dicom file
    img = dicomread(input_file_path, 'frames', frame_numbers(k));
   
    % Save the image
   imwrite(img, output_file_path);
    
end
