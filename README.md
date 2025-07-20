# termite_mound_construction


## Origins
This code in this repository is in support the work in the paper "Optimally Adapted Morphologies of Termite Mounds" by Aditya Ranganathan, Alexander Heyde, and L. Mahadevan. 

The code here was originally developed by Samuel Ocko and used in the papers: 

* S. A. Ocko, A. Heyde, and L. Mahadevan,“Morphogenesis of termite mounds”, Proceedings of the National Academy of Sciences 116, 3379–3384 (2019)
* S. A. Ocko, H. King, D. Andreen, P. Bardunias, J. S. Turner, R. Soar, and L. Mahadevan, “Solar-powered ventilation of African termite mounds”, Journal of ExperimentalBiology 220, 3260–3269 (2017).

The changes made to prior code was primarily in pursuit of the following aims: to allow for the gathering of cost function data and for effective sampling across a multi-parameter range. 

All work  done to modify, adapt, and expand the codebase of Samuel Ocko for this paper was done by Aditya Ranganathan. 

## How the code works

The folder [2022_11_27_newPhase_withDiurnal/](phase_diagrams/2022_11_27_newPhase_withDiurnal/) contains the main Matlab code for this project. The primary simulation file is [`TermiteMoundSimulation.m`](phase_diagrams/2022_11_27_newPhase_withDiurnal/TermiteMoundSimulation.m), which controls the parameter settings and simulation process.

`TermiteMoundSimulation.m` is the primary file in which parameters are set and which loops through the various parameters used to generate Fig 3. in the paper. 

To see an example of sample outputs, see the folder [Sample_Outputs_Deprecated/](phase_diagrams/2022_11_27_newPhase_withDiurnal/Sample_Outputs_Deprecated/) which contains sample outputs from two gas concentration values. 

The code then saves data that the plotting code can use to generate plots. 

Because we do 2D slices when sampling the code, data is always in the form of two free parameters and one fixed parameter (amongst the gas production rate, the odor concentration threshold, and and the permeability). To see what this looks like, see [plotting_code/var_gas_prod_/comb_pdata_varGP.txt](phase_diagrams/plotting_code/var_gas_prod/comb_pdata_varGP.txt). This file contains the relevant information from a run of simulations in which the permeability and gas production were varied while the odor threshold was fixed. This file was produced by combining the various [param_and_cost*](phase_diagrams/plotting_code/params_and_cost.txt) files that are produced by the `TermiteMoundSimulation.m` code. Each [param_and_cost*](phase_diagrams/plotting_code/params_and_cost.txt) file corresponds to a particular permeability. Storing data separately and combining them before plotting allows for multithreading and makes the process of running phase diagram simulations more efficient.

Plotting can be done in each of the [var_*](phase_diagrams/plotting_code/) folders in the plotting code parent folder by running the appropriate Python plotting code, e.g., [plot *_tmp.py](phase_diagrams/plotting_code/var_gas_prod/plot_gas_tmp.py) in each folder. This produces outputs that look like [PermMult_vs_cost_comb.png](phase_diagrams/plotting_code/var_perm_mult/PermMult_vs_cost_comb.png). This plot is used in Fig. 3. 


## How to replicate the results in the paper

Run TermiteMoundSimulation.m to produce the data. This can take a while. I used the the following command on a workstation, which should obviously be edited as needed:

`nohup matlab -nojvm -nodisplay < TermiteMoundSimulation.m > output.txt &`

To create plots, use the plotting methods described in the previous section. 







