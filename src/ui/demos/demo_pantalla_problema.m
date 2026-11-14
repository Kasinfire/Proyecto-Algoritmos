function fig = demo_pantalla_problema(tipo)
% DEMO_PANTALLA_PROBLEMA  Abre la pantalla 2 sola, para probar el puente HTML <-> MATLAB.
%   Desde la carpeta Proyecto/:
%       addpath(genpath('src')); demo_pantalla_problema            % continuo
%       addpath(genpath('src')); demo_pantalla_problema('binario')

    if nargin < 1, tipo = 'continuo'; end

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);
    pantalla_problema(rejilla, tipo, ...
        al_continuar=@(problema) uialert(fig, resumen(problema), 'Siguiente', 'Icon', 'info'), ...
        al_regresar=@() uialert(fig, 'Regresar al paso 1.', 'Regresar', 'Icon', 'info'));
end

function texto = resumen(problema)
    texto = sprintf('%s, n = %d, rango [%g, %g], %s.', problema.nombre, problema.dim, ...
                    problema.lb(1), problema.ub(1), problema.sentido);
end
