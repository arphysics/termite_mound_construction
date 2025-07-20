function [gas_conc_image] = termiteCalculateGasConcentrations(system, cond_transfer_matrix, conv_transfer_matrix)



%Calculates the right and left components of the linear equation due to convection at the current temperature and density
not_in_air = or(or(system.is_interior, system.is_wall), system.is_below_ground);

n_not_air_indices = sum(not_in_air(:));
[not_in_air_indices, not_in_air_index_helper] = indexArrayAndHelper(not_in_air);

target_gas_vector = zeros(n_not_air_indices, 1);
target_gas_vector(not_in_air_indices(system.params.source_iY, system.params.source_iX)) = system.params.gas_production;


total_transfer_matrix = cond_transfer_matrix + conv_transfer_matrix;
gas_conc_vec = total_transfer_matrix \ -target_gas_vector;


gas_conc_image = zeros(size(not_in_air));
gas_conc_image(not_in_air_index_helper) = gas_conc_vec;
