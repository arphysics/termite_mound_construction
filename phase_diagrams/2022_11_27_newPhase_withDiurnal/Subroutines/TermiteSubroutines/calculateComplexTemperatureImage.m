function[complexTemperatureImage] =  calculateComplexTemperatureImage(system)
fprintf('At calculateComplexTemperatureImage!')
interior_or_ground = or(system.is_interior, system.is_below_ground);
not_in_air = or(interior_or_ground, system.is_wall);

[index_array, index_to_array_helper] = indexArrayAndHelper(not_in_air);
n_therm_points = sum(not_in_air(:));

therm_matrix = sparse(n_therm_points, n_therm_points);

delta_iX = [1 0];
delta_iY = [0 1];
therm_target_vector = zeros(n_therm_points, 1); %Units of heat/time

for iX = 1:(size(index_array, 2) -1)
    for iY = 1:(size(index_array, 1) - 1)
        
        for which_neighbor = 1:2
            %fprintf("%d \n", which_neighbor);
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_not_in_air = not_in_air(iY, iX);
            neighbor_not_in_air = not_in_air(neighbor_iY, neighbor_iX);
            
            
            %%Adds the diagonal coefficients corresponding to conductions
            %blah--area
            heat_trans_coeff = system.params.thermDiffus * neighbor_area/system.params.cell_width;
            
            if(box_not_in_air)
                box_index = index_array(iY, iX);
                therm_matrix(box_index, box_index) = therm_matrix(box_index, box_index) - heat_trans_coeff;
                if(~neighbor_not_in_air)
                    therm_target_vector(box_index) = therm_target_vector(box_index) + heat_trans_coeff;
                end
                
                
                if(iY ==1)
                   therm_matrix(box_index, box_index) = therm_matrix(box_index, box_index) - heat_trans_coeff;
                   %%Lower boundary condition for oscillation is 0                   
                end
            end
            
            if(neighbor_not_in_air)
                neighbor_index = index_array(neighbor_iY, neighbor_iX);
                therm_matrix(neighbor_index, neighbor_index) = therm_matrix(neighbor_index, neighbor_index) - heat_trans_coeff;
                if(~box_not_in_air)
                    therm_target_vector(neighbor_index) = therm_target_vector(box_index) + heat_trans_coeff;
                end
            end
            
            %%Adds off-diagonal conduction coefficients
            if(and(box_not_in_air, neighbor_not_in_air))
                therm_matrix(box_index, neighbor_index) = therm_matrix(box_index, neighbor_index) + heat_trans_coeff;
                therm_matrix(neighbor_index, box_index) = therm_matrix(neighbor_index, box_index) + heat_trans_coeff;
            end
        end
        %%Adds the diagonal coefficients related to oscillation
        
        if(box_not_in_air)
            box_index = index_array(iY, iX);
            therm_matrix(box_index, box_index) = therm_matrix(box_index, box_index) - 1.0*1i * system.cell_volume(iY, iX);
        end
        
        
    end
end

therm_solution = therm_matrix\therm_target_vector;

complexTemperatureImage = zeros(size(index_array));
complexTemperatureImage(index_to_array_helper) = therm_solution;

