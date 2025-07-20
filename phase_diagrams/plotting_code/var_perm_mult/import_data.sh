#import the data manually

temp_home="aditya@10.243.53.250:/home3/aditya/TERMITES/new_2022_phase_diagrams/var_perm_mult/"

rsync -avze ssh $temp_home/running/gas_prod_0.5/params_and_cost.txt ./param_and_cost_gp_0-5.txt 
rsync -avze ssh $temp_home/running/gas_prod_2/params_and_cost.txt ./param_and_cost_gp_2.txt 
rsync -avze ssh $temp_home/running/gas_prod_4/params_and_cost.txt ./param_and_cost_gp_4.txt 
rsync -avze ssh $temp_home/running/gas_prod_8/params_and_cost.txt ./param_and_cost_gp_8.txt 
#rsync -avze ssh $temp_home/completed/gas_prod_6/param_and_cost.txt ./param_and_cost_gp_6.txt 

#cat param_and_cost*.txt > comb_param_and_cost.txt


echo "data pulled from var_gas_prod"