function algoritmo = algoritmo_para_ui(id)
% ALGORITMO_PARA_UI  Como se nombra un algoritmo en las pantallas de ejecucion y resultados.
%   algoritmo = algoritmo_para_ui('pso')
%
%   algoritmo : struct con
%       id, nombre, siglas
%       individuos  : como se llama a cada solucion ('partículas', 'vectores', ...)
%       simbolo     : simbolo de la mejor solucion ('g' en PSO, 'x*' en los demas)
%       continuidad : true si cada solucion conserva su identidad entre iteraciones
%                     (entonces el HTML puede animar el movimiento de una a otra)

    catalogo = {
        'ga',  'Algoritmo genético',     'GA',  'individuos',  'x*', false
        'aco', 'Colonia de hormigas',    'ACO', 'hormigas',    'x*', false
        'pso', 'Enjambre de partículas', 'PSO', 'partículas',  'g',  true
        'ais', 'Sistema inmune',         'AIS', 'anticuerpos', 'x*', false
        'de',  'Evolución diferencial',  'DE',  'vectores',    'x*', true
    };
    id = lower(char(id));
    fila = catalogo(strcmp(catalogo(:, 1), id), :);
    if isempty(fila)
        fila = {id, upper(id), upper(id), 'soluciones', 'x*', false};
    end
    algoritmo = cell2struct(fila', {'id', 'nombre', 'siglas', 'individuos', 'simbolo', 'continuidad'});
end
