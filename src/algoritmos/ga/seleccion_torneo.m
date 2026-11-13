function idx = seleccion_torneo(costos, k, n)
% SELECCION_TORNEO  Elige n padres: cada uno gana un torneo de k individuos al azar.
%
%   idx = seleccion_torneo(costos, k, n)
%
%   Entradas:
%       costos - Costo a minimizar de cada individuo (N x 1).
%       k      - Individuos por torneo (se sortean con reemplazo).
%       n      - Cuantos padres elegir.
%   Salida:
%       idx - Indices de los ganadores (n x 1).

    candidatos = randi(numel(costos), n, k);
    [~, columna] = min(costos(candidatos), [], 2);
    idx = candidatos(sub2ind(size(candidatos), (1:n)', columna));
end
