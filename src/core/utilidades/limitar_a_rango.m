function x = limitar_a_rango(x, lb, ub)
% LIMITAR_A_RANGO  Regresa a los límites las componentes que se salieron.
%
%   x = limitar_a_rango(x, lb, ub)
%
%   x_ij = min( max(x_ij, lb_j), ub_j )
%
%   Entradas:  x - matriz N x D;  lb, ub - límites (1 x D o escalares)
%   Salida:    x - la misma matriz dentro de [lb, ub]

    x = min(max(x, lb), ub);
end
