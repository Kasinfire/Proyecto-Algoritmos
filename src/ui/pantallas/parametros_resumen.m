function lista = parametros_resumen(id, representacion, params)
% PARAMETROS_RESUMEN  Parametros usados en una ejecucion, listos para mostrarse.
%   lista = parametros_resumen('pso', 'continuo', resultado.params)
%
%   lista : struct array con
%       nombre   : campo de params
%       etiqueta : texto sin el simbolo final ('Inercia (w)' -> 'Inercia')
%       corta    : el simbolo, si es corto ('w'); '' si no hay
%       valor    : valor usado
%       comun    : true si es de parametros_comunes (iteraciones, semilla, paciencia)

    defs = feval(['parametros_' id], representacion);
    if exist('parametros_para_ui', 'file') == 2
        defs = parametros_para_ui(defs);
    end
    comunes = {parametros_comunes().nombre};
    lista = struct('nombre', {}, 'etiqueta', {}, 'corta', {}, 'valor', {}, 'comun', {});
    for k = 1:numel(defs)
        nombre = defs(k).nombre;
        corta = regexp(defs(k).etiqueta, '\(([^()]{1,4})\)$', 'tokens', 'once');
        if isempty(corta), corta = {''}; end
        lista(end + 1) = struct('nombre', nombre, ...
            'etiqueta', strtrim(regexprep(defs(k).etiqueta, '\([^()]{1,4}\)$', '')), ...
            'corta', corta{1}, 'valor', params.(nombre), ...
            'comun', any(strcmp(comunes, nombre))); %#ok<AGROW>
    end
end
