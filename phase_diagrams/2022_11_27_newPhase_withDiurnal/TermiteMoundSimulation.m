close all
clear all
addAllPaths

tic

%gas production lists the rate at which gas is produced
for gas_production = fliplr([0.1:0.2:1 1:1:10])
%for gas_production = 6; %fliplr([0.1, 1, 10, 100]) %[0.1, 10, 100, 1000]


    
    %perm_mult is a proxy for the diurnal temperature variation??
    %for perm_mult  = [0.0001:0.04:0.001 0.001:0.004:0.01 0.01:0.04:0.1 0.1:0.4:1 1:2:10 10:40:100 100:400:1000 1000:4000:10000 10000:]
    for perm_mult = [0.01 0.1 1 10 100 1000 4000 6000 8000 10000 10000:10000:100000 10.^6], %[1000, 10000]
         
        %for threshold = [0.01:0.01:0.1 0.1:0.1:0.5]
        for threshold = [0.05]
        
            MakeSysParams
            system.params.gas_production = gas_production;
            %system.params.n_iters = 100; %We really want it to reach a final state
            system.params.n_iters = 100; %200; %for testing purposes (not steady state)
            system.params.phases = 2 * pi * [0 .25 .5 .75];
            %system.params.phases = 2 * pi * [0.5];
            system.params.perm_mult = perm_mult;
            system.params.graining = 10; %10;
            system.params.threshold = threshold;
            %system.params.output_path = strcat('GroundHackedRuns22/GasProduction', num2str(gas_production),'/My2OutputPermMult', perm_mult);
            system.params.output_path = strcat('GasProduction', num2str(gas_production),'/My2OutputPermMult', num2str(perm_mult),'/My2OutputThresh', num2str(threshold));

            %playing and trying to understand what is going on with
            %neighbor area
            system.params.width = 10;
            system.params.height = 30;

            FillInSysParamsHelpers
            InitializeSystemStateFromParams
            RunSysParams
        end
    end
    
    
end

toc 
