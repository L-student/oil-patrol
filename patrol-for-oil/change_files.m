function [ ] = change_files(output_name_txt, output_name_nc)

delete(output_name_txt); % Exclui o arquivo
delete(output_name_nc); % Exclui o arquivo

% Caminho doH arquivo a ser copiado
file_initial_txt = 'step_initial.txt';
file_initial_nc = 'step_16_9.nc';
file_modified_txt = 'step.txt';
file_modified_nc = 'step.nc';
copyfile(file_initial_txt, file_modified_txt); % Copia o arquivo
copyfile(file_initial_nc, file_modified_nc); % Copia o arquivo

end