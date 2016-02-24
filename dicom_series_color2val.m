
fSize = 12;

plot_dir = '~/Desktop/flow_plots';

image_dir = '~/Desktop/flow_plots';

file_dir = '/Volumes/Duo/grasshopper_imaging_full_frames';

meta_data_path = '~/Desktop/grasshopper_meta.mat';

% Open a file for logging
fid = fopen(fullfile(output_dir, 'log.txt'), 'w');

% Output structure name
output_name = 'short_axis_data.mat';

% OUtput directory
output_dir = '~/Desktop/grasshopper_output_data/';

% Make the output dir if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir) 
end

% Load the meta data
load(meta_data_path);

% Count files
num_files = length(MetaData);

% Color bar ROI
colorbar_roi = [69, 187, 6, 335];

% Color bar extents
color_bar_range = [-1, 1];

flow_dir = -1;

frame_start = 1;

frame_end_user = inf;

frame_step = 1;

% Block size for reading from the dicom
slices_per_block = 1000;

for f = 1 : num_files;
   try
       
    Data = MetaData{f}; 
    
    % File name
    input_file_name = Data.FileName;
    
    % Construct the path to the dicom file
    input_file_path = fullfile(file_dir, input_file_name);
        
    % Output file name
    output_file_name = [input_file_name(1 : end - 4) '_data.mat'];
    
    % Ouutput file path
    output_file_path = fullfile(output_dir, [Data.Axis '_axis'], output_file_name);
    
    % Make sure it's short axis
    if ~exist(output_file_path, 'file')...
            && exist(input_file_path, 'file');
			
			fprintf(1, 'On file %d of %d\n', f, num_files);
			fprintf(fid, 'On file %d of %d\n', f, num_files);
    
        color_bar_range = Data.VelocityRange * [-1, 1];

        color_bar_roi = Data.ColorBarROI;
        
        % Frames per second
        frames_per_second = double(Data.FrameRate);

        roi_x = Data.ROI.x;
        roi_y = Data.ROI.y;
        roi_width = Data.ROI.Width;
        roi_height = Data.ROI.Height;

        % Image ROI
        image_roi = double([roi_x, roi_y, roi_width, roi_height]);

        % End frame
        frame_end = min(frame_end_user, double(Data.NumberOfFrames));

        % Frame numbers
        frame_numbers = frame_start : frame_step : frame_end;

        % Count the number of frames
        number_of_frames = length(frame_numbers);

        % Allocate the mean velocity array
        flow_rate_raw = zeros(number_of_frames, 1); 

        % Find the color bar
        color_bar_data = dicom_find_color_bar(input_file_path, colorbar_roi);

        % Find the ROI
        dicom_roi_extents = dicom_find_doppler_roi(input_file_path, image_roi);
        
        % Find the width and height
        dicom_subregion_width = dicom_roi_extents(3) - dicom_roi_extents(1) + 1;
        dicom_subregion_height = dicom_roi_extents(4) - dicom_roi_extents(2) + 1;

        % Number of blocks to run
        number_of_blocks = ceil(number_of_frames / slices_per_block);
        
        vel_field = zeros(dicom_subregion_height, dicom_subregion_width, number_of_frames);

        % Loop over all the blocks.
        for n = 1 : number_of_blocks

            fprintf(1,   'Loading block %d of %d\n', n, number_of_blocks);
			fprintf(fid, 'Loading block %d of %d\n', n, number_of_blocks);

            first_slice = (n - 1) * slices_per_block + 1;

            last_slice = min(first_slice + slices_per_block - 1, frame_end);

            dicom_block = dicomread(input_file_path, 'frames', ...
                first_slice : last_slice);

            % Loop over all the frames
            for k = 1 : slices_per_block

                % Index number within the whole dataset.
                index_num = k + (n - 1) * slices_per_block;

                % Inform the user
                % fprintf(1, ['Block ' num2str(n) ', frame ' num2str(k) ' of ' num2str(slices_per_block) '\n']);

                % Load the k'th dicom slice
                dicom_slice = dicom_block(:, :, :, k);
                
               % Extract the velocity field
                [vel_field(:, :, index_num), flow_rate_raw(index_num)] = dicom_color2val(dicom_slice, color_bar_data,...
                color_bar_range, dicom_roi_extents);
            end


        end
        
        % Time in seconds
        time_seconds = (1 : number_of_frames) / frames_per_second;
        
        % Save the velocity field array to the structure
        Data.Velocity = vel_field;
        
        % Save the time
        Data.Time = time_seconds;

		% Write the output data to at mat file.
        save(output_file_path, 'Data', '-v7.3');
		fprintf(fid, 'Saved data to file: %s\n\n', output_file_path);


    end
        
    catch
       fprintf(1, ['Error with file ' num2str(f) '\n']);
    end

end

% Close the opened file
fclose(fid);
