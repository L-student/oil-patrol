% Função auxiliar para tentar repetidamente copiar um arquivo
function copyFileWithRetry(source, destination)
    maxAttempts = 5;
    attempt = 0;
    while ~exist(destination, 'file') && attempt < maxAttempts
        try
            copyfile(source, destination);
        catch
            pause(0.2); % Aguarda um tempo antes de tentar de novo
        end
        attempt = attempt + 1;
    end
    if ~exist(destination, 'file')
        error(['Não foi possível copiar o arquivo: ', destination]);
    end
end