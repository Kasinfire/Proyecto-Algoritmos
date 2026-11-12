function [X1, X2, Z] = malla_funcion(problema, n)
% Evalua f en una malla n x n dentro de [lb, ub] (solo dim 2).
%   Z(a,b) = f( X1(a,b), X2(a,b) )

    x1 = linspace(problema.lb(1), problema.ub(1), n);
    x2 = linspace(problema.lb(2), problema.ub(2), n);
    [X1, X2] = meshgrid(x1, x2);

    Z = zeros(size(X1));
    for a = 1:numel(X1)
        Z(a) = problema.f([X1(a), X2(a)]);
    end
end
