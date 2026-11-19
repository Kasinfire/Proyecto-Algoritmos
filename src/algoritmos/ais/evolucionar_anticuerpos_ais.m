function [poblacion, costos, evaluaciones] = evolucionar_anticuerpos_ais( ...
        poblacion, costos, problema, params, lb, ub, costo)
% EVOLUCIONAR_ANTICUERPOS_AIS  Selecciona, clona, hipermuta y reemplaza.
%   [poblacion, costos, evaluaciones] = evolucionar_anticuerpos_ais(...)

    [costos, orden] = sort(costos, 'ascend');
    poblacion = poblacion(orden, :);
    seleccionados = poblacion(1:params.n_seleccionados, :);
    clones = clonar_anticuerpos_ais(seleccionados, problema, params, lb, ub);
    costos_clones = evaluar_individuos(clones, costo);
    evaluaciones = size(clones, 1);

    combinados = [poblacion; clones];
    costos_combinados = [costos; costos_clones];
    [costos_combinados, orden] = sort(costos_combinados, 'ascend');
    n_anticuerpos = params.n_anticuerpos;
    poblacion = combinados(orden(1:n_anticuerpos), :);
    costos = costos_combinados(1:n_anticuerpos);

    [poblacion, costos, evaluaciones_reemplazo] = reemplazar_anticuerpos_ais( ...
        poblacion, costos, problema, params, lb, ub, costo);
    evaluaciones = evaluaciones + evaluaciones_reemplazo;
end
