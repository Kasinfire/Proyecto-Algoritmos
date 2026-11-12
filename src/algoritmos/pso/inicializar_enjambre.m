function [X, V] = inicializar_enjambre(n_particulas, lb, ub, vmax)
%INICIALIZAR_ENJAMBRE  Crea posiciones y velocidades iniciales aleatorias.
%
%   [X, V] = INICIALIZAR_ENJAMBRE(n_particulas, lb, ub, vmax)
%
%   Entradas:
%       n_particulas - Número de partículas N.
%       lb, ub      - Límites inferior y superior del dominio (1 x D).
%       vmax        - Velocidad máxima permitida por dimensión (1 x D).
%
%   Salidas:
%       X - Posiciones (N x D), distribuidas uniformemente en [lb, ub].
%       V - Velocidades (N x D), uniformes en [-vmax, vmax].

    D = numel(lb);
    X = lb + rand(n_particulas, D) .* (ub - lb);
    V = -vmax + rand(n_particulas, D) .* (2 * vmax);
end
