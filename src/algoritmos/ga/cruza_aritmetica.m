function [h1, h2] = cruza_aritmetica(a, b)
% CRUZA_ARITMETICA  Combinacion convexa de los padres (continuo).
%
%   [h1, h2] = cruza_aritmetica(a, b)
%
%   h1 = L*a + (1-L)*b,  h2 = (1-L)*a + L*b,  con L ~ U(0,1) por pareja.
%   Los hijos quedan siempre entre los padres, asi que no se salen del dominio.
%
%   Entradas:  a, b - parejas de padres (m x D)
%   Salidas:   h1, h2 - hijos (m x D)

    lambda = rand(size(a, 1), 1);
    h1 = lambda .* a + (1 - lambda) .* b;
    h2 = (1 - lambda) .* a + lambda .* b;
end
