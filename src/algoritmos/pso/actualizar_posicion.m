function [X, V] = actualizar_posicion(X, V, lb, ub)
%ACTUALIZAR_POSICION  Mueve las partículas y las mantiene dentro del dominio.
%
%   [X, V] = ACTUALIZAR_POSICION(X, V, lb, ub)
%
%   Ecuación:
%       x(t+1) = x(t) + v(t+1)
%
%   Manejo de límites: si una partícula sale del dominio, se coloca en el
%   borde y la componente de velocidad en esa dimensión se hace cero, para
%   que no siga empujando hacia afuera en la siguiente iteración.
%
%   Entradas:
%       X, V   - Posiciones y velocidades (N x D).
%       lb, ub - Límites del dominio (1 x D).
%
%   Salidas:
%       X, V   - Posiciones y velocidades corregidas.

    X = X + V;

    fuera_abajo = X < lb;
    fuera_arriba = X > ub;

    X = max(min(X, ub), lb);
    V(fuera_abajo | fuera_arriba) = 0;
end
