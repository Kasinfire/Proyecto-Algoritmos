function resultado = de(problema, params, al_cada_iteracion)
% DE  Evolucion Diferencial (estrategias rand/1/bin y best/1/bin).
%
%   resultado = de(problema, params)
%   resultado = de(problema, params, al_cada_iteracion)
%
%   Entradas y salida segun docs/guia_desarrollo.md, seccion 4.
%   Parametros: ver parametros_de(representacion).
%
%   Pasos por generacion (para cada vector x_i de la poblacion):
%       1. Mutacion:  v = x_r1 + F*(x_r2 - x_r3)        (rand/1)
%                     v = x_mejor + F*(x_r1 - x_r2)     (best/1)
%       2. Cruza binomial: u_j = v_j con probabilidad CR (y siempre en un j al azar); si no, x_j.
%       3. Seleccion voraz: u reemplaza a x_i si su costo no es peor.
%
%   Representaciones:
%       continuo    : x vive en [lb, ub] y es la solucion directamente.
%       binario     : x en [0, 1]^dim; el bit es 1 si x > 0.5 (umbral).
%       permutacion : random keys; x en [0, 1]^dim y la ruta es el orden de las llaves.

    if nargin < 3, al_cada_iteracion = []; end
    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);

    N = params.tam_poblacion;
    [lb, ub] = espacio_busqueda(problema);
    X = lb + rand(N, problema.dim) .* (ub - lb);

    poblacion = decodificar(X, problema.representacion);
    costos = evaluar_individuos(poblacion, costo);
    evaluaciones = N;
    [mejor_costo, i] = min(costos);
    mejor_solucion = poblacion(i, :);

    hist_valor = zeros(params.n_iteraciones + 1, 1);
    hist_solucion = zeros(params.n_iteraciones + 1, problema.dim);
    hist_poblacion = cell(params.n_iteraciones + 1, 1);
    motivo = 'max_iteraciones';
    sin_mejora = 0;

    for t = 0:params.n_iteraciones
        if t > 0
            [~, i_mejor] = min(costos);
            V = mutacion_de(X, X(i_mejor, :), params, lb, ub);
            U = cruza_binomial(X, V, params.tasa_cr);

            costos_u = evaluar_individuos(decodificar(U, problema.representacion), costo);
            evaluaciones = evaluaciones + N;
            [X, costos] = seleccion_voraz(X, costos, U, costos_u);
            poblacion = decodificar(X, problema.representacion);

            % La seleccion voraz impide que el mejor empeore, pero el mejor
            % global se actualiza explicitamente para contar sin_mejora.
            [mejor_de_generacion, i] = min(costos);
            if mejor_de_generacion < mejor_costo
                mejor_costo = mejor_de_generacion;
                mejor_solucion = poblacion(i, :);
                sin_mejora = 0;
            else
                sin_mejora = sin_mejora + 1;
            end
        end

        hist_valor(t + 1) = signo * mejor_costo;
        hist_solucion(t + 1, :) = mejor_solucion;
        hist_poblacion{t + 1} = poblacion;

        if ~isempty(al_cada_iteracion)
            estado = struct('iteracion', t, 'n_iteraciones', params.n_iteraciones, ...
                'mejor_valor', signo * mejor_costo, 'mejor_solucion', mejor_solucion, ...
                'poblacion', poblacion, 'evaluaciones', evaluaciones);
            if al_cada_iteracion(estado)
                motivo = 'detenido';
                break;
            end
        end
        if params.paciencia > 0 && sin_mejora >= params.paciencia
            motivo = 'convergencia';
            break;
        end
    end

    n = t + 1;
    info = info_de();
    resultado.algoritmo = 'DE';
    resultado.variante = info.variante;
    resultado.problema = problema;
    resultado.params = params;
    resultado.sentido = problema.sentido;
    resultado.mejor_solucion = mejor_solucion;
    resultado.mejor_valor = signo * mejor_costo;
    resultado.iteraciones = t;
    resultado.motivo_termino = motivo;
    resultado.evaluaciones = evaluaciones;
    resultado.tiempo = toc(t_inicio);
    resultado.historial.mejor_valor = hist_valor(1:n);
    resultado.historial.mejor_solucion = hist_solucion(1:n, :);
    resultado.historial.poblacion = hist_poblacion(1:n);
end

% -------------------------------------------------------------------------
function [lb, ub] = espacio_busqueda(problema)
% Limites del espacio donde viven los vectores de DE.
    if strcmp(problema.representacion, 'continuo')
        lb = problema.lb;
        ub = problema.ub;
    else
        lb = zeros(1, problema.dim);
        ub = ones(1, problema.dim);
    end
end

function soluciones = decodificar(X, representacion)
% Vectores de DE -> soluciones en la representacion del problema.
    switch representacion
        case 'binario'
            soluciones = double(X > 0.5);
        case 'permutacion'
            soluciones = decodificar_llaves(X);
        otherwise
            soluciones = X;
    end
end
