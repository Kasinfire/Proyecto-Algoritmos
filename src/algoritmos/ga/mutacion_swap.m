function hijos = mutacion_swap(hijos, tasa)
% MUTACION_SWAP  Con probabilidad tasa, intercambia dos posiciones de la ruta (permutacion).
%
%   hijos = mutacion_swap(hijos, tasa)
%
%   La tasa es por individuo. Un intercambio conserva la permutacion.

    [n, D] = size(hijos);
    if D < 2
        return;
    end
    for i = find(rand(n, 1) < tasa)'
        p = randperm(D, 2);
        hijos(i, p) = hijos(i, fliplr(p));
    end
end
