

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
    
    for k = 1 : num_valid
        t_num = valid_trials(k);
        if strcmpi(FlowData{t_num}.TrialName, animal_name)
            Data{n}.Velocity = [Data{n}.Velocity; FlowData{t_num}.Velocity];
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

nbins = 10;


for n = 1 : num_with_data
    
%    subplot(1, num_with_data, n);
   
   t_num = trials_with_data(n);
   
   u_mms = Data{t_num}.Velocity;
   u_max = max(abs(u_mms));
   u_pos = abs(u_mms(u_mms > 0)) ./ u_max;
   u_neg = abs(u_mms(u_mms < 0)) ./ u_max;
    
%    subplot(1, num_valid, n);
   violin2(u_pos, nbins, u_neg, nbins);
   xlim([0, 0.6])
   
   print(1, '-depsc', sprintf('~/Desktop/hists/plot_%03d.eps', n));
   
    
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











