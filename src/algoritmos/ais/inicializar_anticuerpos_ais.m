function poblacion = inicializar_anticuerpos_ais(n, problema, lb, ub)
% INICIALIZAR_ANTICUERPOS_AIS  Crea anticuerpos iniciales factibles.
%   poblacion = inicializar_anticuerpos_ais(n, problema, lb, ub)

    dim = problema.dim;
    switch problema.representacion
        case 'continuo'
            poblacion = lb + rand(n, dim) .* (ub - lb);
        case 'binario'
            poblacion = double(rand(n, dim) < 0.5);
        case 'permutacion'
            poblacion = zeros(n, dim);
            for indice = 1:n
                poblacion(indice, :) = randperm(dim);
            end
    end
end
