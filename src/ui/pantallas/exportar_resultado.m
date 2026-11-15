function exportar_resultado(resultado, archivo)
% EXPORTAR_RESULTADO  Guarda una ejecucion en CSV o JSON (segun la extension de archivo).
%   exportar_resultado(resultado, 'ejecucion_06.csv')
%   exportar_resultado(resultado, 'ejecucion_06.json')
%
%   CSV  : una fila por iteracion con el mejor valor acumulado y la mejor solucion
%          (columnas iteracion, mejor_valor, x1 ... xn). Se abre directo en Excel o con readtable.
%   JSON : el resumen de la ejecucion (algoritmo, problema, parametros, mejor solucion,
%          motivo de termino, evaluaciones, tiempo) y el mismo historial del CSV.
%          La poblacion de cada iteracion no se guarda: con poblaciones grandes pesa cientos de MB.

    [~, ~, extension] = fileparts(archivo);
    switch lower(extension)
        case '.csv'
            escribir_csv(resultado, archivo);
        case '.json'
            escribir_json(resultado, archivo);
        otherwise
            error('exportar_resultado:formato', 'Formato no soportado: %s (usa .csv o .json).', extension);
    end
end

function escribir_csv(resultado, archivo)
    hist = resultado.historial;
    n = numel(hist.mejor_valor);
    tabla = array2table([(0:n - 1)', hist.mejor_valor(:), hist.mejor_solucion], ...
        'VariableNames', [{'iteracion', 'mejor_valor'}, ...
                          compose('x%d', 1:size(hist.mejor_solucion, 2))]);
    writetable(tabla, archivo);
end

function escribir_json(resultado, archivo)
    p = resultado.problema;
    resumen = struct( ...
        'algoritmo', resultado.algoritmo, ...
        'variante', resultado.variante, ...
        'problema', struct('nombre', p.nombre, 'representacion', p.representacion, ...
            'dim', p.dim, 'lb', p.lb, 'ub', p.ub, 'sentido', p.sentido, ...
            'f_optimo', p.f_optimo, 'x_optimo', p.x_optimo), ...
        'parametros', resultado.params, ...
        'mejor_valor', resultado.mejor_valor, ...
        'mejor_solucion', resultado.mejor_solucion, ...
        'iteraciones', resultado.iteraciones, ...
        'motivo_termino', resultado.motivo_termino, ...
        'evaluaciones', resultado.evaluaciones, ...
        'tiempo_s', resultado.tiempo, ...
        'historial', struct('mejor_valor', resultado.historial.mejor_valor, ...
                            'mejor_solucion', resultado.historial.mejor_solucion));

    id = fopen(archivo, 'w', 'n', 'UTF-8');
    if id < 0
        error('exportar_resultado:archivo', 'No se pudo escribir en %s.', archivo);
    end
    cerrar = onCleanup(@() fclose(id));
    fwrite(id, jsonencode(resumen, 'PrettyPrint', true), 'char');
end
