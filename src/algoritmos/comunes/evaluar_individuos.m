function costos = evaluar_individuos(poblacion, costo)
% EVALUAR_INDIVIDUOS  Evalúa la función de costo en cada solución de la población.
%
%   costos = evaluar_individuos(poblacion, costo)
%
%   Entradas:
%       poblacion - Soluciones (N x D); cada fila es un individuo, partícula o vector.
%       costo     - Handle de la función a minimizar; recibe una fila (1 x D).
%   Salida:
%       costos - Vector columna (N x 1).

    n = size(poblacion, 1);
    costos = zeros(n, 1);
    for i = 1:n
        costos(i) = costo(poblacion(i, :));
    end
end
