function[system] =  updateTermiteInterior(system, mean_gas_conc, thresh, tol)
neighbor_filter = [0, 1 , 0; 1, 1, 1; 0, 1, 0];

not_interior_float = double(int64(~system.is_interior));
near_not_interior = imfilter(not_interior_float, neighbor_filter);


inside_interior_points = and(near_not_interior>0, system.is_interior);

points_to_be_removed = and(inside_interior_points, mean_gas_conc < (thresh * (1-tol)));



is_interior_float = double(int64(system.is_interior));
near_interior = imfilter(is_interior_float, neighbor_filter);
outside_interior_points = and(near_interior>0, ~system.is_interior);


points_to_be_added = and(outside_interior_points, mean_gas_conc > (thresh * (1+tol)));

system.is_interior(points_to_be_removed) = false;
system.is_interior(points_to_be_added) = true;

if(system.params.dont_model_underground)
    interior_above_ground = and(system.is_interior, ~system.is_below_ground);
    above_ground_radius = max(system.x_mesh(interior_above_ground));
    
    if(~isempty(above_ground_radius) & system.params.mound_collapse == 0)
        distance_from_origin = sqrt(system.x_mesh.^2 + system.y_mesh.^2);
    
        underground_dist_from_origin = distance_from_origin(system.below_ground_y_inds, :);
        underground_interior_mask = underground_dist_from_origin <=above_ground_radius;

        system.is_interior(system.below_ground_y_inds, :) = underground_interior_mask;
        
    else system.params.mound_collapse = 1;
        system.is_interior = system.is_interior;
        
    end
    
    
    
    
    
%     distance_from_origin = sqrt(system.x_mesh.^2 + system.y_mesh.^2);
%     
%     underground_dist_from_origin = distance_from_origin(system.below_ground_y_inds, :);
%     underground_interior_mask = underground_dist_from_origin <=above_ground_radius;
%     
%     %fprintf("agr dim: %f, udfo dim: %f \n", size(above_ground_radius), size(underground_dist_from_origin));
% 
%     
%     
%     %underground_interior_mask = underground_dist_from_origin <=above_ground_radius;
%     
%     system.is_interior(system.below_ground_y_inds, :) = underground_interior_mask;
end
system.is_wall = calculateWallPositions(system);









