function [ ] = generate_permittivity_map_function( numberID )
% Identical to generate_permittivity_map script but functionised to allow
% for input argument numberID to speed up process

%% Generates permittivity map, given relevant .in file

% Hack function - temporary
%   Grabs rebar information from .in file using format that was specified
%   in generate_environment.m
fname = sprintf('./in_files/sim%d.in',numberID);

%% Grab general information. Test, turn into a function if it works

fid=fopen(fname,'r');  % check for success in real life...
line_data = textscan(fid,'%s%s','Delimiter',':','headerlines',18);
fid = fclose(fid);

shape = line_data{1};
size_material = line_data{2};

for i=1:size(size_material,1)
    [text,~,~,nextindex] = sscanf(size_material{i},'%f');
    text = text';
    material{i} = size_material{i}(nextindex:end);
    
    if (strcmpi(shape{i},"#box"))
    box(i,:) = text;
    
    elseif (strcmpi(shape{i},"#cylinder"))
    cylinder(i,:) = text;
    
    end
end

%material = material';

%% Environment details
discretization = 0.002;
step_size = 0.002;
x_offset = 0.1;
y_depth = 0.25;

%% draw permittivity map from location of rebars
% Permittivity scale as follows:
% Function: divide permittivity by 100, then use negative scaled logit function
% below to calculate new image intensity values

syms f(x) g(x)
f(x) = -(0.5 +(log(x/(1-x))/log(99)/2)) + 1;
g(x) = -(0.5 +(log((x/100)/(1-(x/100)))/log(99)/2)) + 1;

air = double(g(1));
concrete = double(g(10));
water = double(g(80));
rebar = double(g(99)); 

map = ones(125, 5000);
map = map*concrete;

%% Due to the way layering in gprMax works, make sure to do air first then rebar

%% For air
% for i=1:size(x1,1)
%     map = insertShape(map, 'FilledRectangle',...
%         [round((x1(i)-x_offset)*1000/2), 0, ...
%         (x2(i)-x1(i))*1000*2, round((y2(i)-y1(i))*1000/2)], ...
%         'Color',[1 1 1],'Opacity', 1 );
% end

if exist('box', 'var')
    for i=1:size(box,1)
        
        if (strcmpi(material{i},"water"))
            box_material = water;
        
        elseif (strcmpi(material{i},"pec"))
            box_material = rebar;

        elseif (strcmpi(material{i},"air"))
            box_material = air;
        end        
        
        %% Scaling applied! to make calculating losses easier. depth doubled. Width cant since it will overlap with other scenes when cropped.
        
        map = insertShape(map, 'FilledRectangle',...
            [round((box(i,1)-x_offset)*1000/2), ...
            round((y_depth - box(i,5))*1000/2), ...
            (box(i,4)-box(i,1))*1000/2, ...
            round((box(i,5)-box(i,2))*1000/2)*2], ...
            'Color',[box_material box_material box_material],'Opacity', 1 );
    end
end

%% For rebar
% for i=1:size(radius,1)
%     map = insertShape(map, 'FilledCircle', ...
%         [round((x(i)-x_offset)*1000/2), round((y_depth-y(i))*1000/2), radius(i)*1000*2],...
%         'Color',[0 0 0],'Opacity', 1 );     
% end



if exist('cylinder', 'var')
    cylinder_material = 0;
    
    for i=1:size(cylinder,1)
        
        if (strcmpi(material{i},"water"))
        cylinder_material = water;
        
        elseif (strcmpi(material{i},"pec"))
        cylinder_material = rebar;

        elseif (strcmpi(material{i},"air"))
        cylinder_material = air;
        end        

        %% Scaling applied! to make calculating losses easier. Radius doubled
        
        map = insertShape(map, 'FilledCircle', ...
            [round((cylinder(i,1)-x_offset)*1000/2), round(((y_depth-cylinder(i,2))*1000/2)),...
            cylinder((i),7)*1000*2],...
            'Color',...
            [cylinder_material cylinder_material cylinder_material],...
            'Opacity', 1 );     
    end
end

%% mapping
map = map(:,:,1);

im_map = mat2gray(map, [0 1]);
imshow(im_map);

combined_filename = sprintf('permittivity_map_images/gt%d.png', numberID);
imwrite(im_map,combined_filename);

%% Added to make sure that the images are loaded fresh and variables are cleared during image creation
clear;


end

