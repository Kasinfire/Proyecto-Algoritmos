function [poblacion, costos, evaluaciones] = reemplazar_anticuerpos_ais( ...
        poblacion, costos, problema, params, lb, ub, costo)
% REEMPLAZAR_ANTICUERPOS_AIS  Sustituye los peores anticuerpos por nuevos.
%   [poblacion, costos, evaluaciones] = reemplazar_anticuerpos_ais(...)

    n_reemplazo = min(params.n_reemplazo, params.n_anticuerpos);
    if n_reemplazo == 0
        evaluaciones = 0;
        return;
    end

    nuevos = inicializar_anticuerpos_ais(n_reemplazo, problema, lb, ub);
    nuevos_costos = evaluar_individuos(nuevos, costo);
    poblacion(end - n_reemplazo + 1:end, :) = nuevos;
    costos(end - n_reemplazo + 1:end) = nuevos_costos;
    [costos, orden] = sort(costos, 'ascend');
    poblacion = poblacion(orden, :);
    evaluaciones = n_reemplazo;
end
