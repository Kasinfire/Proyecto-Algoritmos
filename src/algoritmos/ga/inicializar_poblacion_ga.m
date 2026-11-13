function poblacion = inicializar_poblacion_ga(problema, n)
% INICIALIZAR_POBLACION_GA  Crea n individuos aleatorios validos.
%
%   poblacion = inicializar_poblacion_ga(problema, n)
%
%   continuo    : uniforme en [lb, ub].
%   binario     : cada bit 0 o 1 con la misma probabilidad.
%   permutacion : permutaciones aleatorias de 1..dim.

    switch problema.representacion
        case 'continuo'
            poblacion = problema.lb + rand(n, problema.dim) .* (problema.ub - problema.lb);
        case 'binario'
            poblacion = double(rand(n, problema.dim) > 0.5);
        case 'permutacion'
            poblacion = zeros(n, problema.dim);
            for i = 1:n
                poblacion(i, :) = randperm(problema.dim);
            end
    end
end
