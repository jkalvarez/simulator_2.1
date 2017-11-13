%% Generate randomized environment .in file for gprMax
% Author: Jean Kyle Alvarez

%% Setup - General setup of environment

fileID = fopen('in_files/sim.in','w');
fprintf(fileID, 'testingplz \n');

% Specify title of environment
title = 'Randomly Generated Environment';

% Specify domain [x y z]
% Note add extra 100mm on both sides in x direction, 50mm on y
% Domain size is 10000mm x 250mm 2D
domain = [10.2 0.300 0.002];
fprintf(fileID, '#domain: %.3f %.3f %.3f \n', domain);

% Specify discretization [x y z]
discretization =  [0.002 0.002 0.002];
fprintf(fileID, '#dx_dy_dz: %.3f %.3f %.3f \n', discretization);

% Specify time window [s]
time_window = 5e-9;
fprintf(fileID, '#time_window: %d \n', time_window);

%% Sources - Setup source waveforms

% Name of source excitation file
excitation_file = 'mala_source_modified.txt';
fprintf(fileID,'\n#excitation_file: %s \n', excitation_file);

% Source type (Hertzian Dipole) [polarization x y z ID ]
% x offset = 0.1 - 0.14/2 | 0.1 + 0.14/2
source = 'z 0.030 0.250 0 mala_source';
fprintf(fileID,'#hertzian_dipole: %s \n', source);

% Receiver location, and distance to move source and receiver
% x offset = 0.03 from left for source, receiver + 0.07 for 140mm antenna gap 
% y offset = 0.05 from top / 0.25 from bottom
rx = [0.170 0.250 0];
src_steps = [0.002 0 0];
rx_steps =  [0.002 0 0];

fprintf(fileID, '#rx: %.3f %.3f %.3f \n', rx);
fprintf(fileID, '#src_steps: %.3f %.3f %.3f \n', src_steps);
fprintf(fileID, '#rx_steps: %.3f %.3f %.3f \n', rx_steps);

%%  Materials - define materials
% #material: relative_perm conductivity(S/m) relative_permeability magnetic_loss(Ohm/m) ID

concrete = [10 0.22 1 0];
rebar =  [1 10000000 100 0];
air =  [1 0 1 0];
water = [80 0.5 1 0];

fprintf(fileID, '\n#material: %.3f %.3f %.3f %.3f concrete\n', concrete);
fprintf(fileID, '#material: %.3f %.3f %.3f %.3f rebar\n', rebar);
fprintf(fileID, '#material: %.3f %.3f %.3f %.3f air\n', air);
fprintf(fileID, '#material: %.3f %.3f %.3f %.3f water\n', water);

%%  Materials - define environment
% All the randomization belongs here

% #cylinder: [x, y, z, x2, y2, z2, r, material, smoothing (y/n)]
% #box: bl(x, y, z) ur(x, y, z) material sm
% #triangle: x1, y1, z1, x2, y2, z2, x3, y3, z3, thickness, material, sm

%% seed the rng to stop horrible duplicates
seed = posixtime(datetime());
rng(seed);

%% Concrete - Generate concrete box
% CONCRETE SPECIFICATIONS
% Domain = 10000mm (travel) x 250mm (depth)
% #box: 0 0 0 10.200 0.250 0.002 concrete
generate_concrete = [0 0 0 10.2 0.25 0.002];
generate_concrete_string = fprintf(fileID,'\n#box: %.3f %.3f %.3f %.3f %.3f %.3f concrete\n\n', generate_concrete);

% Draw concrete - each pixel is 2mm. Base template 125x500x3
x = imread('template.png'); 

%% Void (Air) - Randomly generate air voids according to spec
% AIR VOID SPECIFICATIONS 

% % Starting x distance for randomization
% current_distance = 0;
% air_min_spacing = 100; % 500 normally
% air_max_spacing = 500; % 1000 normally
% 
% 
% while current_distance <= 10100
%     air_x = randi([current_distance + air_min_spacing, current_distance + air_max_spacing]); % in m /1000;
%     air_depth_mm = randi([250-150,250-20]); % in m /1000;
%     air_width_mm = randi([2,10]); % width
%        
%     % Update current distance now to allow for rebar domain check
%     current_distance = air_x;
%     
%     % Gross but is a break to stop adding air once last one is added and
%     % is actually outside the domain 
%     
%     if current_distance > 10100
%         break;
%     end
%     
%     % Done before to allow conversion into m from mm
%     x = insertShape(x, 'FilledRectangle', [(current_distance-100)/2, 0, air_width_mm*2, (250-air_depth_mm)/2], ...
%         'Color','green','Opacity', 1 );
%     
%     % Convert measurements to m. Now air_x chosen so that current
%     % distance stays in mm. Lazy - rewrite plz
%     air_x = air_x/1000;
%     air_depth = air_depth_mm/1000;
%     air_width = air_width_mm/1000; 
%     
%     generate_air = [air_x, air_depth, 0, (air_x + air_width), 0.25, 0.002];
%     generate_air_string = fprintf(fileID,'#box: %.3f %.3f %.3f %.3f %.3f %.3f air\n', generate_air);
%     
% end

%% Void (Water) - Randomly generate water voids according to spec
% WATER VOID SPECIFICATIONS 

% Starting x distance for randomization
% current_distance = 0;
% water_min_spacing = 100;
% water_max_spacing = 500;
% 
% 
% while current_distance <= 10100
%     water_x = randi([current_distance + water_min_spacing, current_distance + water_max_spacing]); % in m /1000;
%     water_depth_mm = randi([250-150,250-80]);
%     water_size_mm = randi([10,30])/2; % Radius 
%        
%     % Update current distance now to allow for rebar domain check
%     current_distance = water_x;
%     
%     % Gross but is a break to stop adding rebar once last one is added and
%     % is actually outside the domain 
%     
%     if current_distance > 10100
%         break;
%     end
%     
%     % Done before to allow conversion into m from mm
%     x = insertShape(x, 'FilledCircle', [(current_distance-100)/2, (250-water_depth_mm)/2, water_size_mm*2],'Color','blue','Opacity', 1 );
%     
%     % Convert measurements to m. Notw rebar_x chosen so that current
%     % distance stays in mm. Lazy - rewrite plz
%     water_x = water_x/1000;
%     water_depth = water_depth_mm/1000;
%     water_size = water_size_mm/1000; 
% 
%     generate_water = [water_x, water_depth, 0, water_x, water_depth, 0.002, water_size];
%     generate_water_string = fprintf(fileID,'#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f water\n', generate_water);
%     
% end 

%% Rebar - Randomly generate rebar according to spec
% REBAR SPECIFICATIONS
% Size of rebar = between 10mm and 20mm in 1mm sizes (standard specifies
% 10, 12, 16, 20). 1mm for size estimation due to corrosion etc
% Depth of rebar = randomized between 20-100mm (AS:3600 states 15-78mm)
% Rebar spacing = randomized between 100-300mm spacing
% number of rebar = minimum 5, maximum 10 (based on min max spacing)

% Starting x distance for randomization
current_distance = 0;
rebar_min_spacing = 100;
rebar_max_spacing = 300;


while current_distance <= 10100
    rebar_x = randi([current_distance + rebar_min_spacing, current_distance + rebar_max_spacing]); % in m /1000;
    rebar_depth_mm = randi([250-150,250-30]);
    rebar_size_mm = randi([10,20])/2; % Radius 
       
    % Update current distance now to allow for rebar domain check
    current_distance = rebar_x;
    
    % Gross but is a break to stop adding rebar once last one is added and
    % is actually outside the domain 
    
    if current_distance > 10100
        break;
    end
    
    % Done before to allow conversion into m from mm
    x = insertShape(x, 'FilledCircle', [(current_distance-100)/2, (250-rebar_depth_mm)/2, rebar_size_mm*2],'Color','red','Opacity', 1 );
    
    % Convert measurements to m. Notw rebar_x chosen so that current
    % distance stays in mm. Lazy - rewrite plz
    rebar_x = rebar_x/1000;
    rebar_depth = rebar_depth_mm/1000;
    rebar_size = rebar_size_mm/1000; 

    generate_rebar = [rebar_x, rebar_depth, 0, rebar_x, rebar_depth, 0.002, rebar_size];
    generate_rebar_string = fprintf(fileID,'#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f rebar\n', generate_rebar);
    
end 

%%
imwrite(x,'ground_truth_images/gt.png');
