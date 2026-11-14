function V = mutacion_de(X, mejor, params, lb, ub)
% MUTACION_DE  Vectores mutantes de DE.
%
%   V = mutacion_de(X, mejor, params, lb, ub)
%
%   Para cada x_i se eligen indices distintos entre si y distintos de i:
%       rand/1/bin :  v_i = x_r1 + F*(x_r2 - x_r3)
%       best/1/bin :  v_i = x_mejor + F*(x_r1 - x_r2)
%   Los mutantes se recortan a [lb, ub].
%
%   Entradas:
%       X      - Poblacion de vectores (N x D), N >= 4.
%       mejor  - Mejor vector de la poblacion (1 x D).
%       params - Campos factor_f y estrategia.
%       lb, ub - Limites del espacio de busqueda (1 x D).
%   Salida:
%       V - Mutantes (N x D).

    N = size(X, 1);
    V = zeros(size(X));
    for i = 1:N
        otros = [1:i-1, i+1:N];
        r = otros(randperm(N - 1, 3));
        switch params.estrategia
            case 'rand/1/bin'
                V(i, :) = X(r(1), :) + params.factor_f * (X(r(2), :) - X(r(3), :));
            case 'best/1/bin'
                V(i, :) = mejor + params.factor_f * (X(r(1), :) - X(r(2), :));
        end
    end
    V = limitar_a_rango(V, lb, ub);
end
