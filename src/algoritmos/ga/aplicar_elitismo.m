function [hijos, costos_hijos] = aplicar_elitismo(hijos, costos_hijos, poblacion, costos, n_elite)
% APLICAR_ELITISMO  Los mejores padres reemplazan a los peores hijos.
%
%   [hijos, costos_hijos] = aplicar_elitismo(hijos, costos_hijos, poblacion, costos, n_elite)
%
%   Garantiza que el mejor valor de la poblacion no empeora entre generaciones.
%   n_elite se limita a N - 1 para que siempre entre al menos un hijo.
%
%   Entradas:
%       hijos, costos_hijos - Nueva generacion y su costo.
%       poblacion, costos   - Generacion anterior y su costo.
%       n_elite             - Cuantos padres conservar.

    n_elite = min(n_elite, size(poblacion, 1) - 1);
    if n_elite <= 0
        return;
    end
    [~, mejores_padres] = mink(costos, n_elite);
    [~, peores_hijos] = maxk(costos_hijos, n_elite);
    hijos(peores_hijos, :) = poblacion(mejores_padres, :);
    costos_hijos(peores_hijos) = costos(mejores_padres);
end
