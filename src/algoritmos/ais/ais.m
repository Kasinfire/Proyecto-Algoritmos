function resultado = ais(problema, params, al_cada_iteracion)
% AIS  Ejecuta CLONALG con hipermutacion para las tres representaciones.
%   resultado = ais(problema, params, al_cada_iteracion)

    if nargin < 3, al_cada_iteracion = []; end
    if ~ismember(problema.representacion, {'continuo', 'binario', 'permutacion'})
        error('ais:representacion', 'AIS no soporta la representacion "%s".', ...
            problema.representacion);
    end
    if params.n_seleccionados > params.n_anticuerpos
        error('ais:n_seleccionados', 'n_seleccionados no puede superar n_anticuerpos.');
    end
    if params.n_reemplazo > params.n_anticuerpos
        error('ais:n_reemplazo', 'n_reemplazo no puede superar n_anticuerpos.');
    end

    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);
    [lb, ub] = espacio_busqueda(problema);
    poblacion = inicializar_anticuerpos_ais(params.n_anticuerpos, problema, lb, ub);
    costos = evaluar_individuos(poblacion, costo);
    evaluaciones = size(poblacion, 1);
    [mejor_costo, indice] = min(costos);
    mejor_solucion = poblacion(indice, :);
    historial = inicializar_historial_ais(params.n_iteraciones, problema.dim);
    motivo = 'max_iteraciones';
    sin_mejora = 0;

    for iteracion = 0:params.n_iteraciones
        if iteracion > 0
            [poblacion, costos, evaluaciones_iteracion] = evolucionar_anticuerpos_ais( ...
                poblacion, costos, problema, params, lb, ub, costo);
            evaluaciones = evaluaciones + evaluaciones_iteracion;
            [mejor_costo, mejor_solucion, sin_mejora] = actualizar_mejor_ais( ...
                costos, poblacion, mejor_costo, mejor_solucion, sin_mejora);
        end

        historial = guardar_estado_ais(historial, iteracion, signo * mejor_costo, ...
            mejor_solucion, poblacion);
        if ~isempty(al_cada_iteracion)
            estado = struct('iteracion', iteracion, 'n_iteraciones', params.n_iteraciones, ...
                'mejor_valor', signo * mejor_costo, 'mejor_solucion', mejor_solucion, ...
                'poblacion', poblacion, 'evaluaciones', evaluaciones);
            if al_cada_iteracion(estado), motivo = 'detenido'; break; end
        end
        if params.paciencia > 0 && sin_mejora >= params.paciencia
            motivo = 'convergencia';
            break;
        end
    end

    info = info_ais();
    resultado = struct('algoritmo', 'AIS', 'variante', info.variante, ...
        'problema', problema, 'params', params, 'sentido', problema.sentido, ...
        'mejor_solucion', mejor_solucion, 'mejor_valor', signo * mejor_costo, ...
        'iteraciones', iteracion, 'motivo_termino', motivo, ...
        'evaluaciones', evaluaciones, 'tiempo', toc(t_inicio));
    resultado.historial.mejor_valor = historial.mejor_valor(1:iteracion + 1);
    resultado.historial.mejor_solucion = historial.mejor_solucion(1:iteracion + 1, :);
    resultado.historial.poblacion = historial.poblacion(1:iteracion + 1);
end

function historial = inicializar_historial_ais(n_iteraciones, dim)
% INICIALIZAR_HISTORIAL_AIS  Reserva el historial del algoritmo.
    historial.mejor_valor = zeros(n_iteraciones + 1, 1);
    historial.mejor_solucion = zeros(n_iteraciones + 1, dim);
    historial.poblacion = cell(n_iteraciones + 1, 1);
end

function historial = guardar_estado_ais(historial, iteracion, mejor_valor, mejor_solucion, poblacion)
% GUARDAR_ESTADO_AIS  Guarda el mejor valor acumulado y la poblacion.
    historial.mejor_valor(iteracion + 1) = mejor_valor;
    historial.mejor_solucion(iteracion + 1, :) = mejor_solucion;
    historial.poblacion{iteracion + 1} = poblacion;
end

function [mejor_costo, mejor_solucion, sin_mejora] = actualizar_mejor_ais( ...
        costos, poblacion, mejor_costo, mejor_solucion, sin_mejora)
% ACTUALIZAR_MEJOR_AIS  Actualiza el mejor global y la paciencia.
    [costo_iteracion, indice] = min(costos);
    if costo_iteracion < mejor_costo
        mejor_costo = costo_iteracion;
        mejor_solucion = poblacion(indice, :);
        sin_mejora = 0;
    else
        sin_mejora = sin_mejora + 1;
    end
end
