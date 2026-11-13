function hijos = cruzar_padres(padres, tasa_cruza, cruza)
% CRUZAR_PADRES  Cruza los padres por parejas (1-2, 3-4, ...).
%
%   hijos = cruzar_padres(padres, tasa_cruza, cruza)
%
%   Cada pareja se cruza con probabilidad tasa_cruza; si no, los hijos son
%   copias de los padres. Si N es impar, el ultimo padre pasa sin cambios.
%
%   Entradas:
%       padres     - Padres ya seleccionados (N x D).
%       tasa_cruza - Probabilidad de cruzar cada pareja.
%       cruza      - Handle [h1, h2] = cruza(a, b); a y b son m x D con una pareja por fila.
%   Salida:
%       hijos - Matriz N x D.

    hijos = padres;
    n_pares = floor(size(padres, 1) / 2);
    pares = find(rand(n_pares, 1) < tasa_cruza);
    if isempty(pares)
        return;
    end
    a = padres(2 * pares - 1, :);
    b = padres(2 * pares, :);
    [h1, h2] = cruza(a, b);
    hijos(2 * pares - 1, :) = h1;
    hijos(2 * pares, :) = h2;
end
