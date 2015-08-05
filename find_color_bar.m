function color_bar = find_color_bar(file_path)

% Load the first image in the dicom file.
img = dicomread(file_path, 'frames', 1);

% Display the image
imshow(img);

% Prompt the user to draw a rectangle around the colorbar.
rect_pos = getPosition(imrect);

% Rectangle extends
rect_xmin   = rect_pos(1);
rect_ymin   = rect_pos(2);
rect_width  = rect_pos(3);
rect_height = rect_pos(4);

% Extract the rectangle from the image
img_roi = fliplr(img(rect_ymin : rect_ymin + rect_height, ...
    rect_xmin : rect_xmin + rect_width, :));

% Wait for the user to press a key so they have
% time to adjust the ROI box.
pause;

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
color_bar = squeeze(img_roi(color_row_first : color_row_last,...
    color_col, :));

end