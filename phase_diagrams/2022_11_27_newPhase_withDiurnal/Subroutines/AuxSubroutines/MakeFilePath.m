function[] = MakeFilePath(file_path_string)

if ~strcmp(file_path_string, 'SystemState.png');
	% [pathstr,name,ext] = fileparts(file_path_string);
	system(['mkdir -p ' fileparts(file_path_string)]);
end

%system(sprintf('mkdir -p %s', fileparts(file_path_string)));

%[pathstr,name,ext] = fileparts(file_path_string);
%system(strcat('mkdir -p ', pathstr, name, ext));

%foo = fileparts(file_path_string);
%fprintf('Making file path for %s \n', foo);