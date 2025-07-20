#load libraries
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
matplotlib.rcParams['text.usetex'] = False
from scipy import interpolate
import os
import seaborn as sns
sns.set()
sns.set_style("white")


#load data and assign data columns 
org_data = np.loadtxt('comb_pdata_varGP.txt', delimiter = ',') #this is the output from the matlab code

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
perm_mult_scaled = perm_mult*mound_radius

eps = -1

tmp_cost = np.power(avg_gas_conc,(1-eps))*np.power(std_gas_conc, eps)/concentration_threshold

#tmp_cost_2 = np.power(avg_gas_conc,(-eps)*np.power(std_gas_conc, eps)

#select and filter
perm_mult_unique = np.unique(perm_mult)
# print("Unique temperature values are: ", perm_mult_unique)
# gas_prod_unique = np.unique(gas_production)
# data_store = np.zeros(len(perm_mult_unique), len(gas_prod_unique))


#plotting
plt.figure(figsize = (10,10))
for value in perm_mult_unique:
	if value == 5000 or value==10000 or value==50000:
		print(value)
		xselector = tuple([perm_mult == value])
		xdata = gas_production_scaled[xselector]
		#xdata = perm_mult_scaled
		#xdata = gas_production[xselector]
		ydata = tmp_cost[xselector]

		#find the minimum value
		tmp_min_arg = np.argmin(ydata)


		label = "         = " + str(np.round(value, 2))
		plt.plot(xdata, ydata, 'o--', label = label)
		#plt.plot(gas_production_scaled, tmp_cost, '.')
		plt.plot(xdata[tmp_min_arg], ydata[tmp_min_arg], 'kD', markersize = 8)

title = "Plot of Cost Function vs Scaled Gas Production for eps=" +str(eps)
# plt.title(title, fontsize = 30)
# plt.xlabel("Scaled Gas Production", fontsize = 25) #\frac{JR^2}{D_0}", fontsize = 20)
# plt.ylabel("Cost Function", fontsize = 25)
plt.legend(fontsize = 20)
plt.xscale("log")
plt.xticks(fontsize=20)
plt.yticks(fontsize=20)
plt.savefig("gasProd_vs_cost_comb.png")







# plt.figure(figsize = (10,10))
# #plt.plot(gas_production, tmp_cost)
# plt.plot(gas_production_scaled, tmp_cost, '.')
# plt.xlabel("Gas Production Scaled JR^2/D0")
# plt.ylabel("Cost Function")
# plt.xscale("log")
# plt.savefig("gasProd_vs_cost_pm10k.png")

plt.figure(figsize = (10,10))
#plt.plot(gas_production, tmp_cost)
plt.plot(gas_production, mound_radius**2)
#plt.xscale("log")
plt.savefig("gas_vs_moundArea.png")



