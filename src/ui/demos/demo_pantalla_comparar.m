function fig = demo_pantalla_comparar()
% DEMO_PANTALLA_COMPARAR  Corre cinco ejecuciones y abre la pantalla de comparar.
%   Cuatro sobre Rastrigin 2D con semilla 42 (PSO con w = 0.7 y w = 0.4, GA y DE) y una
%   sobre Ackley 5D, que aparece desactivada porque es otro problema.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_comparar

    rastrigin = funcion_prueba('rastrigin', 2);
    ackley = funcion_prueba('ackley', 5);
    corridas = {
        rastrigin, 'pso', struct('w', 0.7)
        rastrigin, 'pso', struct('w', 0.4)
        rastrigin, 'ga',  struct()
        rastrigin, 'de',  struct()
        ackley,    'pso', struct()
    };

    ejecuciones = struct('numero', {}, 'resultado', {});
    for k = 1:size(corridas, 1)
        [problema, id, cambios] = corridas{k, :};
        params = valores_por_defecto(feval(['parametros_' id], problema.representacion));
        for campo = fieldnames(cambios)'
            params.(campo{1}) = cambios.(campo{1});
        end
        ejecuciones(end + 1) = struct('numero', k, 'resultado', feval(id, problema, params)); %#ok<AGROW>
    end

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_comparar(rejilla, ejecuciones, elegida=1, ...
        al_volver=@() uialert(fig, 'Volver a la pantalla anterior.', 'Volver', 'Icon', 'info'), ...
        al_ir_a_paso=@(paso) uialert(fig, sprintf('Ir al paso %d.', paso + 1), 'Riel', 'Icon', 'info'));
end
