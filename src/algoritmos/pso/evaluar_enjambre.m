function costos = evaluar_enjambre(X, costo)
%EVALUAR_ENJAMBRE  Evalúa la función de costo en cada partícula.
%
%   costos = EVALUAR_ENJAMBRE(X, costo)
%
%   Entradas:
%       X     - Posiciones del enjambre (N x D); cada fila es una partícula.
%       costo - Handle de la función a minimizar; recibe una fila (1 x D).
%
%   Salida:
%       costos - Vector columna (N x 1) con el costo de cada partícula.

    n_particulas = size(X, 1);
    costos = zeros(n_particulas, 1);
    for i = 1:n_particulas
        costos(i) = costo(X(i, :));
    end
end
