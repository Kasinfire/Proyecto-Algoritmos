function soluciones = decodificar_solucion(X, representacion)
% DECODIFICAR_SOLUCION  Convierte vectores reales en soluciones de la representación del problema.
%
%   soluciones = decodificar_solucion(X, representacion)
%
%   continuo    : X sin cambios.
%   binario     : umbral, el bit es 1 si x > 0.5.
%   permutacion : random keys, la ruta es el orden de las llaves (decodificar_llaves).
%
%   Entradas:  X - matriz N x D;  representacion - 'continuo', 'binario' o 'permutacion'
%   Salida:    soluciones - matriz N x D

    switch representacion
        case 'binario'
            soluciones = double(X > 0.5);
        case 'permutacion'
            soluciones = decodificar_llaves(X);
        otherwise
            soluciones = X;
    end
end
