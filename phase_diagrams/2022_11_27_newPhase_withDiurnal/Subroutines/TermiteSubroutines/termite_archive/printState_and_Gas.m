function[image_to_print] =  printState_and_Gas(system, title_string)


    %make a plot of the gas concentration over time 
    %seems like this only works for a 1 phase case.
    %this is because it is not in the phases loop
    head_path = "/Users/adityaranganathan/Dropbox/Harvard_Research/repos/Termites_Draft/AR_Test_Mound_Code/GAS_conc_temp/"; 
    img_path = 'gac_conc_' + string(iter)+ "_.png";
    full_path = head_path + img_path;
    temp_gas_conc = flipud([fliplr(total_gas_conc_image) total_gas_conc_image]);
    imwrite(temp_gas_conc, full_path)
    
    total_odor_in_dirt = sum(total_gas_conc_image(and(~system.is_interior, system.is_below_ground)))



%Flip the image
image_to_print = flipud(image_to_print*0.0);
imwriteWithPath(image_to_print * 1./255., title_string);







