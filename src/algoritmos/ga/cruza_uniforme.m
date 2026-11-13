function [h1, h2] = cruza_uniforme(a, b)
% CRUZA_UNIFORME  Cruza uniforme (binario).
%
%   [h1, h2] = cruza_uniforme(a, b)
%
%   Cada gen de h1 viene de a o de b con la misma probabilidad; h2 toma el
%   gen contrario.
%
%   Entradas:  a, b - parejas de padres (m x D)
%   Salidas:   h1, h2 - hijos (m x D)

    de_a = rand(size(a)) < 0.5;
    h1 = a .* de_a + b .* ~de_a;
    h2 = b .* de_a + a .* ~de_a;
end
