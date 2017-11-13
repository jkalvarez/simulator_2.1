function [] = generate_dataset(training_set, testing_set, sim_path, gt_path)
%% Generates dataset from gprMax simulation output and permittivity map
%   Takes simualation id matrix/array of sims to be converted. First
%   arg is training set id array, second arg is testing set id array.

%   generate_dataset([], [], "./gprMax_output/", "./permittivity_map_images/")
%   generate_dataset([1 2 3 5 6 7 9 10 11 13 14 15 17 18 19], [4 8 12 16 20], "./gprMax_output/", "./permittivity_map_images/");

%   pec water differentiation test
%   generate_dataset([1 2 3 13 14 15 17 18 19], [4 16 20], "./gprMax_output/", "./permittivity_map_images/");

%   Dataset is saved into combined_images under train-test-val folders.
%   Training set is 10:1 to testing. 

%%  Loads training simulation dataset

image_count = 1;

for i=1:size(training_set,2) 
    % Go through training id sets and store in ./combined_images/train
    
    % ./permittivity_map_images/
    gt_filename = char(sprintf(gt_path + 'gt%d.png', training_set(i)));
    image_gt = imread(gt_filename);
    
    % try .out file, if error thrown, then txt file
    try
        % ./gprMax_output/
        sim_filename = char(sprintf(sim_path + 'sim%d_merged.out', training_set(i)));
        % Load HDF5 file
        data = hdf5read(sim_filename, 'rxs/rx1/Ez');
        data = double(data)';

        
    catch
        sim_filename = char(sprintf(sim_path + 'sim%d.txt', training_set(i)));
        data = importfile(sim_filename);
    end
    
    image_gprMax = process_gprMax_data(data);
    
    image_stride = 4;
    
    image_count = combine_image(image_count, image_stride, image_gprMax, image_gt, "./combined_images/train/");
    
end

%% Loads testing simulation dataset. Note kept seperate for a reason, rather than functionised.
image_count = 1;

for i=1:size(testing_set,2) 
    % Go through testing id sets and store in ./combined_images/test
    
    % ./permittivity_map_images/
    gt_filename = char(sprintf(gt_path + 'gt%d.png', testing_set(i)));
    image_gt = imread(gt_filename);
    
    % try .out file, if error thrown, then txt file
    try
        % ./gprMax_output/
        sim_filename = char(sprintf(sim_path + 'sim%d_merged.out', testing_set(i)));
        % Load HDF5 file
        data = hdf5read(sim_filename, 'rxs/rx1/Ez');
        data = double(data)';

        
    catch
        sim_filename = char(sprintf(sim_path + 'sim%d.txt', testing_set(i)));
        data = importfile(sim_filename);
    end
    
    image_gprMax = process_gprMax_data(data);
    
    image_stride = 40;
    
    image_count = combine_image(image_count, image_stride, image_gprMax, image_gt, "./combined_images/val/");
    
end

end

function image_count = combine_image(image_count_initial, stride, gpr, gt, image_path)

    % Starting image number. Used for creating image file names that don't
    % start at 1. 
    image_count = image_count_initial;

    for i=1:stride:4800
        a = imcrop(gpr,[i 1 124 125]);
        b = imcrop(gt,[i 1 124 125]);

        %Image concatenation
        c = [a b];
        combined_filename = char(sprintf(image_path+'%d.png', image_count));
        imwrite(c, combined_filename);

        image_count = image_count + 1;

    end
    
end


