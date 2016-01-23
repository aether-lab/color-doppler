function [vel_field, flow_rate] = dicom_color2val(dicom_slice, color_bar_data_raw,...
    color_bar_range, dicom_roi_extents);

% dicom_roi
roi_xmin   = dicom_roi_extents(1);
roi_ymin   = dicom_roi_extents(2);
roi_xmax  = dicom_roi_extents(3);
roi_ymax = dicom_roi_extents(4);

dicom_roi = double(dicom_slice(roi_ymin : roi_ymax, roi_xmin : roi_xmax, :));

% Extract the dicom ROI
% dicom_roi = permute(dicom_roi_raw, [1, 3, 2]);

[roi_height, roi_width, ~] = size(dicom_roi);

% Find pixels with color
has_color = range(dicom_roi, 3) > 50;

% Find the colored pixels
colored_pixel_inds = find(has_color(:) > 0);

% Colored pixel row, col, depth
[colored_pixel_rows, colored_pixel_cols] = ind2sub(...
    size(has_color), colored_pixel_inds);

% Count the number of colored pixels
num_colored_pixels = length(colored_pixel_inds);

% Allocate the quantitative velocity field array
vel_field = nan(roi_height, roi_width);

% Flip the color bar data to align its minimum
% with that of the velocity range.
color_bar_data = flipud(color_bar_data_raw);

% Make a linear space for the velocity values
vel_range = linspace(min(color_bar_range), max(color_bar_range),...
    size(color_bar_data, 1));

% Initialize the mean flow rate.
flow_rate = 0;

% Loop over the number of colored pixels
for k = 1 : num_colored_pixels
   
    % Extract the RGB values from the colored pixel
   pixel_val = permute(dicom_roi(colored_pixel_rows(k), ...
       colored_pixel_cols(k), :), [1, 3, 2]);
   
   % Replicate the pixel value to be the same size as the color bar column
   pixel_val_rep = repmat(pixel_val, [size(color_bar_data, 1), 1]);
   
   % Absolute difference between the pixel value and the color bar values
   color_diff = sum(abs(color_bar_data - pixel_val_rep), 2);
   
   % Index of the minimum color difference
   color_diff_min_idx = find(color_diff == min(color_diff), 1);
   
   pixel_velocity = vel_range(color_diff_min_idx);
   
   % Colored pixel velocity value
   vel_field(colored_pixel_rows(k), colored_pixel_cols(k)) = ...
       pixel_velocity;
   
   % Add to the net flow rate
   flow_rate = flow_rate + pixel_velocity;
    
end

end


