function [X, costos] = seleccion_voraz(X, costos, U, costos_u)
% SELECCION_VORAZ  Cada vector de prueba reemplaza a su objetivo si no es peor.
%
%   [X, costos] = seleccion_voraz(X, costos, U, costos_u)
%
%   Entradas:  X, costos - vectores objetivo y su costo;  U, costos_u - vectores de prueba y su costo
%   Salidas:   X, costos - generacion siguiente

    mejoro = costos_u <= costos;
    X(mejoro, :) = U(mejoro, :);
    costos(mejoro) = costos_u(mejoro);
end
