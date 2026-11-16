function exportar_comparacion(ejecuciones, archivo)
% EXPORTAR_COMPARACION  Guarda varias ejecuciones lado a lado en CSV o JSON.
%   exportar_comparacion(ejecuciones, 'comparacion_rastrigin.csv')
%   exportar_comparacion(ejecuciones, 'comparacion_rastrigin.json')
%
%   ejecuciones : struct array con numero y resultado (como en pantalla_comparar)
%   CSV  : una fila por iteracion y una columna por ejecucion con su mejor valor acumulado
%          (ejecucion_06_pso, ...). Las que terminaron antes quedan vacias al final.
%   JSON : el problema y, por ejecucion, algoritmo, parametros, mejor solucion, valor,
%          iteraciones, motivo de termino, evaluaciones, tiempo e historial del mejor valor.

    [~, ~, extension] = fileparts(archivo);
    switch lower(extension)
        case '.csv'
            escribir_csv(ejecuciones, archivo);
        case '.json'
            escribir_json(ejecuciones, archivo);
        otherwise
            error('exportar_comparacion:formato', 'Formato no soportado: %s (usa .csv o .json).', extension);
    end
end

function escribir_csv(ejecuciones, archivo)
    historiales = arrayfun(@(e) e.resultado.historial.mejor_valor(:), ejecuciones, 'UniformOutput', false);
    n = max(cellfun(@numel, historiales));
    valores = NaN(n, numel(ejecuciones));
    for k = 1:numel(ejecuciones)
        valores(1:numel(historiales{k}), k) = historiales{k};
    end
    nombres = arrayfun(@(e) sprintf('ejecucion_%02d_%s', e.numero, lower(e.resultado.algoritmo)), ...
        ejecuciones, 'UniformOutput', false);
    tabla = array2table([(0:n - 1)', valores], 'VariableNames', [{'iteracion'}, nombres(:)']);
    writetable(tabla, archivo);
end

function escribir_json(ejecuciones, archivo)
    p = ejecuciones(1).resultado.problema;
    lista = cell(1, numel(ejecuciones));
    for k = 1:numel(ejecuciones)
        r = ejecuciones(k).resultado;
        lista{k} = struct( ...
            'numero', ejecuciones(k).numero, ...
            'algoritmo', r.algoritmo, ...
            'variante', r.variante, ...
            'parametros', r.params, ...
            'mejor_valor', r.mejor_valor, ...
            'mejor_solucion', r.mejor_solucion, ...
            'iteraciones', r.iteraciones, ...
            'motivo_termino', r.motivo_termino, ...
            'evaluaciones', r.evaluaciones, ...
            'tiempo_s', r.tiempo, ...
            'historial_mejor_valor', r.historial.mejor_valor);
    end
    resumen = struct( ...
        'problema', struct('nombre', p.nombre, 'representacion', p.representacion, ...
            'dim', p.dim, 'lb', p.lb, 'ub', p.ub, 'sentido', p.sentido, ...
            'f_optimo', p.f_optimo, 'x_optimo', p.x_optimo), ...
        'ejecuciones', {lista});

    id = fopen(archivo, 'w', 'n', 'UTF-8');
    if id < 0
        error('exportar_comparacion:archivo', 'No se pudo escribir en %s.', archivo);
    end
    cerrar = onCleanup(@() fclose(id));
    fwrite(id, jsonencode(resumen, 'PrettyPrint', true), 'char');
end
