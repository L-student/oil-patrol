function [efficiency] = dirty_accumulator(grid, dirty_accumulator_1)

    % Contar células sujas restantes e acumular
    dirty_remaining = sum(grid(:) > 0);
    dirty_accumulator_1 = dirty_accumulator_1 + dirty_remaining;
    % Eficiência final será o valor acumulado das células sujas
    efficiency = dirty_accumulator_1;

end
