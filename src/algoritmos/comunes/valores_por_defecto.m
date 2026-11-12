function params = valores_por_defecto(defs)
% VALORES_POR_DEFECTO  Convierte un arreglo de parametros en un struct params.
%
%   params = valores_por_defecto(parametros_ga('continuo'))
%   params.n_iteraciones -> 200, params.tam_poblacion -> 50, ...

    params = struct();
    for k = 1:numel(defs)
        params.(defs(k).nombre) = defs(k).valor;
    end
end
