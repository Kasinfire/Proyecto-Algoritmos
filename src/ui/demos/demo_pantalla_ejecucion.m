function fig = demo_pantalla_ejecucion(nombre, dim, id)
% DEMO_PANTALLA_EJECUCION  Abre la pantalla 4 sola, con un algoritmo ya configurado.
%   Al presionar Ver resultados cambia a la pantalla 5 con ese resultado.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_ejecucion                     % PSO en Rastrigin 2D
%       addpath(genpath('src')); demo_pantalla_ejecucion('ackley', 5, 'de')

    if nargin < 1, nombre = 'rastrigin'; end
    if nargin < 2, dim = 2; end
    if nargin < 3, id = 'pso'; end

    problema = funcion_prueba(nombre, dim);
    params = valores_por_defecto(feval(['parametros_' id], problema.representacion));

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_ejecucion(rejilla, problema, id, params, ...
        al_ver_resultados=@(r) ver_resultados(fig, rejilla, r), ...
        al_regresar=@() uialert(fig, 'Regresar al paso 3.', 'Regresar', 'Icon', 'info'), ...
        al_ir_a_paso=@(paso) uialert(fig, sprintf('Ir al paso %d.', paso + 1), 'Riel', 'Icon', 'info'));
end

function ver_resultados(fig, rejilla, resultado)
    delete(rejilla.Children);
    pantalla_resultados(rejilla, resultado, numero=1, n_guardadas=1, ...
        al_comparar=@() uialert(fig, 'Ir a comparar ejecuciones.', 'Comparar', 'Icon', 'info'), ...
        al_ir_a_paso=@(paso) uialert(fig, sprintf('Ir al paso %d.', paso + 1), 'Riel', 'Icon', 'info'));
end
