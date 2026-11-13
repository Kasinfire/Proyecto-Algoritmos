function [h1, h2] = cruza_ox(a, b)
% CRUZA_OX  Cruza de orden OX (permutacion).
%
%   [h1, h2] = cruza_ox(a, b)
%
%   Un hijo conserva el tramo [c1, c2] de un padre en su misma posicion; el
%   resto se llena con los elementos del otro padre en su orden relativo,
%   empezando despues de c2 y sin repetir. Siempre regresa permutaciones.
%
%   Entradas:  a, b - parejas de padres (m x D), cada fila una permutacion
%   Salidas:   h1, h2 - hijos (m x D)

    h1 = zeros(size(a));
    h2 = zeros(size(b));
    for i = 1:size(a, 1)
        D = size(a, 2);
        cortes = sort(randi(D, 1, 2));
        h1(i, :) = ox_un_hijo(a(i, :), b(i, :), cortes(1), cortes(2));
        h2(i, :) = ox_un_hijo(b(i, :), a(i, :), cortes(1), cortes(2));
    end
end

% -------------------------------------------------------------------------
function hijo = ox_un_hijo(p1, p2, c1, c2)
% Tramo c1..c2 de p1; el resto, de p2 en orden desde c2 + 1 (circular).
    D = numel(p1);
    hijo = zeros(1, D);
    hijo(c1:c2) = p1(c1:c2);

    orden = circshift(1:D, -c2);                         % posiciones c2+1, ..., D, 1, ..., c2
    candidatos = p2(orden);
    candidatos = candidatos(~ismember(candidatos, p1(c1:c2)));
    libres = orden(~ismember(orden, c1:c2));
    hijo(libres) = candidatos;
end
