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
org_data = np.loadtxt('par_fixed_GP_v1.txt', delimiter = ',') #this is the output from the matlab code

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

eps = -2

tmp_cost = np.power(avg_gas_conc,(1-eps))*np.power(std_gas_conc, eps)

#tmp_cost_2 = np.power(avg_gas_conc,(-eps)*np.power(std_gas_conc, eps)


plt.figure(figsize = (10,10))
plt.plot(perm_mult, tmp_cost, '-o')
plt.xscale("log")
plt.savefig("PM_vs_cost.png")
