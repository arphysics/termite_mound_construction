function [air_vel_trans_matrix, air_vel_magnitude_image] = termiteCalculateAirVel(system, temp_grad_image)
%fprintf('At termiteCalculateAirVel!')


%Sets up a linear equation to determine the air velocity at fixed permeability.

interior_or_ground = or(system.is_interior, system.is_below_ground);
not_in_air = or(interior_or_ground, system.is_wall);
[not_air_index_array, not_air_index_to_array_helper] = indexArrayAndHelper(not_in_air);
n_not_air_points = sum(not_in_air(:));

[interior_index_array, interior_index_to_array_helper] = indexArrayAndHelper(system.is_interior);
n_interior_points = sum(system.is_interior(:));

pressure_matrix = sparse(n_interior_points, n_interior_points);
%pressure_matrix = zeros(sysparams.array_size); %Pressure is the independent variable we solve for, such that the net outwards
%flow(divergence) of each cell is 0.
pressure_matrix(1, 1) = -1;% To set the average pressure to 0. This way MATLAB doesn't complain that the matrix is singular



%The base divergence if pressure were zero everywhere(Changes in temperature and airflow would give us divergence)
base_divergence = zeros(n_interior_points, 1);



%Calculates the air flows
delta_iX = [1 0];
delta_iY = [0 1];
for iX = 1:(size(interior_index_array, 2) -1)
    for iY = 1:(size(interior_index_array, 1) - 1)
        
        for which_neighbor = 1:2
            
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_in_interior = system.is_interior(iY, iX);
            neighbor_in_interior = system.is_interior(neighbor_iY, neighbor_iX);
            
            %blah--area
            air_trans_coeff = neighbor_area/system.params.cell_width;
            
            if(and(box_in_interior, neighbor_in_interior))
                box_index = interior_index_array(iY, iX);
                neighbor_index = interior_index_array(neighbor_iY, neighbor_iX);
                %%Adds the diagonal coefficients corresponding to Air
                %%Conduction
                pressure_matrix(box_index, box_index) = pressure_matrix(box_index, box_index) + air_trans_coeff;
                pressure_matrix(neighbor_index, neighbor_index) = pressure_matrix(neighbor_index, neighbor_index) + air_trans_coeff;
                
                %Adds off-diagonal components
                pressure_matrix(box_index, neighbor_index) = pressure_matrix(box_index, neighbor_index) - air_trans_coeff;
                pressure_matrix(neighbor_index, box_index) = pressure_matrix(neighbor_index, box_index) - air_trans_coeff;
                
                if(which_neighbor == 2)
                    %Vertical neighbor so we add divergence from buoyancy
                    upper_buoyant_force = system.params.cell_width*  mean([temp_grad_image(iY, iX), temp_grad_image(iY+1, iX)]);
                    base_divergence(box_index) = base_divergence(box_index)  + air_trans_coeff *upper_buoyant_force;
                    base_divergence(neighbor_index) = base_divergence(neighbor_index)  -air_trans_coeff *upper_buoyant_force;
                end
            end
            
        end
    end
    
end

%We have now set up the pressure matrix

pressure_vector = pressure_matrix \ -base_divergence;
%Actually solves for it
%The pressure must cancel out what the base divergence would be, s.t. the actual divergence is 0.

%Calculates the heat flow from each cell to each other cell. This gives us
%the heat transfer matrix and the heat transfer vector for convection. This uses an upstreaming scheme, where the heat
%transfer between two cells depends on the temperature of the cell that the air is leaving.

%A check that the total divergence is zero. If it's not, then we have set up the linear problem incorrectly
total_divergence = zeros(n_interior_points, 1);


air_vel_trans_matrix = sparse(n_not_air_points, n_not_air_points); %Takes in concentrations and gives a flow rate
air_vel_mag_squared = zeros(n_not_air_points, 1);

delta_iX = [1 0];
delta_iY = [0 1];
for iX = 1:(size(interior_index_array, 2) -1)
    for iY = 1:(size(interior_index_array, 1) - 1)
        
        for which_neighbor = 1:2
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_in_interior = system.is_interior(iY, iX);
            neighbor_in_interior = system.is_interior(neighbor_iY, neighbor_iX);
            
%            fprintf('\n')
%            fprintf('Neighbor area is %f \n', neighbor_area)
            
            %blah--neighbor area
            air_trans_coeff = neighbor_area/system.params.cell_width;
%            fprintf('air_trans_coeff is %f \n', air_trans_coeff)
            
            
            if(and(box_in_interior, neighbor_in_interior))
                box_index = interior_index_array(iY, iX);
                neighbor_index = interior_index_array(neighbor_iY, neighbor_iX);
                
                box_press = pressure_vector(box_index);
                neighbor_press = pressure_vector(neighbor_index);
                air_trans_rate = air_trans_coeff  * (box_press-neighbor_press);
                
                if(which_neighbor == 2)
                    %Vertical neighbor so we add buoyancy
                    upper_buoyant_force = system.params.cell_width*  mean([temp_grad_image(iY, iX), temp_grad_image(iY+1, iX)]);
                    air_trans_rate  = air_trans_rate + air_trans_coeff * upper_buoyant_force;
                end
                
                
                total_divergence(box_index) = total_divergence(box_index) + air_trans_rate;
                total_divergence(neighbor_index) = total_divergence(neighbor_index) - air_trans_rate;
                
                
                
                
                
                %Upwinding scheme
                outwards_flow = air_trans_rate > 0;
                box_not_air_index = not_air_index_array(iY, iX);
                neighbor_not_air_index = not_air_index_array(neighbor_iY, neighbor_iX);
                
                air_vel = air_trans_rate/neighbor_area;
%                fprintf('Adding air vel of %f \n', air_vel)
                
                air_vel_mag_squared(box_not_air_index) = air_vel_mag_squared(box_not_air_index)  + air_vel^2;
                air_vel_mag_squared(neighbor_not_air_index) = air_vel_mag_squared(neighbor_not_air_index)  + air_vel^2;
                
                
                from_index = myTern(outwards_flow , box_not_air_index, neighbor_not_air_index);
                to_index =   myTern(~outwards_flow, box_not_air_index, neighbor_not_air_index);
                air_vel_trans_matrix(from_index, from_index) = air_vel_trans_matrix(from_index, from_index) - abs(air_trans_rate);
                air_vel_trans_matrix(to_index, from_index) = air_vel_trans_matrix(to_index, from_index)  + abs(air_trans_rate);
            end
        end
    end
end





%Makes sure that divergence is very small

%fprintf('Mean divergence is %f \n', mean(total_divergence(:)))

if(max(abs(total_divergence))> .000001)
    fprintf('Max divergence is %f, aborting \n', max(abs(total_divergence(:))));
    abort;
else
%    fprintf('Max divergence is %f, Everythings in the clear! \n', max(abs(total_divergence(:))));
end


air_vel_magnitude_image = zeros(size(not_in_air));
air_vel_magnitude_image(not_air_index_to_array_helper) = air_vel_mag_squared.^(.5);

