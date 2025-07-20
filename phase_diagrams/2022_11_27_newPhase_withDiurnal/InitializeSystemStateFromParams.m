
%%

fprintf('Initialized system params! \n');
system.is_interior = initTermiteInterior(system);
if(0)
    %Sets no interior for testing purposes
    system.is_interior = boolean(zeros(size(system.is_interior)));
end
fprintf('initialized system interior! \n');

system.is_wall = calculateWallPositions(system);
fprintf('initialized system wall! \n');


bar = printState(system, 'SystemState.png');





