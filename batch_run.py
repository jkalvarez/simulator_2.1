# Testing

import os
from gprMax.gprMax import api

sims_to_run = [25, 26, 27, 28]

for item in sims_to_run: 
    filename_input = os.path.join('simulator_2.1', 'sim'+str(item)+'.in')
    print(filename_input)
    api(filename_input, n=5000, geometry_only=False, gpu=[True])    
    
    filename_output = os.path.join('simulator_2.1', 'sim'+str(item))
    print(filename_output)
    
    filename_merge = 'python -m tools.outputfiles_merge_no_prompt ' + filename_output
    print(filename_merge)
    os.system(filename_merge)
