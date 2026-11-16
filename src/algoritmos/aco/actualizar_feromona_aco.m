function feromona = actualizar_feromona_aco(feromona, mejor_solucion, params, es_binario)
% ACTUALIZAR_FEROMONA_ACO  Evapora feromona y refuerza la mejor solucion.
%   feromona = actualizar_feromona_aco(feromona, mejor_solucion, params, es_binario)

    if es_binario
        feromona = (1 - params.evaporacion) * feromona + ...
            params.evaporacion * double(mejor_solucion);
        return;
    end

    feromona = (1 - params.evaporacion) * feromona;
    if numel(mejor_solucion) > 1
        siguiente = mejor_solucion([2:end, 1]);
        deposito = params.Q / numel(mejor_solucion);
        for indice = 1:numel(mejor_solucion)
            origen = mejor_solucion(indice);
            destino = siguiente(indice);
            feromona(origen, destino) = feromona(origen, destino) + deposito;
        end
    end
end
