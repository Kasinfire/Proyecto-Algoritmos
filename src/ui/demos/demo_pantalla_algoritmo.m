function fig = demo_pantalla_algoritmo(id_problema, dim)
% DEMO_PANTALLA_ALGORITMO  Abre la pantalla 3 sola, para probar el puente HTML <-> MATLAB.
%   Al presionar Ejecutar corre el algoritmo elegido y muestra el mejor valor.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_algoritmo                 % Rastrigin en 2D
%       addpath(genpath('src')); demo_pantalla_algoritmo('ackley', 10)

    if nargin < 1, id_problema = 'rastrigin'; end
    if nargin < 2, dim = 2; end

    problema = funcion_prueba(id_problema, dim);
    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_algoritmo(rejilla, problema, ...
        al_ejecutar=@(id, params) ejecutar(fig, problema, id, params), ...
        al_regresar=@() uialert(fig, 'Regresar al paso 2.', 'Regresar', 'Icon', 'info'), ...
        al_ir_a_tipo=@() uialert(fig, 'Ir al paso 1.', 'Tipo', 'Icon', 'info'));
end

function ejecutar(fig, problema, id, params)
    espera = uiprogressdlg(fig, 'Title', upper(id), 'Message', 'Ejecutando...', 'Indeterminate', 'on');
    resultado = feval(id, problema, params);
    close(espera);
    uialert(fig, sprintf('%s terminó en %d iteraciones. Mejor valor: %.6g', ...
            resultado.algoritmo, resultado.iteraciones, resultado.mejor_valor), ...
            'Resultado', 'Icon', 'success');
end
