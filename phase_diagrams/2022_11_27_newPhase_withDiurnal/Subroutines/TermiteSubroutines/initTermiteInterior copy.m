function[is_interior] =  setTermiteInterior(system)
    %CUrrently just a dummy method
    
    radius_mesh = sqrt(system.x_mesh.^2 + system.y_mesh.^2);
    is_interior = radius_mesh < 2;
    

