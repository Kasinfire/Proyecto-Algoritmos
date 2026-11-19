function [feromona, poblacion, heuristica] = inicializar_aco(problema, params)
% INICIALIZAR_ACO  Crea feromonas, poblacion inicial y heuristica.
%   [feromona, poblacion, heuristica] = inicializar_aco(problema, params)

    n_hormigas = params.n_hormigas;
    dim = problema.dim;
    if strcmp(problema.representacion, 'binario')
        feromona = params.probabilidad_inicial * ones(1, dim);
        poblacion = double(rand(n_hormigas, dim) < feromona);
        heuristica = [];
    else
        feromona = params.feromona_inicial * ones(dim, dim);
        poblacion = zeros(n_hormigas, dim);
        for indice = 1:n_hormigas
            poblacion(indice, :) = randperm(dim);
        end
        heuristica = heuristica_aco(problema);
    end
end
