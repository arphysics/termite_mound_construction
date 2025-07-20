%Converts a few things to lattice units and Makes meshes of values
system.params.cell_width = 1./system.params.graining;

system.params.i_wall_thickness = system.params.wall_thickness * system.params.graining;
system.params.array_width = system.params.width * system.params.graining;
system.params.array_height = system.params.height * system.params.graining;

system.x_values = system.params.cell_width * (-.5 + (1:system.params.array_width ));
system.y_values = system.params.cell_width * ( -.5 + (1:system.params.array_height)) - system.params.maxDepth;
[system.x_mesh, system.y_mesh] = meshgrid(system.x_values, system.y_values);
system.is_below_ground = system.y_mesh < 0;

dummy_list = 1:length(system.y_values);
system.below_ground_y_inds = dummy_list(system.y_values<0);

[junk, system.params.source_iX] = min(abs(system.x_values -system.params.source_X));
[junk, system.params.source_iY] = min(abs(system.y_values -system.params.source_Y));



%% Sets area and volume
%fprintf('Doing area and volume stuff \n');
system.right_area  = (system.x_mesh + (.5 * system.params.cell_width))* system.params.cell_width; %The radius times the height(Area)
system.upper_area  =.5 *( (system.x_mesh + (.5 * system.params.cell_width)).^2 - (system.x_mesh - (.5 * system.params.cell_width)).^2);
%The area of a pizza slice is .5 * r^2 * phi. Therefore, we take the outer area minus the inner area
system.cell_volume = system.upper_area * system.params.cell_width;
%The volume is the upper area times the height

