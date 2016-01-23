
fSize = 12;

plot_dir = '~/Desktop/flow_plots';

image_dir = '~/Desktop/flow_plots';

file_dir = '/Volumes/Duo/grasshopper_imaging_full_frames';

meta_data_path = '~/Desktop/grasshopper_meta.mat';

load(meta_data_path);

% Count files
num_files = length(MetaData.MetaList);

% Color bar ROI
colorbar_roi = [69, 187, 6, 335];

% Color bar extents
color_bar_range = [-1, 1];

flow_dir = -1;

frame_start = 1;

frame_end_user = 1000;

frame_step = 1;

MetaList = MetaData.MetaList;

for f = 2 : 2;
   try
       
    Meta = MetaData.MetaList{f};  
       
    % File name
    file_name = Meta.FileName;
    
    % Construct the path to the dicom file
    input_file_path = fullfile(file_dir, file_name);

    % Frames per second
    frames_per_second = double(Meta.FrameRate);

    roi_x = Meta.ROI.x;
    roi_y = Meta.ROI.y;
    roi_width = Meta.ROI.Width;
    roi_height = Meta.ROI.Height;

    % Image ROI
    image_roi = double([roi_x, roi_y, roi_width, roi_height]);
    
    % End frame
    frame_end = min(frame_end_user, double(Meta.NumberOfFrames));

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

    % Block size for reading from the dicom
    slices_per_block = 1000;

    % Number of blocks to run
    number_of_blocks = ceil(number_of_frames / slices_per_block);

    % Loop over all the blocks.
    for n = 1 : number_of_blocks

        fprintf(1, ['Loading block ' num2str(n) ' of ' num2str(number_of_blocks) '\n']);

        first_slice = (n - 1) * slices_per_block + 1;

        last_slice = min(first_slice + slices_per_block - 1, frame_end);

        dicom_block = dicomread(input_file_path, 'frames', ...
            first_slice : last_slice);

        % Loop over all the frames
        for k = 1 : slices_per_block

            % Index number within the whole dataset.
            index_num = k + (n - 1) * slices_per_block;

            % Inform the user
            fprintf(1, ['Block ' num2str(n) ', frame ' num2str(k) ' of ' num2str(slices_per_block) '\n']);

            % Load the k'th dicom slice
            dicom_slice = dicom_block(:, :, :, k);
            
            subplot(1, 2, 1);
            imshow(uint8(dicom_slice));
            
            subplot(1, 2, 2);
            imagesc(vel_field);
            caxis([-1, 1]);
            colorbar;
            axis image;
            
            print(1, '-dpng', '-r200', fullfile(image_dir, ['flow_plot_' num2str(k, '%05d') '.png']));

            % Extract the velocity field
            [vel_field, flow_rate_raw(index_num)] = dicom_color2val(dicom_slice, color_bar_data,...
            color_bar_range, dicom_roi_extents);

        end


    end

    % Get the direction correct.
    flow_rate = flow_dir * flow_rate_raw;

    % Normalize flow rate
    flow_rate_norm = flow_rate ./ max(abs(flow_rate(:)));

    % Time in seconds
    time_seconds = (1 : number_of_frames) / frames_per_second;

    % Plot
    plot(time_seconds, flow_rate_norm, '-k', 'linewidth', 2);
    ylim(1.1 * [-1, 1]);
    pbaspect([4, 1, 1]);
    
    xlabel('Time (seconds)', 'FontSize', fSize);
    ylabel('Normalized flow rate', 'FontSize', fSize);
    set(gca, 'FontSize', fSize);
    
    % Print the file
    plot_name = [file_name(1 : end - 4) '.png'];
    plot_path = fullfile(plot_dir, plot_name);
    print(1, '-dpng', '-r300', plot_path);

       
    catch
       fprintf(1, ['Error with file ' num2str(k) '\n']);
    
    end

% Direction of positive values
% 1 for toward head, -1 for away from head.





end