function color_bar = dicom_find_color_bar(file_path, ROI)

% Load the first image in the dicom file.
img = dicomread(file_path, 'frames', 1);

% Pick the ROI
if nargin < 2 || isempty(ROI)
    
    % Display the image
    imshow(img);

    % Prompt the user to draw a rectangle around the colorbar.
    rect_pos = getPosition(imrect);
    
    % Rectangle extends
    rect_xmin   = round(rect_pos(1));
    rect_ymin   = round(rect_pos(2));
    rect_width  = round(rect_pos(3));
    rect_height = round(rect_pos(4));
    
    % Wait for the user to press a key so they have
    % time to adjust the ROI box.
    pause;
    
else
    rect_xmin   = ROI(1);
    rect_ymin   = ROI(2);
    rect_width  = ROI(3);
    rect_height = ROI(4);
end

% Extract the rectangle from the image
img_roi = fliplr(img(rect_ymin : rect_ymin + rect_height, ...
    rect_xmin : rect_xmin + rect_width, :));

% Range of values
roi_range = range(img_roi, 3);

% Find the first index that isn't gray!
color_index_first = find(roi_range > 0, 1);
[color_row_first, color_col] = ind2sub(size(img_roi), color_index_first);

% Find the last index that isn't gray!
color_index_last = find(flipud(roi_range) > 0, 1);
[color_row_last_flipped, ~] = ind2sub(size(img_roi), color_index_last);

% Correct for the flip
color_row_last = rect_height - color_row_last_flipped;

% Extract the single column of color values corresponding to the color bar.
color_bar = double(squeeze(img_roi(color_row_first : color_row_last,...
    color_col, :)));

end




