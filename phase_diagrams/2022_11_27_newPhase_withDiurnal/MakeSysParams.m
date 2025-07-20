%% Various Parameters

system.params.dont_model_underground = 1;

system.params.gas_production = 1; %odor production!!
system.params.graining = 13;
system.params.n_iters = 100;

system.params.width = 10;
system.params.height = 30;
system.params.wall_thickness = .3;


system.params.maxDepth = 10; %The max depth. Determines how much of the simulation is above-ground or below-ground.
system.params.thermDiffus = .05;
system.params.gasDiffus = 1; %gas diffusion!

system.params.perm_mult = 5000; %permeability (kappa-nought)


system.params.source_X = 0;
system.params.source_Y = 0;
system.params.init_radius = 1;

%what happens if I try to add a set of system params:

system.params.threshold = .1;



system.params.output_path = 'MyOutput'

system.params.phases  = 2 * pi * (0:.1:(1 - 10^-5))

%system.params.phases  = 2 * pi * (0:.05:(1 - 10^-5))

%extra system params:

system.params.mound_collapse = 0;








