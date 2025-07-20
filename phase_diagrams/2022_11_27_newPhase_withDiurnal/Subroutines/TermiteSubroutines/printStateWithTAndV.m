function[velocity_image_to_print] =  printStateWithTAndV(system, temperature_image, velocity_image, gas_image, title_string)


velocity_image_to_print = 0 * ones(system.params.array_height, system.params.array_width, 3);



interior_color = [34 96 147]; %bluish
ground_color = [128 64 1]; %Brown
%wall_color = [100 100 100]; %Dark Grey
wall_color = [220 0 220]; %Dark Blue


velocity_image_to_print = colorAllRegions(velocity_image_to_print, system.is_below_ground, ground_color);
velocity_image_to_print = colorAllRegions(velocity_image_to_print, system.is_interior, interior_color);
velocity_image_to_print = colorAllRegions(velocity_image_to_print, system.is_wall, wall_color);


rgb_velocity_image = gray2rgb(velocity_image);
velocity_image_to_print = replaceMaskWith(velocity_image_to_print, system.is_interior, 255 * rgb_velocity_image * 2.5);

%%%%Does the thermal image


thermal_image_to_print = 0 * ones(system.params.array_height, system.params.array_width, 3);
thermal_image_to_print(:, :, 3) = 200;
rgb_temperature_image = gray2rgb(temperature_image);

not_in_air = or(or(system.is_interior, system.is_wall), system.is_below_ground);
thermal_image_to_print = replaceMaskWith(thermal_image_to_print, not_in_air, (255/2) * (rgb_temperature_image + 1));



%%%%%%


gas_image_to_print =thermal_image_to_print;
rgb_gas_image = gray2rgb(gas_image);
gas_image_to_print = replaceMaskWith(thermal_image_to_print, not_in_air, 255 * rgb_gas_image * 1.);
%%%


%

total_image_to_print = flipud([thermal_image_to_print, velocity_image_to_print, gas_image_to_print]);
imwriteWithPath(total_image_to_print * 1./255., title_string);







