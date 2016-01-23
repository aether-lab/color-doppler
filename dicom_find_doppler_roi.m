function dicom_roi = dicom_find_doppler_roi(file_path, image_roi)

% Load the first image in the dicom file.
img = dicomread(file_path, 'frames', 1);

x_min = image_roi(1);
y_min = image_roi(2);
image_width = image_roi(3);
image_height = image_roi(4);
x_max = x_min + image_width;
y_max = y_min + image_height;


% Part of the entire dicom image that contains the ultrasound image
img_cropped = img(y_min : y_max, x_min : x_max, :);

% Find color pixels
has_color = range(img_cropped, 3) > 0;

% Measure size
[cropped_height, cropped_width] = size(has_color);

[x, y] = meshgrid(1 : cropped_width, 1 : cropped_height);

x_vect = x(:);
y_vect = y(:);

origin_idx = find(has_color(:) > 0, 1, 'first');

roi_x_min = x_vect(origin_idx) + 1 + x_min;
roi_y_min = y_vect(origin_idx) + 1 + y_min;

extents_idx = find(has_color(:) > 0, 1, 'last');
roi_x_max = x_vect(extents_idx) - 2 + x_min;
roi_y_max = y_vect(extents_idx) - 2 + y_min;

dicom_roi = [roi_x_min, roi_y_min, roi_x_max, roi_y_max];

end