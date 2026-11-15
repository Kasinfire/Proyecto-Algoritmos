function fig = demo_pantalla_algoritmo(id_problema, dim)
% DEMO_PANTALLA_ALGORITMO  Abre la pantalla 3 sola, para probar el puente HTML <-> MATLAB.
%   Al presionar Ejecutar corre el algoritmo elegido y muestra el mejor valor.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_algoritmo                 % Rastrigin en 2D
%       addpath(genpath('src')); demo_pantalla_algoritmo('ackley', 10)
%       addpath(genpath('src')); demo_pantalla_algoritmo('horario')       % problema real
%
%   Con 'horario' se usa un problema binario de prueba con 26 secciones de 6 materias
%   (f cuenta cuantas materias no tienen exactamente una seccion) mientras no exista horario.m.

    if nargin < 1, id_problema = 'rastrigin'; end
    if nargin < 2, dim = 2; end

    tipo = '';
    config = struct();
    if strcmp(id_problema, 'horario')
        [problema, config] = horario_de_prueba();
        tipo = 'real';
    else
        problema = funcion_prueba(id_problema, dim);
    end
    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_algoritmo(rejilla, problema, ...
        al_ejecutar=@(id, params) ejecutar(fig, problema, id, params), ...
        al_regresar=@() uialert(fig, 'Regresar al paso 2.', 'Regresar', 'Icon', 'info'), ...
        al_ir_a_tipo=@() uialert(fig, 'Ir al paso 1.', 'Tipo', 'Icon', 'info'), ...
        tipo=tipo, config=config);
end

function [problema, config] = horario_de_prueba()
    materia = repelem(1:6, [5 4 5 4 4 4]);
    f = @(x) sum(accumarray(materia(:), x(:), [6 1]) ~= 1);
    problema = crear_problema('Horario de materias', f, 0, 1, numel(materia), ...
        representacion='binario', sentido='min', sentido_fijo=true);
    config = struct('claves', "M" + (1:6));
end

function ejecutar(fig, problema, id, params)
    espera = uiprogressdlg(fig, 'Title', upper(id), 'Message', 'Ejecutando...', 'Indeterminate', 'on');
    resultado = feval(id, problema, params);
    close(espera);
    uialert(fig, sprintf('%s terminó en %d iteraciones. Mejor valor: %.6g', ...
            resultado.algoritmo, resultado.iteraciones, resultado.mejor_valor), ...
            'Resultado', 'Icon', 'success');
end
