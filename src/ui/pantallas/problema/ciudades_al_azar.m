function [x, y] = ciudades_al_azar(n, semilla)
% CIUDADES_AL_AZAR  Coordenadas de una instancia de TSP generada con una semilla.
%   [x, y] = ciudades_al_azar(n, semilla)
%
%   n       : numero de ciudades
%   semilla : entero >= 0; la misma semilla siempre da las mismas ciudades
%   x, y    : vectores fila 1 x n en el cuadrado [0, 100] x [0, 100]
%
%   Usa su propio generador para no mover el rng global de los algoritmos.

    flujo = RandStream('mt19937ar', 'Seed', semilla);
    puntos = round(100 * rand(flujo, 2, n), 2);
    x = puntos(1, :);
    y = puntos(2, :);
end
