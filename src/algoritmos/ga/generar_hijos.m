function hijos = generar_hijos(poblacion, costos, params, problema, sigma)
% GENERAR_HIJOS  Seleccion, cruza y mutacion: produce la siguiente generacion.
%
%   hijos = generar_hijos(poblacion, costos, params, problema, sigma)
%
%   Entradas:
%       poblacion - Individuos actuales (N x D).
%       costos    - Costo a minimizar de cada individuo (N x 1).
%       params    - Parametros del GA.
%       problema  - Struct del problema.
%       sigma     - Desviacion de la mutacion gaussiana (1 x D); [] si no aplica.
%   Salida:
%       hijos - Nueva generacion (N x D), sin evaluar y con soluciones validas.

    idx = seleccionar_padres(costos, params);
    padres = poblacion(idx, :);
    hijos = cruzar_padres(padres, params.tasa_cruza, elegir_cruza(problema, params));
    if strcmp(problema.representacion, 'continuo')
        hijos = limitar_a_rango(hijos, problema.lb, problema.ub);
    end
    hijos = mutar_hijos(hijos, problema, params, sigma);
end

% -------------------------------------------------------------------------
function idx = seleccionar_padres(costos, params)
    n = numel(costos);
    switch params.seleccion
        case 'torneo'
            idx = seleccion_torneo(costos, params.k_torneo, n);
        case 'ruleta'
            idx = seleccion_ruleta(costos, n);
    end
end

function cruza = elegir_cruza(problema, params)
% Regresa un handle @(a, b) -> [h1, h2] segun la representacion.
    switch problema.representacion
        case 'continuo'
            if strcmp(params.tipo_cruza, 'blx')
                cruza = @(a, b) cruza_blx(a, b, params.alpha_blx);
            else
                cruza = @cruza_aritmetica;
            end
        case 'binario'
            if strcmp(params.tipo_cruza, 'un_punto')
                cruza = @cruza_un_punto;
            else
                cruza = @cruza_uniforme;
            end
        case 'permutacion'
            cruza = @cruza_ox;
    end
end

function hijos = mutar_hijos(hijos, problema, params, sigma)
    switch problema.representacion
        case 'continuo'
            hijos = mutacion_gaussiana(hijos, params.tasa_mutacion, sigma, ...
                                       problema.lb, problema.ub);
        case 'binario'
            hijos = mutacion_bitflip(hijos, params.tasa_mutacion);
        case 'permutacion'
            if strcmp(params.tipo_mutacion, 'swap')
                hijos = mutacion_swap(hijos, params.tasa_mutacion);
            else
                hijos = mutacion_inversion(hijos, params.tasa_mutacion);
            end
    end
end
