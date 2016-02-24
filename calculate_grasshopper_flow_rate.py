import numpy as np
import h5py
import matplotlib.pyplot as plt
import os
import time
import pdb
import matplotlib

def load_mat(file_path = None, variable_name = None, output_path = None):
    if file_path is not None:
        
        # Load the file
        file = h5py.File(file_path, 'r')
        
        # Get the variable
        vel_array = file.get(variable_name)
        
        # Time vector
        time_vect = np.array(file.get('Data/Time')) / 60;
        
        # Shape of the data    
        num_regions, height, width = vel_array.shape; 
        
        # Allocate the flow rate array
        mean_flow = np.zeros(num_regions);  
        
        # Loop over the regions
        for kk in range(num_regions):
            
            print("On region " + str(kk) + " of " + str(num_regions))
            
            # Extract the slice
            uu = vel_array[kk, :, :]
            
            # Calculate the mean velocity
            mean_flow[kk] = -1 * np.nanmean(uu)
        
        # pdb.set_trace()
            
        max_vel = np.nanmax(np.abs(mean_flow));
        
        # Plot
        fig = plt.figure()
        
        # 1D plot
        plt.plot(time_vect, mean_flow / max_vel, '.k', markersize=10)
        
        plt.xlabel('Time (minutes)')
        plt.ylabel('Flow velocity (normalized to max)')
        plt.xlim([0,4])
        plt.ylim([-1.1, 1.1])
        plt.title('Flow velocity in a grasshopper heart')
        matplotlib.rc('xtick', labelsize = 20) 
        matplotlib.rc('ytick', labelsize = 20)
        
        font = {'family' : 'normal',
                'size'   : 18}

        matplotlib.rc('font', **font)
        
        fig.savefig(output_path, format = 'pdf', facecolor='white', edgecolor='none')
        
        # Show the plot
        # plt.show()
        

 
# Main script
file_dir = "/Users/matthewgiarra/Desktop/grasshopper/short_axis"

file_list = os.listdir(file_dir)

f_num = 0

for file_name in file_list:
    file_path = os.path.join(file_dir, file_name)
    output_path = "file_" + str(f_num) + ".pdf"
    load_mat(file_path = file_path, variable_name = 'Data/Velocity', output_path = output_path)
    f_num += 1
    

# file_name = "test_data.mat"
#          
# file_path = os.path.join(file_dir, file_name)



             
             
             
        