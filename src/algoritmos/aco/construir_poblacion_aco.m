function poblacion = construir_poblacion_aco(feromona, heuristica, problema, params)
% CONSTRUIR_POBLACION_ACO  Construye hormigas segun la representacion.
%   poblacion = construir_poblacion_aco(feromona, heuristica, problema, params)

    n_hormigas = params.n_hormigas;
    dim = problema.dim;
    if strcmp(problema.representacion, 'binario')
        poblacion = double(rand(n_hormigas, dim) < feromona);
    else
        poblacion = zeros(n_hormigas, dim);
        for indice = 1:n_hormigas
            poblacion(indice, :) = construir_ruta_aco(feromona, heuristica, params, dim);
        end
    end
end
