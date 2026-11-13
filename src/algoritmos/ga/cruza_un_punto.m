function [h1, h2] = cruza_un_punto(a, b)
% CRUZA_UN_PUNTO  Cruza de un punto (binario).
%
%   [h1, h2] = cruza_un_punto(a, b)
%
%   Se sortea un punto de corte c por pareja: h1 toma los genes 1..c de a y el
%   resto de b; h2 lo contrario. Con un solo gen no hay donde cortar y los
%   hijos son copias de los padres.
%
%   Entradas:  a, b - parejas de padres (m x D)
%   Salidas:   h1, h2 - hijos (m x D)

    [m, D] = size(a);
    if D < 2
        h1 = a;
        h2 = b;
        return;
    end
    corte = randi(D - 1, m, 1);
    antes = (1:D) <= corte;
    h1 = a .* antes + b .* ~antes;
    h2 = b .* antes + a .* ~antes;
end
