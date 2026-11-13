function [h1, h2] = cruza_blx(a, b, alpha)
% CRUZA_BLX  Cruza BLX-alfa (continuo).
%
%   [h1, h2] = cruza_blx(a, b, alpha)
%
%   Cada gen del hijo se sortea uniforme en
%       [min - alpha*d,  max + alpha*d],   con d = |a - b|
%   Con alpha > 0 el hijo puede salir un poco del intervalo de los padres, lo
%   que mantiene exploracion; el recorte a [lb, ub] se hace en generar_hijos.
%
%   Entradas:  a, b - parejas de padres (m x D);  alpha - ampliacion del intervalo
%   Salidas:   h1, h2 - hijos (m x D)

    menor = min(a, b);
    d = max(a, b) - menor;
    limite_inf = menor - alpha * d;
    ancho = (1 + 2 * alpha) * d;
    h1 = limite_inf + rand(size(a)) .* ancho;
    h2 = limite_inf + rand(size(a)) .* ancho;
end
