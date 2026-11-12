function est = calcular_estadisticas(ejecuciones, problema, config)
%CALCULAR_ESTADISTICAS  Resume varias ejecuciones del PSO en métricas.
%
%   est = CALCULAR_ESTADISTICAS(ejecuciones, problema, config)
%
%   Entradas:
%       ejecuciones - Arreglo de resultados de pso().
%       problema     - Problema evaluado (para conocer sentido y óptimo).
%       config      - Configuración (usa la tolerancia de convergencia).
%
%   Salida (estructura):
%       mejor_valor       - Mejor resultado entre todas las repeticiones.
%       mejor_posicion    - Posición donde se obtuvo ese mejor resultado.
%       promedio         - Promedio del valor final.
%       desv_estandar     - Desviación estándar del valor final.
%       error_promedio    - Promedio de |valor final - óptimo conocido|.
%       tasa_exito        - % de repeticiones que llegaron al óptimo
%                          (error <= tolerancia).
%       iter_convergencia - Iteración promedio en que se alcanzó la
%                          tolerancia (solo repeticiones exitosas; NaN si
%                          ninguna lo logró).
%       curva_promedio    - Curva media del mejor valor por iteración.

    valores    = [ejecuciones.mejor_valor]';
    % (n_iter+1) x n_rep: una columna por repeticion
    historiales = cell2mat(arrayfun(@(e) e.historial.mejor_valor, ejecuciones, ...
                                    'UniformOutput', false));

    % Mejor resultado según el sentido del problema
    if strcmp(problema.sentido, 'max')
        [est.mejor_valor, idx] = max(valores);
    else
        [est.mejor_valor, idx] = min(valores);
    end
    est.mejor_posicion = ejecuciones(idx).mejor_solucion;

    est.promedio      = mean(valores);
    est.desv_estandar  = std(valores);
    est.error_promedio = mean(abs(valores - problema.f_optimo));

    % Iteración en la que cada repetición alcanzó la tolerancia
    n_rep = numel(ejecuciones);
    iter_alcanzada = nan(n_rep, 1);
    for r = 1:n_rep
        error_curva = abs(historiales(:, r) - problema.f_optimo);
        primera = find(error_curva <= config.tolerancia, 1, 'first');
        if ~isempty(primera)
            iter_alcanzada(r) = primera - 1;   % la posición 1 es la iteración 0
        end
    end

    exitosas = ~isnan(iter_alcanzada);
    est.tasa_exito = 100 * mean(exitosas);
    if any(exitosas)
        est.iter_convergencia = mean(iter_alcanzada(exitosas));
    else
        est.iter_convergencia = NaN;
    end

    est.curva_promedio = mean(historiales, 2);
end
