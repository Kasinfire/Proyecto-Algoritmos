function tipos = tipos_de_problema()
% TIPOS_DE_PROBLEMA  Datos de las tarjetas de la pantalla 1 (tipo de problema).
%   tipos = tipos_de_problema()
%
%   tipos : struct 1 x 3 con id, nombre, notacion, descripcion, problemas y algoritmos.
%           problemas y algoritmos se calculan con lo que existe en src/, asi la
%           pantalla se actualiza sola cuando alguien agrega un problema o un algoritmo.

    ids = {'continuo', 'binario', 'permutacion'};
    nombres = {'Continuo', 'Binario', 'Permutación'};
    notaciones = {'x ∈ ℝⁿ', 'x ∈ {0,1}ⁿ', 'π ∈ Sₙ'};
    descripciones = { ...
        'Vector de números reales dentro de un rango. Buscar el punto más bajo de una superficie.', ...
        'Vector de ceros y unos. Cada bit decide si algo se toma o no, como en la mochila.', ...
        'Un orden de los elementos 1 a n. Por ejemplo, el orden en que se visitan ciudades.'};

    problemas = {problemas_continuos(), ...
                 problemas_existentes({'onemax', 'OneMax'; 'mochila', 'Mochila'}), ...
                 problemas_existentes({'tsp', 'TSP'})};

    tipos = struct('id', ids, 'nombre', nombres, 'notacion', notaciones, ...
                   'descripcion', descripciones, 'problemas', {{}}, 'algoritmos', {{}});
    for k = 1:numel(ids)
        tipos(k).problemas = problemas{k};
        tipos(k).algoritmos = algoritmos_para(ids{k});
    end
end

function nombres = problemas_continuos()
    nombres = cellfun(@(n) funcion_prueba(n, 2).nombre, funcion_prueba('lista'), ...
                      'UniformOutput', false);
end

function nombres = problemas_existentes(catalogo)
% catalogo: celda n x 2 con {funcion, nombre visible}.
    existe = cellfun(@(f) exist(f, 'file') == 2, catalogo(:, 1));
    nombres = catalogo(existe, 2)';
end

function siglas = algoritmos_para(representacion)
    siglas = {};
    for id = {'ga', 'aco', 'pso', 'ais', 'de'}
        funcion_info = ['info_' id{1}];
        if exist(funcion_info, 'file') ~= 2, continue; end
        info = feval(funcion_info);
        if any(strcmp(info.representaciones, representacion))
            siglas{end + 1} = upper(id{1}); %#ok<AGROW>
        end
    end
end
