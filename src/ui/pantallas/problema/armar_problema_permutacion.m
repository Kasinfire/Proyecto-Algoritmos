function problema = armar_problema_permutacion(config)
% ARMAR_PROBLEMA_PERMUTACION  Crea el problema de permutacion que el usuario configuro en la pantalla 2.
%   problema = armar_problema_permutacion(config)
%
%   config   : struct con id ('tsp') y las coordenadas x, y de las ciudades
%   problema : struct de crear_problema, listo para cualquier algoritmo.
%   Lanza un error con mensaje legible si la configuracion no es valida.
%
%   La funcion del problema vive en src/problemas/permutacion/:
%       problema = tsp(coordenadas)      % coordenadas: n x 2

    if ~strcmp(config.id, 'tsp')
        error('armar_problema_permutacion:id', 'Problema de permutación desconocido: "%s".', config.id);
    end
    if exist('tsp', 'file') ~= 2
        error('armar_problema_permutacion:falta', ...
              'Este problema todavía está en desarrollo: falta tsp.m en src/problemas/permutacion.');
    end

    x = reshape(double(config.x), [], 1);
    y = reshape(double(config.y), [], 1);
    n = numel(x);
    limites = limites_problema('tsp');
    if n ~= numel(y) || n < limites.dim_min || n > limites.dim_max
        error('armar_problema_permutacion:ciudades', ...
              'El TSP debe tener entre %d y %d ciudades, cada una con x e y.', ...
              limites.dim_min, limites.dim_max);
    end
    if any(~isfinite(x) | ~isfinite(y))
        error('armar_problema_permutacion:coordenadas', 'Las coordenadas deben ser números.');
    end

    problema = tsp([x y]);
end
