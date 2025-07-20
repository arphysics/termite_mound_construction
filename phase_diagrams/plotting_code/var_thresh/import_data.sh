#import the data manually

temp_home="aditya@10.243.53.250:/home3/aditya/TERMITES/new_2022_phase_diagrams/var_thresh/"

rsync -avze ssh $temp_home/var_thresh_gp4_pm_5000/param_and_cost.txt ./param_and_cost_gp4.txt 
rsync -avze ssh $temp_home/var_thresh_gp2_pm_5000/param_and_cost.txt ./param_and_cost_gp2.txt 
rsync -avze ssh $temp_home/var_thresh_gp6_pm_5000/param_and_cost.txt ./param_and_cost_gp6.txt 


echo "data pulled from var_gas_prod"