#load libraries
import numpy as np
import matplotlib.pyplot as plt
import matplotlib
matplotlib.rcParams['text.usetex'] = False
from scipy import interpolate
import os
import seaborn as sns
sns.set()
sns.set_style("white")


#load data and assign data columns 
org_data = np.loadtxt('comb_param_and_cost_thresh.txt', delimiter = ',') #this is the output from the matlab code

#remove nans
data_1 = org_data[~np.isnan(org_data).any(axis=1)]

#only select cases in which steady state has been achieved
data = data_1[data_1[:,6] ==0,:]

gas_production = data [:,0]
concentration_threshold = data[:,1]
perm_mult = data[:,2]
mound_radius = data[:,3]
avg_gas_conc = data[:,4]
std_gas_conc = data[:,5]
cells_changed = data[:,6]

#define the scaled variables (scaled production, perm_mult, and phi-critical)
gas_production_scaled = gas_production*(mound_radius**2)

eps = -1

tmp_cost = np.power(avg_gas_conc,(1-eps))*np.power(std_gas_conc, eps)/concentration_threshold

#tmp_cost_2 = np.power(avg_gas_conc,(-eps)*np.power(std_gas_conc, eps)

#select and filter
perm_mult_unique = np.unique(perm_mult)
print(perm_mult_unique)
gas_prod_unique = np.unique(gas_production)
print("Unique Gas Production Values: ", gas_prod_unique)
# print("Unique temperature values are: ", perm_mult_unique)
# gas_prod_unique = np.unique(gas_production)
# data_store = np.zeros(len(perm_mult_unique), len(gas_prod_unique))


#plotting
plt.figure(figsize = (10,10))
for value in gas_prod_unique:
	xselector = tuple([gas_production == value])
	xdata = concentration_threshold[xselector]
	ydata = tmp_cost[xselector]

	#find the minimum value
	tmp_min_arg = np.argmin(ydata)


	label = "J = " + str(np.round(value, 2))
	plt.plot(xdata, ydata, 'o--', label = label)
	#plt.plot(gas_production_scaled, tmp_cost, '.')
	plt.plot(xdata[tmp_min_arg], ydata[tmp_min_arg], 'kD', markersize = 8)

title = "Plot of Cost Function vs Threshold for eps=" +str(eps)
# plt.title(title)
# plt.xlabel("Concentration Threshold", fontsize = 25) #("Concentration Threshold phi_c")
# plt.ylabel("Cost Function")
plt.legend(fontsize = 20)
plt.xscale("log")
plt.xticks(fontsize=20)
plt.yticks(fontsize=20)
plt.savefig("thresh_cost_comb.png")

