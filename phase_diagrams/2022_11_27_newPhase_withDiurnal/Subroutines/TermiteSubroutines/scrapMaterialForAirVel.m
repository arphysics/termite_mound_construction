function [air_vel_transf_matrix] = termiteCalculateAirVel(system, temp_grad_image)
%Sets up a linear equation to determine the air velocity at fixed permeability.



[index_array, index_to_array_helper] = indexArrayAndHelper(system.is_interior);
n_interior_points = sum(system.is_interior(:))

pressure_matrix = sparse(n_interior_points, n_interior_points)
%pressure_matrix = zeros(sysparams.array_size); %Pressure is the independent variable we solve for, such that the net outwards
%flow(divergence) of each cell is 0.

%The base divergence if pressure were zero everywhere(Changes in temperature and airflow would give us divergence)
base_divergence = zeros(sysparams.array_size, 1);




delta_iX = [1 0];
delta_iY = [0 1];
for iX = 1:(size(index_array, 2) -1)
    for iY = 1:(size(index_array, 1) - 1)
        
        for which_neighbor = 1:2
            
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_in_interior = system.is_interior(iY, iX);
            neighbor_in_interior = system.is_interior(neighbor_iY, neighbor_iX);
            
            air_trans_coeff = neighbor_area/system.params.cell_width;
            
            if(and(box_in_interior, neighbor_in_interior))
                box_index = index_array(iY, iX);
                neighbor_index = index_array(neighbor_iY, neighbor_iX);
                %%Adds the diagonal coefficients corresponding to Air
                %%Conduction
                pressure_matrix(box_index, box_index) = pressure_matrix(box_index, box_index) + air_trans_coeff
                pressure_matrix(neighbor_index, neighbor_index) = pressure_matrix(neighbor_index, neighbor_index) + air_trans_coeff
                
                %Adds off-diagonal components
                pressure_matrix(box_index, neighbor_index) = pressure_matrix(box_index, neighbor_index) - air_trans_coeff
                pressure_matrix(neighbor_index, box_index) = pressure_matrix(neighbor_index, box_index) - air_trans_coeff
                
                if(which_neighbor == 2)
                    %Vertical neighbor so we add divergence from buoyancy
                    upper_buoyant_force = system.params.graining*  mean([temp_grad_image(iY, iX), temp_grad_image(iY+1, iX)]);
                    base_divergence(box_index) = base_divergence(box_index)  + air_trans_coeff *upper_buoyant_force
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
total_divergence = zeros(sysparams.array_size, 1);


air_vel_transf_matrix = sparse(n_interior_points, n_interior_points); %Takes in concentrations and gives a flow rate

delta_iX = [1 0];
delta_iY = [0 1];
for iX = 1:(size(index_array, 2) -1)
    for iY = 1:(size(index_array, 1) - 1)
        
        for which_neighbor = 1:2
            neighbor_iX = iX + delta_iX(which_neighbor);
            neighbor_iY = iY + delta_iY(which_neighbor);
            neighbor_area = myTern(which_neighbor == 1, system.right_area(iY, iX), system.upper_area(iY, iX));
            
            box_in_interior = system.is_interior(iY, iX);
            neighbor_in_interior = system.is_interior(neighbor_iY, neighbor_iX);
            
            air_trans_coeff = neighbor_area/system.params.cell_width;
            
            
            if(and(box_in_interior, neighbor_in_interior))
                box_index = index_array(iY, iX);
                neighbor_index = index_array(neighbor_iY, neighbor_iX);
                
                box_press = pressure_vector(box_index);
                neighbor_press = pressure_vector(neighbor_index)
                air_transf_rate = air_trans_coeff  * (cur_press-neighbor_press);
                
                if(which_neighbor == 2)
                    %Vertical neighbor so we add buoyancy
                    upper_buoyant_force = system.params.graining*  mean([temp_grad_image(iY, iX), temp_grad_image(iY+1, iX)]);
                    air_transf_rate  = air_trans_rate + upper_buoyant_force
                end
                
                
                total_divergence(box_index) = total_divergence(box_index) + air_transf_rate
                total_divergence(neighbor_index) = total_divergence(neighbor_index) - air_transf_rate
                
                %Upwinding scheme
                outwards_flow = air_transf_rate > 0
                from_index = myTern(outwards_flow, box_index, neighbor_index)
                to_index = myTern(~outwards_flow, box_index, neighbor_index)
                air_vel_transf_matrix(from_index, from_index) = air_vel_transf_matrix(from_index, from_index) - abs(air_transf_rate);
                air_vel_transf_matrix(to_index, from_index) = air_vel_transf_matrix(to_index, from_index)  + abs(air_transf_rate(k));                
            end
        end
    end
end


    %Makes sure that divergence is very small
    if(max(abs(total_divergence))> .000001)
        fprintf('Max divergence is %f, aborting \n', max(abs(total_divergence(:))));
        abort;
    end





is_vert_help = [1 0]; %Just a little helper array to use for piecewise multiplication


for iX = 1:(sysparams.array_width-1)
    for iY = 1:(sysparams.array_height-1)
        
        
        %Makes the convective heat transfer matrix
        box_index = sysparams.index_array(iY, iX);
        cur_temp = guess_temp(iY, iX);
        
        
        %Figure out the pressure in our cell
        if(box_index ==-1)
            cur_press = 0; %Pressure outside of the cluster is zero
        else
            cur_press = pressure_vector(box_index);
        end
        
        
        %Upper neighbor
        neighbor_index(1) = sysparams.index_array(iY +1, iX);
        air_tranfer_coeff(1)=  harmmean([f.darcy(iY, iX)  f.darcy(iY+1, iX)]) * sysparams.upper_area(iY, iX)/sysparams.cell_width;
        neighbor_temp(1) = guess_temp(iY+1, iX);
        
        %Right(outer) neighbor
        neighbor_index(2) = sysparams.index_array(iY   , iX +1);
        air_tranfer_coeff(2) =  harmmean([f.darcy(iY, iX)  f.darcy(iY, iX+1)]) * sysparams.right_area(iY, iX)/sysparams.cell_width;
        neighbor_temp(2) = guess_temp(iY, iX+1);
        
        %Calculate pressure in neighbor cells
        for k = 1:2
            if(neighbor_index(k) == -1)
                neighbor_press(k) = 0;
            else
                neighbor_press(k) = pressure_vector(neighbor_index(k));
            end
        end
        
        
        %Air transfer due to buoyancy and pressure differences
        air_transf_rate = air_tranfer_coeff .* ...
            ((cur_press - neighbor_press) + is_vert_help .* (.5/sysparams.graining) .*(neighbor_temp + cur_temp - 2*sysparams.ambientT));
        
        
        
        
        for k = 1:2
            
            if(air_transf_rate(k) >0)
                from_index = box_index;
                to_index = neighbor_index(k);
                %Air going from cur to neighbor
            else
                from_index = neighbor_index(k);
                to_index = box_index;
                %Vice versa
            end
            
            
            
            if(from_index ~= -1)
                %Heat transferred away from from_index
                heat_transf_matrix(from_index, from_index) = heat_transf_matrix(from_index, from_index) - abs(air_transf_rate(k));
                if(to_index ~= -1)
                    %Transfer from from_index to to_index
                    heat_transf_matrix(to_index, from_index) = heat_transf_matrix(to_index, from_index)  + abs(air_transf_rate(k));
                end
            else
                if(to_index ~= -1)
                    %Heat transfer from the outside to to_index
                    base_heat_transf_vec(to_index) = base_heat_transf_vec(to_index) + abs(air_transf_rate(k)) * sysparams.ambientT;
                end
            end
            %End of positional loop
            
            %Does some summing to check that the actual divergence of each cell is actually zero(Air flow conserved)
            if(from_index ~= -1)
                total_divergence(from_index) = total_divergence(from_index) +abs(air_transf_rate(k));
            end
            if(to_index ~=-1)
                total_divergence(to_index) = total_divergence(to_index) -abs(air_transf_rate(k));
            end
        end
    end
    
end













































%%Old code, prob don't need. I think I know how to set this stuff up to the
%%point where it's easier to do it from scratch
if(0)
    
    for iX = 1:(system.params.array_width-1)
        for iY = 1:(system.params.array_height-1)
            
            %Calculates the base divergences, if pressure were zero everywhere
            box_index = sysparams.index_array(iY, iX);
            upper_neighbor_index = sysparams.index_array(iY+1, iX);
            if(and(box_index >0, upper_neighbor_index > 0))
                
                %The air transfer coefficient (air conductance) is the permeability times the area divided by the distance
                air_tranfer_coeff = system.upper_area(iY, iX)/sysparams.cell_width;
                %The buoyant force is equal to the change in temperature times the height of a cell
                upper_buoyant_force = (1./sysparams.graining)*( mean([guess_temp(iY, iX), guess_temp(iY+1, iX)]) - sysparams.ambientT);
                
                %If the pressure in each was the same, the transfer would be the buoyancy times the air transfer coefficient
                base_air_transf = air_tranfer_coeff * upper_buoyant_force;
                
                %The upper part gets negative divergence, the lower part gets positive divergence
                base_divergence(box_index) = base_divergence(box_index) + base_air_transf;
                base_divergence(upper_neighbor_index) = base_divergence(upper_neighbor_index) - base_air_transf;
            end
        end
    end
    
    
    for iX = 1:(sysparams.array_width-1)
        for iY = 1:(sysparams.array_height-1)
            %Calculates the pressure matrix, which will be put into a linear solver to find pressure everywhere
            
            box_index = sysparams.index_array(iY, iX);
            %Upper neighbor
            neighbor_index(1) = sysparams.index_array(iY +1, iX   );
            air_tranfer_coeff(1)=  harmmean([f.darcy(iY, iX)  f.darcy(iY+1, iX)])  * sysparams.upper_area(iY, iX)/sysparams.cell_width;
            
            %Right(outer) neighbor
            neighbor_index(2) = sysparams.index_array(iY   , iX +1);
            air_tranfer_coeff(2) =  harmmean([f.darcy(iY, iX)  f.darcy(iY, iX+1)]) * sysparams.right_area(iY, iX)/sysparams.cell_width;
            
            %iterates over upper and right neighbors
            for k = 1:2
                
                if(box_index ~= -1)
                    pressure_matrix(box_index, box_index) = pressure_matrix(box_index, box_index) + air_tranfer_coeff(k);
                    %Flow out of the current index in the direction of the neighbor index. More pressure means more diverengence
                end
                
                if(neighbor_index(k) ~=-1)
                    %Flow from the neighbor index in the direction of the current index
                    pressure_matrix(neighbor_index(k), neighbor_index(k)) = pressure_matrix(neighbor_index(k), neighbor_index(k)) + air_tranfer_coeff(k);%More pressure means more divergence
                end
                
                if((neighbor_index(k)~=-1) && (box_index ~=-1))
                    %Transfer between neighbor_index and current index
                    pressure_matrix(box_index, neighbor_index(k)) = pressure_matrix(box_index, neighbor_index(k))  - air_tranfer_coeff(k);
                    pressure_matrix(neighbor_index(k), box_index) = pressure_matrix(neighbor_index(k), box_index)  - air_tranfer_coeff(k);
                end
                
                
            end
            
            %End of positional loop
        end
    end
    
    
    
    pressure_vector = pressure_matrix \ -base_divergence;
    %Actually solves for it
    %The pressure must cancel out what the base divergence would be, s.t. the actual divergence is 0.
    
    
    base_heat_transf_vec = zeros(size(pressure_vector));
    heat_transf_matrix = sparse([], [], [], sysparams.array_size, sysparams.array_size);
    
    is_vert_help = [1 0]; %Just a little helper array to use for piecewise multiplication
    
    %Calculates the heat flow from each cell to each other cell. This gives us
    %the heat transfer matrix and the heat transfer vector for convection. This uses an upstreaming scheme, where the heat
    %transfer between two cells depends on the temperature of the cell that the air is leaving.
    
    %A check that the total divergence is zero. If it's not, then we have set up the linear problem incorrectly
    total_divergence = zeros(sysparams.array_size, 1);
    
    for iX = 1:(sysparams.array_width-1)
        for iY = 1:(sysparams.array_height-1)
            
            %Makes the convective heat transfer matrix
            box_index = sysparams.index_array(iY, iX);
            cur_temp = guess_temp(iY, iX);
            
            
            %Figure out the pressure in our cell
            if(box_index ==-1)
                cur_press = 0; %Pressure outside of the cluster is zero
            else
                cur_press = pressure_vector(box_index);
            end
            
            
            %Upper neighbor
            neighbor_index(1) = sysparams.index_array(iY +1, iX);
            air_tranfer_coeff(1)=  harmmean([f.darcy(iY, iX)  f.darcy(iY+1, iX)]) * sysparams.upper_area(iY, iX)/sysparams.cell_width;
            neighbor_temp(1) = guess_temp(iY+1, iX);
            
            %Right(outer) neighbor
            neighbor_index(2) = sysparams.index_array(iY   , iX +1);
            air_tranfer_coeff(2) =  harmmean([f.darcy(iY, iX)  f.darcy(iY, iX+1)]) * sysparams.right_area(iY, iX)/sysparams.cell_width;
            neighbor_temp(2) = guess_temp(iY, iX+1);
            
            %Calculate pressure in neighbor cells
            for k = 1:2
                if(neighbor_index(k) == -1)
                    neighbor_press(k) = 0;
                else
                    neighbor_press(k) = pressure_vector(neighbor_index(k));
                end
            end
            
            
            %Air transfer due to buoyancy and pressure differences
            air_transf_rate = air_tranfer_coeff .* ...
                ((cur_press - neighbor_press) + is_vert_help .* (.5/sysparams.graining) .*(neighbor_temp + cur_temp - 2*sysparams.ambientT));
            
            
            
            for k = 1:2
                
                if(air_transf_rate(k) >0)
                    from_index = box_index;
                    to_index = neighbor_index(k);
                    %Air going from cur to neighbor
                else
                    from_index = neighbor_index(k);
                    to_index = box_index;
                    %Vice versa
                end
                
                
                
                if(from_index ~= -1)
                    %Heat transferred away from from_index
                    heat_transf_matrix(from_index, from_index) = heat_transf_matrix(from_index, from_index) - abs(air_transf_rate(k));
                    if(to_index ~= -1)
                        %Transfer from from_index to to_index
                        heat_transf_matrix(to_index, from_index) = heat_transf_matrix(to_index, from_index)  + abs(air_transf_rate(k));
                    end
                else
                    if(to_index ~= -1)
                        %Heat transfer from the outside to to_index
                        base_heat_transf_vec(to_index) = base_heat_transf_vec(to_index) + abs(air_transf_rate(k)) * sysparams.ambientT;
                    end
                end
                %End of positional loop
                
                %Does some summing to check that the actual divergence of each cell is actually zero(Air flow conserved)
                if(from_index ~= -1)
                    total_divergence(from_index) = total_divergence(from_index) +abs(air_transf_rate(k));
                end
                if(to_index ~=-1)
                    total_divergence(to_index) = total_divergence(to_index) -abs(air_transf_rate(k));
                end
            end
        end
        
    end
    
    %Makes sure that divergence is very small
    if(max(abs(total_divergence))> .000001)
        fprintf('Max divergence is %f, aborting \n', max(abs(total_divergence(:))));
        abort;
    end
end