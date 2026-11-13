function hijos = mutacion_gaussiana(hijos, tasa, sigma, lb, ub)
% MUTACION_GAUSSIANA  Suma ruido normal a cada gen con probabilidad tasa (continuo).
%
%   hijos = mutacion_gaussiana(hijos, tasa, sigma, lb, ub)
%
%   Entradas:
%       hijos  - Individuos (N x D).
%       tasa   - Probabilidad de mutar cada gen.
%       sigma  - Desviacion estandar por variable (1 x D).
%       lb, ub - Limites del dominio (1 x D); el resultado se recorta a ellos.

    mascara = rand(size(hijos)) < tasa;
    hijos = hijos + mascara .* randn(size(hijos)) .* sigma;
    hijos = limitar_a_rango(hijos, lb, ub);
end
