function[] = imwriteWithPath(image, image_path_string)


MakeFilePath(image_path_string)
imwrite([fliplr(image) image], image_path_string)

%foo = fileparts(file_path_string);
%fprintf('Making file path for %s \n', foo);