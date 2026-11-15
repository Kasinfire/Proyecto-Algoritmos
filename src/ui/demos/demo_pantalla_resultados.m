function fig = demo_pantalla_resultados(nombre, dim, id)
% DEMO_PANTALLA_RESULTADOS  Corre un algoritmo y abre la pantalla 5 con su resultado.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_resultados                     % PSO en Rastrigin 2D
%       addpath(genpath('src')); demo_pantalla_resultados('ackley', 5, 'de')

    if nargin < 1, nombre = 'rastrigin'; end
    if nargin < 2, dim = 2; end
    if nargin < 3, id = 'pso'; end

    problema = funcion_prueba(nombre, dim);
    params = valores_por_defecto(feval(['parametros_' id], problema.representacion));
    resultado = feval(id, problema, params);

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_resultados(rejilla, resultado, numero=1, n_guardadas=1, ...
        al_nueva_ejecucion=@() uialert(fig, 'Volver al paso 3 con la misma configuración.', ...
            'Nueva ejecución', 'Icon', 'info'), ...
        al_comparar=@() uialert(fig, 'Ir a comparar ejecuciones.', 'Comparar', 'Icon', 'info'), ...
        al_ir_a_paso=@(paso) uialert(fig, sprintf('Ir al paso %d.', paso + 1), 'Riel', 'Icon', 'info'));
end
