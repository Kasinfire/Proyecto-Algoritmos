function fig = demo_pantalla_tipo()
% DEMO_PANTALLA_TIPO  Abre la pantalla 1 sola, para probar el puente HTML <-> MATLAB.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_tipo

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_tipo(rejilla, ...
        al_continuar=@(tipo) uialert(fig, ['Tipo elegido: ' tipo], 'Siguiente', 'Icon', 'info'));
end
