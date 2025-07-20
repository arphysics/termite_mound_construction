function[gas_matrix] =  calculateGasDiffusionMatrix(system)

interior_or_ground = or(system.is_interior, system.is_below_ground);
not_in_air = or(interior_or_ground, system.is_wall);

[index_array, index_to_array_helper] = indexArrayAndHelper(not_in_air);
n_gas_points = sum(not_in_air(:));

gas_matrix = sparse(n_gas_points, n_gas_points);%Takes concentrations and gives gas flow

delta_iX = [1 0];
delta_iY = [0 1];

for iX = 1:(size(index_array, 2) -1)
    for iY = 1:(size(index_array, 1) - 1)
        
        for which_neighbor = 1:2
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_not_in_air = not_in_air(iY, iX);
            neighbor_not_in_air = not_in_air(neighbor_iY, neighbor_iX);
            

            box_underground = system.is_below_ground(iY, iX);
            neighbor_underground = system.is_below_ground(neighbor_iY, neighbor_iX);
            
            box_in_interior_or_wall = or(system.is_interior(iY, iX), system.is_wall(iY, iX));
            neighbor_in_interior_or_wall = or(system.is_interior(neighbor_iY, neighbor_iX), system.is_wall(neighbor_iY, neighbor_iX));
            
            %%Adds the diagonal coefficients corresponding to conductions
            %blah--area
            gas_trans_coeff = system.params.gasDiffus * neighbor_area/system.params.cell_width;
            %gas_trans_coeff = system.params.gasDiffus/system.params.cell_width;
            if(box_not_in_air)
                box_index = index_array(iY, iX);
                gas_matrix(box_index, box_index) = gas_matrix(box_index, box_index) - gas_trans_coeff;
                
                if(iY ==1)                    
                   %%Lower boundary condition for concentration is 0                   
                   gas_matrix(box_index, box_index) = gas_matrix(box_index, box_index) - gas_trans_coeff;
                end
            end
            
            if(neighbor_not_in_air)
                neighbor_index = index_array(neighbor_iY, neighbor_iX);
                gas_matrix(neighbor_index, neighbor_index) = gas_matrix(neighbor_index, neighbor_index) - gas_trans_coeff;
            end
            
            %%Adds off-diagonal conduction coefficients
            
            interior_or_wall_next_to_exterior_below_ground = and(xor(box_in_interior_or_wall, neighbor_in_interior_or_wall), or(box_underground, neighbor_underground));
            underground_hacked_dont_do_coupling = and(interior_or_wall_next_to_exterior_below_ground, system.params.dont_model_underground);
            
            if(and(box_not_in_air, neighbor_not_in_air) && (~underground_hacked_dont_do_coupling))
                gas_matrix(box_index, neighbor_index) = gas_matrix(box_index, neighbor_index) + gas_trans_coeff;
                gas_matrix(neighbor_index, box_index) = gas_matrix(neighbor_index, box_index) + gas_trans_coeff;
            end
        end
    end
end



