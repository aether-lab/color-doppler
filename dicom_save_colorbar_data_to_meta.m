
fSize = 12;

plot_dir = '~/Desktop/flow_plots';

image_dir = '~/Desktop/flow_plots';

file_dir = '/Volumes/Duo/grasshopper_imaging_full_frames';

meta_data_path = '~/Desktop/grasshopper_meta.mat';

% OUtput directory
output_dir = '~/Desktop/grasshopper_output_data/';

% Open a file for logging
fid = fopen(fullfile(output_dir, 'log.txt'), 'w');

% Output structure name
output_name = 'short_axis_data.mat';

% Make the output dir if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir) 
end

% Load the meta data
load(meta_data_path);

% Count files
num_files = length(MetaData);

% Default Color bar ROI
% colorbar_roi = [69, 187, 6, 335];


for f = 1 : num_files;
    
    try
      
    fprintf(1, 'On file %d of %d\n\n', f, num_files);    
    
    % Load the data
    Data = MetaData{f}; 
    
    % File name
    input_file_name = Data.FileName;
    
    % Construct the path to the dicom file
    input_file_path = fullfile(file_dir, input_file_name);
   
    % Make sure it's short axis
    if exist(input_file_path, 'file');
		
        
        if isfield(Data, 'ColorBar')
            if isfield(Data.ColorBar, 'ROI')
                % This is the default color bar ROI for this 
                color_bar_roi = Data.ColorBar.ROI;
            end
        elseif isfield(Data, 'ColorBarROI')
            color_bar_roi = Data.ColorBarROI;
            Data = rmfield(Data, 'ColorBarROI');
        end

        % Find the color bar
        color_bar_data = dicom_find_color_bar(input_file_path, color_bar_roi);
        
        % Make the user get the data manually. 
        if isempty(color_bar_data)
            fprintf(1, 'Colorbar data not found. Finding color bar data...\n\n');
            [color_bar_data, color_bar_roi] = dicom_find_color_bar(input_file_path);
            Data.ColorBar.ROI = color_bar_roi;
        end
        
        Data.ColorBar.Data = color_bar_data;
        Data.ColorBar.ROI = color_bar_roi;
        
        MetaData{f} = Data;
        
        save(meta_data_path, 'MetaData');
        
    end
    
    catch er
        fprintf(1, 'Problem with file %d\n\n', f);
        fprintf(1, '%s\n', er.message);
        keyboard
    end
        
end
