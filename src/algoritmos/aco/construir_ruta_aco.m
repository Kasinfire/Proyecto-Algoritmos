function ruta = construir_ruta_aco(feromona, heuristica, params, dim)
% CONSTRUIR_RUTA_ACO  Construye una permutacion con transiciones probabilisticas.
%   ruta = construir_ruta_aco(feromona, heuristica, params, dim)

    ruta = zeros(1, dim);
    ruta(1) = randi(dim);
    disponibles = true(1, dim);
    disponibles(ruta(1)) = false;
    for posicion = 2:dim
        actual = ruta(posicion - 1);
        candidatos = find(disponibles);
        pesos = feromona(actual, candidatos) .^ params.alfa .* ...
            heuristica(actual, candidatos) .^ params.beta;
        siguiente = candidatos(seleccionar_ruleta_aco(pesos));
        ruta(posicion) = siguiente;
        disponibles(siguiente) = false;
    end
end
