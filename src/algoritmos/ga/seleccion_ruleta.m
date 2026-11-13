function idx = seleccion_ruleta(costos, n)
% SELECCION_RULETA  Elige n padres con probabilidad proporcional a su calidad.
%
%   idx = seleccion_ruleta(costos, n)
%
%   Como el costo se minimiza, la calidad es  max(costos) - costo. Asi funciona
%   con costos negativos o de cualquier escala; el peor individuo queda con
%   probabilidad 0. Si todos tienen el mismo costo, la eleccion es uniforme.
%
%   Entradas:
%       costos - Costo a minimizar de cada individuo (N x 1).
%       n      - Cuantos padres elegir.
%   Salida:
%       idx - Indices de los elegidos (n x 1).

    n_individuos = numel(costos);
    calidad = max(costos) - costos(:);
    total = sum(calidad);
    if total > 0
        probabilidad = calidad / total;
    else
        probabilidad = ones(n_individuos, 1) / n_individuos;
    end
    acumulada = cumsum(probabilidad)';
    idx = sum(rand(n, 1) > acumulada, 2) + 1;
    idx = min(idx, n_individuos);   % el redondeo puede dejar acumulada(end) < 1
end
