function rutas = decodificar_llaves(llaves)
% DECODIFICAR_LLAVES  Convierte random keys en permutaciones.
%
%   rutas = decodificar_llaves(llaves)
%
%   Cada fila de llaves (valores reales) se ordena y el orden resultante es la
%   permutacion. Ejemplo: [0.7 0.1 0.4] -> [2 3 1]. Permite usar algoritmos de
%   espacio continuo (PSO, DE) en problemas de permutacion como el TSP.
%
%   Entradas:  llaves - matriz N x D
%   Salidas:   rutas  - matriz N x D, cada fila es una permutacion de 1..D

    [~, rutas] = sort(llaves, 2);
end
