function estrellas = inicializar_estrellas(n, lb, ub)
% Genera n estrellas aleatorias dentro de los limites:
%
%   x_ij = lb_j + rand * (ub_j - lb_j)

dim = numel(lb);
estrellas = lb + rand(n, dim) .* (ub - lb);
end
