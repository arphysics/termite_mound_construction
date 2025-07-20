function [colored_image] = colorAllRegions(image_to_color, mask,  image_to_imprint)
colored_image  = image_to_color;

for color_ind = 1:3
    cur_marked_image_color = image_to_color(:, :, color_ind);
    cur_image_to_imprint_color = image_to_imprint(:, :, color_ind);
    
    cur_marked_image_color(mask) = cur_image_to_imprint_color(mask);
    colored_image(:, :, color_ind) = cur_marked_image_color;
    
%    marked_image(center_mass_marker_mask, color_ind) = center_mass_marker_color(color_ind);
%    cur_marked_image_color    
end














