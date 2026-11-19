function problema = tsp(coordenadas)
% TSP  Crea el problema del agente viajero con coordenadas cartesianas.
%   problema = tsp(coordenadas)
%   coordenadas: matriz n x 2; cada fila guarda [x, y] de una ciudad.

    if ~isnumeric(coordenadas) || ~isreal(coordenadas) || ...
            size(coordenadas, 2) ~= 2 || size(coordenadas, 1) < 2
        error('tsp:coordenadas', ...
            'Las coordenadas deben ser una matriz real n x 2 con al menos dos ciudades.');
    end
    coordenadas = double(coordenadas);
    if any(~isfinite(coordenadas), 'all')
        error('tsp:coordenadas', 'Todas las coordenadas deben ser finitas.');
    end

    diferencias_x = coordenadas(:, 1) - coordenadas(:, 1)';
    diferencias_y = coordenadas(:, 2) - coordenadas(:, 2)';
    distancias = hypot(diferencias_x, diferencias_y);
    datos = struct('coordenadas', coordenadas, 'distancias', distancias);
    dim = size(coordenadas, 1);
    funcion = @(ruta) longitud_ruta_tsp(ruta, distancias, dim);
    descripcion = ['La solucion es el orden de visita de las ciudades. La funcion ' ...
        'suma las distancias euclidianas entre ciudades consecutivas y cierra la ruta ' ...
        'regresando de la ultima ciudad a la primera.'];

    problema = crear_problema('TSP', funcion, [], [], dim, ...
        representacion='permutacion', sentido='min', sentido_fijo=true, ...
        datos=datos, descripcion=descripcion);
end

function longitud = longitud_ruta_tsp(ruta, distancias, dim)
% LONGITUD_RUTA_TSP  Suma las aristas de una ruta cerrada valida.
    if ~isnumeric(ruta) || ~isreal(ruta) || ~isvector(ruta) || numel(ruta) ~= dim || ...
            any(~isfinite(ruta)) || any(ruta ~= fix(ruta)) || ...
            ~isequal(sort(reshape(ruta, 1, [])), 1:dim)
        error('tsp:ruta', 'La ruta debe ser una permutacion de los enteros 1..dim.');
    end
    ruta = double(reshape(ruta, 1, []));
    siguiente = ruta([2:end, 1]);
    indices = sub2ind([dim, dim], ruta, siguiente);
    longitud = sum(distancias(indices));
end
