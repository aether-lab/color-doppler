function dicom_roi = dicom_find_doppler_roi(file_path)

% Load the first image in the dicom file.
img = dicomread(file_path, 'frames', 1);

% Display the image
imshow(img);

% Prompt the user to draw a rectangle around the colorbar.
dicom_roi = getPosition(imrect);

% Pause to give the user time to adjust the ROI!
pause;

end