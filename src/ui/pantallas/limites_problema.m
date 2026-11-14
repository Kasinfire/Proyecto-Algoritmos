function limites = limites_problema(id)
% LIMITES_PROBLEMA  Dimensiones permitidas de un problema en la pantalla 2.
%   limites = limites_problema(id)
%
%   id      : identificador del problema ('rastrigin', 'himmelblau', ...)
%   limites : struct con dim_min, dim_max y dim_defecto.
%
%   Las funciones simples se plantean en 1D, Himmelblau y Eggholder solo existen
%   en 2D y el resto empieza en 2D. El maximo es igual para todas.

    dim_max = 100;
    switch id
        case {'parabolica', 'seno', 'lineal', 'exponencial', 'coseno'}
            limites = struct('dim_min', 1, 'dim_max', dim_max, 'dim_defecto', 1);
        case {'himmelblau', 'eggholder'}
            limites = struct('dim_min', 2, 'dim_max', 2, 'dim_defecto', 2);
        otherwise
            limites = struct('dim_min', 2, 'dim_max', dim_max, 'dim_defecto', 2);
    end
end
