function [index_array, index_to_array_helper] = indexArrayAndHelper(logical_mask)

index_array = zeros(size(logical_mask));


%Fills up the index array and the index array helper
cur_index = 1;
for iX = 1:size(logical_mask, 2)
    for iY = 1:size(logical_mask, 1)
        if(logical_mask(iY, iX))
            index_to_array_helper(cur_index) = sub2ind(size(logical_mask), iY, iX);
            index_array(iY, iX) = cur_index;
            cur_index = cur_index +1;
        end
    end
end

index_to_array_helper = MakeHorizontal(index_to_array_helper)';

