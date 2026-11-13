function costos = evaluar_individuos(poblacion, costo)
% EVALUAR_INDIVIDUOS  Evalua la funcion de costo en cada individuo.
%
%   costos = evaluar_individuos(poblacion, costo)
%
%   Entradas:
%       poblacion - Soluciones (N x D); cada fila es un individuo.
%       costo     - Handle de la funcion a minimizar; recibe una fila (1 x D).
%   Salida:
%       costos - Vector columna (N x 1).
%
%   Tambien lo usa de.m.

    n = size(poblacion, 1);
    costos = zeros(n, 1);
    for i = 1:n
        costos(i) = costo(poblacion(i, :));
    end
end
