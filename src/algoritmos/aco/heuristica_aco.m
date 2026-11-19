function heuristica = heuristica_aco(problema)
% HEURISTICA_ACO  Calcula la preferencia por aristas usando distancias si existen.
%   heuristica = heuristica_aco(problema)

    dim = problema.dim;
    if isfield(problema.datos, 'distancias') && ...
            isequal(size(problema.datos.distancias), [dim, dim])
        distancias = problema.datos.distancias;
        heuristica = 1 ./ max(distancias, eps);
    else
        heuristica = ones(dim);
    end
    heuristica(1:dim + 1:end) = 0;
end
