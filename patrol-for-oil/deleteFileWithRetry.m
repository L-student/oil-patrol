function deleteFileWithRetry(filename)
    maxAttempts = 5;
    attempt = 0;
    while exist(filename, 'file') && attempt < maxAttempts
        try
            delete(filename);
        catch
            pause(0.2); % Aguarda um tempo antes de tentar de novo
        end
        attempt = attempt + 1;
    end
    if exist(filename, 'file')
        error(['Não foi possível deletar o arquivo: ', filename]);
    end
end