

% Directory containing the dicoms
dicom_dir = '/Volumes/Duo/grasshopper_imaging_full_frames';

% Directory containing the metadata file
meta_dir = '~/Desktop';

% Name of the metadata file
meta_name = 'grasshopper_meta.mat';

% Path to the metadata file
meta_path = fullfile(meta_dir, meta_name);

% Load the metadata
load(meta_path);

% This is the number of files in the metadata
num_dicoms = length(MetaData);

% Loop over all the dicoms, showing
% the first image in each and prompting
% the user to indicate the imaging axis.
for k = 1 : num_dicoms
    
    % Inform the user of the progress.
    fprintf('On %d of %d\n', k, num_dicoms)
    
    % Check validity
    if isfield(MetaData{k}, 'FileName')
        
        % Make the path to the file
        dicom_path = fullfile(dicom_dir, MetaData{k}.FileName);
        
        % Read the image
        img = dicomread(dicom_path, 'frames', 1);
        
        % Show the first image
        imshow(img);
        
        % Get input
        img_axis = input('Axis: ', 's');
        
        % Assign result to structure
        if img_axis == 's'
            MetaData{k}.Axis = 'short';
        elseif img_axis == 'l'
            MetaData{k}.Axis = 'Long';
        end      
        
    end
    
end

% Save the structure
save(meta_path, 'MetaData');


