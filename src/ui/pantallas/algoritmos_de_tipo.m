function algoritmos = algoritmos_de_tipo(representacion)
% ALGORITMOS_DE_TIPO  Catalogo de algoritmos para la pantalla 3.
%   algoritmos = algoritmos_de_tipo(representacion)
%
%   representacion : 'continuo', 'binario' o 'permutacion' (la del problema elegido)
%   algoritmos     : struct 1 x 5 con id, nombre, siglas, descripcion, disponible, nota y
%                    parametros. disponible es false si el algoritmo todavia no existe en
%                    src/ o no maneja esta representacion, y nota dice por que.
%                    parametros sale de parametros_<id>(representacion), con los textos
%                    de parametros_para_ui.

    catalogo = {
        'ga',  'Algoritmo genético',     'GA', ...
            'Una población evoluciona por selección, cruza y mutación: los mejores individuos pasan sus genes a la siguiente generación.'
        'aco', 'Colonia de hormigas',    'ACO', ...
            'Cada hormiga arma una ruta paso a paso y deja feromona en los caminos buenos. La feromona se evapora con el tiempo.'
        'pso', 'Enjambre de partículas', 'PSO', ...
            'Cada partícula se mueve combinando su inercia, la atracción hacia su mejor punto y la atracción hacia el mejor punto de todo el enjambre.'
        'ais', 'Sistema inmune',         'AIS', ...
            'Los mejores anticuerpos se clonan y sus clones mutan; los peores se reemplazan por anticuerpos nuevos.'
        'de',  'Evolución diferencial',  'DE', ...
            'Cada vector prueba moverse con la diferencia escalada entre otros dos vectores y se queda con el cambio solo si mejora.'
    };

    algoritmos = struct('id', catalogo(:, 1)', 'nombre', catalogo(:, 2)', ...
        'siglas', catalogo(:, 3)', 'descripcion', catalogo(:, 4)', ...
        'disponible', false, 'nota', '', 'parametros', {{}});

    for k = 1:numel(algoritmos)
        id = algoritmos(k).id;
        [algoritmos(k).disponible, algoritmos(k).nota] = disponibilidad(id, representacion);
        if algoritmos(k).disponible
            algoritmos(k).parametros = parametros_para_ui(feval(['parametros_' id], representacion));
        end
    end
end

function [disponible, nota] = disponibilidad(id, representacion)
    archivos = {id, ['info_' id], ['parametros_' id]};
    if ~all(cellfun(@(f) exist(f, 'file') == 2, archivos))
        disponible = false;
        nota = 'en desarrollo';
        return;
    end
    info = feval(['info_' id]);
    disponible = any(strcmp(info.representaciones, representacion));
    if disponible
        nota = '';
    else
        nota = ['solo para ' strjoin(cellfun(@nombre_representacion, ...
                info.representaciones, 'UniformOutput', false), ' y ')];
    end
end

function texto = nombre_representacion(representacion)
    switch representacion
        case 'continuo',    texto = 'continuos';
        case 'binario',     texto = 'binarios';
        case 'permutacion', texto = 'rutas';
        otherwise,          texto = representacion;
    end
end
