function vel_field = dicom_color2val(dicom_slice, color_bar_data,...
    color_bar_range, dicom_roi_extents);

% dicom_roi
roi_xmin   = dicom_roi_extents(1);
roi_ymin   = dicom_roi_extents(2);
roi_width  = dicom_roi_extents(3);
roi_height = dicom_roi_extents(4);

% Extract the dicom ROI
dicom_roi = permute(dicom_slice(roi_ymin : roi_ymin + roi_height, ...
    roi_xmin : roi_xmin + roi_width, :), [1, 3, 2]);

% Range of values
roi_color_range = squeeze(range(dicom_roi, 2));

% Find the colored pixels
colored_pixel_inds = find(roi_color_range > 0);

% Colored pixel row, col, depth
[colored_pixel_rows, ~, colored_pixel_cols] = ind2sub(...
    size(dicom_roi), colored_pixel_inds);

% Count the number of colored pixels
num_colored_pixels = length(colored_pixel_inds);

% Allocate the quantitative velocity field array
vel_field = nan(roi_height, roi_width);

% Make a linear space for the velocity values
vel_range = linspace(min(color_bar_range), max(color_bar_range),...
    size(color_bar_data, 1));

% Loop over the number of colored pixels
for k = 1 : num_colored_pixels
   
    % Extract the RGB values from the colored pixel
    pixel_val = double(squeeze(dicom_roi(colored_pixel_rows(k), ...
       :, colored_pixel_cols(k))));
   
   % Replicate the pixel value to be the same size as the color bar column
   pixel_val_rep = repmat(pixel_val, [size(color_bar_data, 1), 1]);
   
   % Absolute difference between the pixel value and the color bar values
   color_diff = sum(abs(color_bar_data - pixel_val_rep), 2);
   
   % Index of the minimum color difference
   color_diff_min_idx = find(color_diff == min(color_diff), 1);
   
   % Colored pixel velocity value
   vel_field(colored_pixel_rows(k), colored_pixel_cols(k)) = ...
       vel_range(color_diff_min_idx); 
    
end

end


