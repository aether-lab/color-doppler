

file_path = '/Users/matthewgiarra/Desktop/grasshopper_data/short_axis/velocities_short_axis.mat';

plot_dir = '~/Desktop/plots';

% Load the file
load(file_path)

% Which file to print
n = 1;

% Number of files
num_files = length(FlowData);

% Figure out which plots have 10k frames
valid_trials = [];

for k = 1 : num_files
   if length(FlowData{k}.Time) == 10000
       valid_trials(end + 1) = k;
   end
end

% Number of animals
for k = 1 : length(FlowData)
   names{k} = FlowData{k}.TrialName; 
end
animal_names = unique(names);

% NUmber of aninmals
num_animals = length(animal_names);

% Number of valid trials
num_valid = length(valid_trials);

% Horizontal coordinate of plots
x = 0;

% Plot marker amplitude
amplitude = 2E2;



% Loop over animals
for n = 1 : num_animals
    animal_name = animal_names{n};
    
    Data{n}.Animal = animal_name;
    Data{n}.Velocity = [];
    Data{n}.Time = [];
    
    running_max = 0;
    
    for k = 1 : num_valid    
        t_num = valid_trials(k);
        if strcmpi(FlowData{t_num}.TrialName, animal_name)
            Data{n}.Velocity = [Data{n}.Velocity; FlowData{t_num}.Velocity];
            Data{n}.Time = [Data{n}.Time; FlowData{t_num}.Time + running_max];
            running_max = running_max + max(FlowData{t_num}.Time);      
        end
    end
    
end

% Find how many animals have velocity data
trials_with_data = [];
for n = 1 : num_animals
    if length(Data{n}.Velocity) > 1
        trials_with_data(end + 1) = n;
    end
end

% Number with data
num_with_data = length(trials_with_data);

for n = 1 : num_with_data
   
    num_reversals = 0;
    
    t_num = trials_with_data(n);
    time_sec = Data{t_num}.Time * 60;
    u_mms = Data{t_num}.Velocity;
    
    [pks_pos, locs_pos] = findpeaks(u_mms);
    [pks_neg, locs_neg] = findpeaks(-1 * u_mms);
    
    all_locs = sort([locs_pos; locs_neg]);
    
    % Read the values of the velocity data at the locs
    all_peaks = u_mms(all_locs);
    all_times = time_sec(all_locs);
    
    num_peaks = length(all_peaks);
    for k = 2 : num_peaks 
       peak_prod = all_peaks(k) * all_peaks(k - 1);
       
       if peak_prod < 0
           
           %%% IN PROGRESS
           num_reversal = num_reversals + 1;
%            reversal_
       end
        
        
    end
    
    
    
end


f = figure;
set(f, 'visible', 'off')

for k = 1 : 1000
    
    plot_name = sprintf('plot_%06d.png', k);
    plot_path = fullfile(plot_dir, plot_name);
    
    for n = 1 : num_with_data
        t_num = trials_with_data(n);
        u_mms = Data{t_num}.Velocity(k);
        
        if u_mms > 0
            y = 1;
        elseif u_mms < 0
            y = -1;
        end
        
        % Marker size
        marker_size = amplitude * abs(u_mms) + eps;
 
        subplot(1, num_with_data, n);
        scatter(x, y, marker_size,...
            'blue', 'filled', ...
            'markerfacealpha', 0.5);
           xlim([-1, 1]);
           ylim([-1.5, 1.5]);
           pbaspect([1, 3, 1])
           grid on
           set(gca, 'xticklabel', []);
           set(gca, 'yticklabel', []);
           box on
   
        
        
    end
    
   print(f, '-dpng', '-r200', plot_path);
   
end











