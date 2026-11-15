function [lb, ub] = espacio_busqueda(problema)
% ESPACIO_BUSQUEDA  Límites del espacio continuo donde se mueve un algoritmo como PSO o DE.
%
%   [lb, ub] = espacio_busqueda(problema)
%
%   continuo            : los límites del problema.
%   binario/permutacion : [0, 1]^dim; la solución se obtiene con decodificar_solucion.
%
%   Salidas:  lb, ub - vectores 1 x dim

    if strcmp(problema.representacion, 'continuo')
        lb = problema.lb;
        ub = problema.ub;
    else
        lb = zeros(1, problema.dim);
        ub = ones(1, problema.dim);
    end
end
