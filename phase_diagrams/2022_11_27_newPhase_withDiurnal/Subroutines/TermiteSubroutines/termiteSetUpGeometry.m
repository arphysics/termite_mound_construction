%This subroutine(Not quite a subroutine), takes a sysparams object, makes an index array, and also makes a bunch of helper objets
%to deal with the heat transfer and indexing. It's called somewhat redundantly, in that when it's called during iterativeSolver,
%only a fraction of what it does is required, but it's not worth the added complexity to change.


%% 


%%



radius = sysparams.height/2;

[x_mesh, y_mesh] = meshgrid(x_values, y_values);
sysparams.index_array =  - ((x_mesh.^2 + y_mesh.^2) >= (radius).^2);

sysparams.cyl_radius = x_mesh;

%Fills up the index array and the index array helper
cur_index = 1;
for iX = 1:size(sysparams.index_array, 2)
    for iY = 1:size(sysparams.index_array, 1)
        if(sysparams.index_array(iY, iX)~=-1)
            sysparams.index_to_array_helper(cur_index) = sub2ind(size(sysparams.index_array), iY, iX);
            sysparams.index_array(iY, iX) = cur_index;
            cur_index = cur_index +1;
        end
    end
end

sysparams.index_to_array_helper = MakeHorizontal(sysparams.index_to_array_helper)';
%Just does a bit of a fix on the size

sysparams.interior = sysparams.index_array > -1;
sysparams.exterior = sysparams.index_array == -1;



%Just to possibly cause us less headaches later on
sysparams.kphi = 0;

sysparams.array_size = sum(sysparams.index_array(:) > -1);
