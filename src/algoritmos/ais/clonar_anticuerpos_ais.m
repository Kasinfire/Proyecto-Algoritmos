function clones = clonar_anticuerpos_ais(seleccionados, problema, params, lb, ub)
% CLONAR_ANTICUERPOS_AIS  Clona proporcionalmente al rango y muta cada clon.
%   clones = clonar_anticuerpos_ais(seleccionados, problema, params, lb, ub)

    n_seleccionados = size(seleccionados, 1);
    n_clones = params.n_clones * sum(n_seleccionados:-1:1);
    clones = zeros(n_clones, problema.dim);
    indice_clon = 0;
    for indice = 1:n_seleccionados
        cantidad = params.n_clones * (n_seleccionados - indice + 1);
        tasa = params.tasa_mutacion * indice / (n_seleccionados + 1);
        for numero = 1:cantidad
            indice_clon = indice_clon + 1;
            clones(indice_clon, :) = mutar_anticuerpo_ais( ...
                seleccionados(indice, :), problema, params, tasa, lb, ub);
        end
    end
end
