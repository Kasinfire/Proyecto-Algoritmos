function x = limitar_a_rango(x, lb, ub)
% Regresa a los limites las estrellas que se salieron:
%
%   x_ij = min( max(x_ij, lb_j), ub_j )

x = min(max(x, lb), ub);
end
