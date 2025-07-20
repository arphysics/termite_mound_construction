function[image_to_print] =  printState(system, title_string)


image_to_print = 255 * ones(system.params.array_height, system.params.array_width, 3);



interior_color = [34 96 147]; %bluish
ground_color = [128 64 1]; %Brown

wall_color = [100 100 100]; %Dark Grey



image_to_print = colorAllRegions(image_to_print, system.is_below_ground, ground_color);
image_to_print = colorAllRegions(image_to_print, system.is_interior, interior_color);
image_to_print = colorAllRegions(image_to_print, system.is_wall, wall_color);



%Flip the image
image_to_print = flipud(image_to_print);
imwriteWithPath(image_to_print * 1./255., title_string);







