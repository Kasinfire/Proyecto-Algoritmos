function [pbest, pbest_costo] = actualizar_mejores_personales(X, costos, pbest, pbest_costo)
%ACTUALIZAR_MEJORES_PERSONALES  Actualiza la memoria (pbest) de cada partícula.
%
%   [pbest, pbest_costo] = ACTUALIZAR_MEJORES_PERSONALES(X, costos, pbest, pbest_costo)
%
%   Si una partícula encontró en esta iteración una posición con menor
%   costo que su mejor posición histórica, esa posición pasa a ser su
%   nueva pbest.
%
%   Entradas:
%       X          - Posiciones actuales (N x D).
%       costos     - Costo de las posiciones actuales (N x 1).
%       pbest      - Mejores posiciones personales previas (N x D).
%       pbest_costo - Costo de esas posiciones (N x 1).
%
%   Salidas:
%       pbest, pbest_costo - Valores actualizados.

    mejoro = costos < pbest_costo;
    pbest(mejoro, :)   = X(mejoro, :);
    pbest_costo(mejoro) = costos(mejoro);
end
