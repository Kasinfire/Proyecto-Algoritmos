function hijos = mutacion_inversion(hijos, tasa)
% MUTACION_INVERSION  Con probabilidad tasa, invierte un tramo de la ruta (permutacion).
%
%   hijos = mutacion_inversion(hijos, tasa)
%
%   La tasa es por individuo. Invertir un tramo conserva la permutacion y, en
%   el TSP, cambia solo dos aristas de la ruta.

    [n, D] = size(hijos);
    if D < 2
        return;
    end
    for i = find(rand(n, 1) < tasa)'
        p = sort(randperm(D, 2));
        tramo = p(1):p(2);
        hijos(i, tramo) = fliplr(hijos(i, tramo));
    end
end
