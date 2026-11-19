function resultado = aco(problema, params, al_cada_iteracion)
% ACO  Ejecuta Ant System elitista en problemas binarios o de permutacion.
%   resultado = aco(problema, params, al_cada_iteracion)

    if nargin < 3, al_cada_iteracion = []; end
    if ~ismember(problema.representacion, {'binario', 'permutacion'})
        error('aco:representacion', 'ACO no soporta la representacion "%s".', ...
            problema.representacion);
    end

    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);
    es_binario = strcmp(problema.representacion, 'binario');
    [feromona, poblacion, heuristica] = inicializar_aco(problema, params);

    costos = evaluar_individuos(poblacion, costo);
    evaluaciones = size(poblacion, 1);
    [mejor_costo, indice] = min(costos);
    mejor_solucion = poblacion(indice, :);
    historial = inicializar_historial_aco(params.n_iteraciones, problema.dim);
    motivo = 'max_iteraciones';
    sin_mejora = 0;

    for iteracion = 0:params.n_iteraciones
        if iteracion > 0
            poblacion = construir_poblacion_aco(feromona, heuristica, problema, params);
            costos = evaluar_individuos(poblacion, costo);
            evaluaciones = evaluaciones + size(poblacion, 1);
            [mejor_costo, mejor_solucion, sin_mejora] = actualizar_mejor_aco( ...
                costos, poblacion, mejor_costo, mejor_solucion, sin_mejora);
            feromona = actualizar_feromona_aco(feromona, mejor_solucion, params, es_binario);
        end

        solucion_actual = mejor_solucion;
        historial = guardar_estado_aco(historial, iteracion, signo * mejor_costo, ...
            solucion_actual, poblacion);
        if ~isempty(al_cada_iteracion)
            estado = struct('iteracion', iteracion, 'n_iteraciones', params.n_iteraciones, ...
                'mejor_valor', signo * mejor_costo, 'mejor_solucion', solucion_actual, ...
                'poblacion', poblacion, 'evaluaciones', evaluaciones);
            if al_cada_iteracion(estado), motivo = 'detenido'; break; end
        end
        if params.paciencia > 0 && sin_mejora >= params.paciencia
            motivo = 'convergencia';
            break;
        end
    end

    info = info_aco();
    resultado = struct('algoritmo', 'ACO', 'variante', info.variante, ...
        'problema', problema, 'params', params, 'sentido', problema.sentido, ...
        'mejor_solucion', mejor_solucion, 'mejor_valor', signo * mejor_costo, ...
        'iteraciones', iteracion, 'motivo_termino', motivo, ...
        'evaluaciones', evaluaciones, 'tiempo', toc(t_inicio));
    resultado.historial.mejor_valor = historial.mejor_valor(1:iteracion + 1);
    resultado.historial.mejor_solucion = historial.mejor_solucion(1:iteracion + 1, :);
    resultado.historial.poblacion = historial.poblacion(1:iteracion + 1);
end

function historial = inicializar_historial_aco(n_iteraciones, dim)
% INICIALIZAR_HISTORIAL_ACO  Reserva las salidas de cada iteracion.
    historial.mejor_valor = zeros(n_iteraciones + 1, 1);
    historial.mejor_solucion = zeros(n_iteraciones + 1, dim);
    historial.poblacion = cell(n_iteraciones + 1, 1);
end

function historial = guardar_estado_aco(historial, iteracion, mejor_costo, mejor_solucion, poblacion)
% GUARDAR_ESTADO_ACO  Guarda el mejor acumulado y la poblacion actual.
    historial.mejor_valor(iteracion + 1) = mejor_costo;
    historial.mejor_solucion(iteracion + 1, :) = mejor_solucion;
    historial.poblacion{iteracion + 1} = poblacion;
end

function [mejor_costo, mejor_solucion, sin_mejora] = actualizar_mejor_aco( ...
        costos, poblacion, mejor_costo, mejor_solucion, sin_mejora)
% ACTUALIZAR_MEJOR_ACO  Actualiza el mejor global y el contador de paciencia.
    [costo_iteracion, indice] = min(costos);
    if costo_iteracion < mejor_costo
        mejor_costo = costo_iteracion;
        mejor_solucion = poblacion(indice, :);
        sin_mejora = 0;
    else
        sin_mejora = sin_mejora + 1;
    end
end
