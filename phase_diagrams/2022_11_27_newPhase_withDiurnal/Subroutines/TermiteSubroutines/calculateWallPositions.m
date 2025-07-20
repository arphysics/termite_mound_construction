function[wall_positions] =  calculateWallPositions(system)


my_filter = double(int64 (fspecial('disk', system.params.i_wall_thickness)  >0 ));


close_to_interior = imfilter(double(int64(system.is_interior)), my_filter) > 0;


wall_positions = and(and(close_to_interior, ~system.is_below_ground), ~system.is_interior);
