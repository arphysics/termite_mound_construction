#import the data manually

temp_home="aditya@10.243.53.250:/home3/aditya/TERMITES/new_2022_phase_diagrams/var_gas_prod/"

rsync -avze ssh $temp_home/perm_mult_10000/param_and_cost.txt ./param_and_cost_pm_10k.txt 
rsync -avze ssh $temp_home/perm_mult_5000/param_and_cost.txt ./param_and_cost_pm_5k.txt 
rsync -avze ssh $temp_home/perm_mult_50000/param_and_cost.txt ./param_and_cost_pm_50k.txt 
rsync -avze ssh $temp_home/perm_mult_500k/param_and_cost.txt ./param_and_cost_pm_500k.txt 

echo "data pulled from var_gas_prod"