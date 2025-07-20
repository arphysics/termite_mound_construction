
should_continue = true;
iter = 1;
tmp_norm_gas_conc_storer = [];
tmp_std_gas_conc_storer = [];
tmp_mound_radius = [];

fprintf('System detail...gas_prod: %f perm_mult: %f thresh: %f', system.params.gas_production, system.params.perm_mult, system.params.threshold);

while(should_continue)
    prev_interior = system.is_interior;
    
    complex_gradient_image = calculateComplexTemperatureImage(system);
    
    my_frame = 1;
    total_gas_conc_image = (zeros(size(system.is_below_ground)));
    
    bar = printState(system, strcat('Outputs/', system.params.output_path, '/SystemState/StateIter', num2str(iter), '.png'));

    for phase = system.params.phases
        fprintf('Doing phase %.2f, iter %d \n', phase, iter);
        
        cur_gradient_image = real(complex_gradient_image*exp(phase* j)/100.);
        fprintf("%f \n",  exp(phase* j))
        [air_vel_transfer_matrix, air_vel_mag_image] = termiteCalculateAirVel(system, cur_gradient_image);
        gas_diff_transfer_matrix = calculateGasDiffusionMatrix(system);
        
        %%prints out the air flow velocity field at a given timestep
        %imwriteWithPath(air_vel_mag_image * 2.5, strcat('Outputs/', system.params.output_path, '/Velocity/Iter', num2str(iter), '/VelFrame', num2str(my_frame), '.png'));
        
        gas_conc_image = termiteCalculateGasConcentrations(system,gas_diff_transfer_matrix, system.params.perm_mult * air_vel_transfer_matrix);
        
        %%prints out the system state with overlayed temperature, gas, and
        %%velocity
        %printStateWithTAndV(system, cur_gradient_image, air_vel_mag_image, gas_conc_image, strcat('Outputs/', system.params.output_path, '/VelocitywithStateIter', num2str(iter), '/VelFrame', num2str(my_frame), '.png'));
        
        total_gas_conc_image = total_gas_conc_image + gas_conc_image;
        %what does the addition of "total_gas_conc_image" on the RHS of
        %this equation do?
        
        
        %%let's now make a plot of the gas concentration and the mound as a
        %%function of time, with gas overlaid:
        %printStateWithConc(system, cur_gradient_image, air_vel_mag_image, total_gas_conc_image,strcat('Outputs/', system.params.output_path, '/Gas_Conc_Overlays/','/image', num2str(iter), '.png'));
        
        
        %calculate the normalized gas concentration:
        
%         total_gas_conc = sum(total_gas_conc_image, 'all'); %total gas in system 
%         norm_area = sum(system.is_interior, 'all');
%         norm_total_gas_conc = total_gas_conc/norm_area;
%         tmp_norm_gas_conc_storer = [tmp_norm_gas_conc_storer norm_total_gas_conc];
%         
%         %not sure if I should use the matlab function or my own...
%         tmp_norm_gas_conc_storer = [tmp_norm_gas_conc_storer mean(total_gas_conc_image(system.is_interior))];
%         
%         %for the std, I'll use the matlab function to be consistent
%         tmp_std_gas_conc_storer = [tmp_std_gas_conc_storer std(total_gas_conc_image(system.is_interior))];
        
        %dump the width of the mound
        
        
        my_frame = my_frame + 1;
        
    end


    %taking the average of the gas concentration 
    mean_gas_conc_image = total_gas_conc_image /(length(system.params.phases));

    %cost-function evaluations
     %not sure if I should use the matlab function or my own...
    tmp_norm_gas_conc_storer = [tmp_norm_gas_conc_storer mean(mean_gas_conc_image(system.is_interior))];
    
    %for the std, I'll use the matlab function to be consistent
    tmp_std_gas_conc_storer = [tmp_std_gas_conc_storer std(mean_gas_conc_image(system.is_interior))];

    %find and save the mound radius
    radius_storer = zeros(1,length(mean_gas_conc_image(:,1)))
    for ii = 1:length(mean_gas_conc_image(:,1))
        radius_storer(ii) = length(nonzeros(mean_gas_conc_image(ii,:)));
    end
    tmp_mound_radius = [tmp_mound_radius max(radius_storer)]
    
    %print the output
    printStateWithConc(system, cur_gradient_image, air_vel_mag_image, mean_gas_conc_image,strcat('Outputs/', system.params.output_path, '/Gas_Conc_Overlays/','/image', num2str(iter), '.png'));
    
    %system.params.threshold is the critical concentration
    system = updateTermiteInterior(system, mean_gas_conc_image, system.params.threshold, .01);
    
    
    system_mat_path = strcat('Outputs/', system.params.output_path, '/SystemMatStates/SystemState', num2str(iter), '.mat');
    MakeFilePath(system_mat_path);
    save(system_mat_path, 'system');
    
    
    iter = iter + 1;
    n_cells_moved = sum(prev_interior(:) ~= system.is_interior(:));
    should_continue = and(iter<= system.params.n_iters, n_cells_moved > 0);
    fprintf('%d Cells have changed \n', n_cells_moved);
   
    
    total_odor_in_dirt = sum(total_gas_conc_image(and(~system.is_interior, system.is_below_ground)))
    
    
    
end


%dump the steady state gas concentration
dlmwrite('param_and_cost.txt',[system.params.gas_production system.params.threshold system.params.perm_mult tmp_mound_radius tmp_norm_gas_conc_storer(end) tmp_std_gas_conc_storer(end) n_cells_moved],'-append');

%PUt the final state in 2 places for easy comparasion
bar = printState(system, strcat('Outputs/', system.params.output_path, '/FinalState.png'));

[output_path output_file file_type] = fileparts(system.params.output_path);
bar = printState(system, strcat('Outputs/', output_path, '/FinalState', output_file, '.png'));

