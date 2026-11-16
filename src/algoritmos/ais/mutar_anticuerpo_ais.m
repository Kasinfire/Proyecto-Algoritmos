function hijo = mutar_anticuerpo_ais(padre, problema, params, tasa, lb, ub)
% MUTAR_ANTICUERPO_AIS  Aplica hipermutacion segun la representacion.
%   hijo = mutar_anticuerpo_ais(padre, problema, params, tasa, lb, ub)

    hijo = padre;
    switch problema.representacion
        case 'continuo'
            mascara = rand(size(padre)) < tasa;
            hijo(mascara) = hijo(mascara) + params.sigma_mutacion .* ...
                (ub(mascara) - lb(mascara)) .* randn(1, nnz(mascara));
            hijo = limitar_a_rango(hijo, lb, ub);
        case 'binario'
            mascara = rand(size(padre)) < tasa;
            hijo(mascara) = 1 - hijo(mascara);
        case 'permutacion'
            if numel(padre) > 1 && rand < tasa
                posiciones = randperm(numel(padre), 2);
                hijo(posiciones) = hijo(fliplr(posiciones));
            end
    end
end
