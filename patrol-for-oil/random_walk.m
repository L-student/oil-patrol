function [robots, heading] = random_walk(grid, robots, heading, mask)

% Caminhar de maneira aleatória 
% Random 0 a 7, depois verifica se o passo é válido, caso seja esse é o
% passo que o robô dará, caso não seja, roda de novo e escolhe o próximo,
% caso vá até 7 ele fica parado e vai para o próximo robô
% É o baseline, pior caso
% Integral + quantidade de loops
% Colocar para rodar x vezes e analisa o quanto falta para finalizar
        n_robots = size(robots, 1);  % Número de robôs
    aux_mask = mask;

    for robot = 1:n_robots
        neighbors = robots(setdiff(1:end, robot), :);
        disp(robot)
        
        max_attempts = 8;  % Número máximo de tentativas para encontrar um movimento válido
        attempt = 0;
        valid_move = false;

        while attempt < max_attempts && ~valid_move
            % Movimentação aleatória
            move = randi([-1, 1], 1, 2);  % Gera movimento aleatório [-1, 0, 1] para x e y

            % Calcula nova posição
            new_position = robots(robot, :) + move;

            % Verifica se a nova posição está dentro dos limites do grid e não é obstáculo
            if new_position(1) > 0 && new_position(1) <= size(grid, 2) && ...
               new_position(2) > 0 && new_position(2) <= size(grid, 1) && ...
               mask(new_position(2), new_position(1)) == 0  % Verifica se não é um obstáculo

                % Movimento válido, atualiza a posição do robô
                robots(robot, :) = new_position;
                heading(robot) = atan2(move(2), move(1));
                valid_move = true;  % Movimento válido encontrado
            else
                attempt = attempt + 1;  % Incrementa tentativas se o movimento for inválido
            end
        end

        % Se todas as tentativas falharem, o robô permanece parado
        if ~valid_move
            disp(['Robo ', num2str(robot), ' permaneceu parado após ', num2str(max_attempts), ' tentativas inválidas.']);
        end
    end
end
