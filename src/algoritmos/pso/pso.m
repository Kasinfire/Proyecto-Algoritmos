function resultado = pso(problema, params, al_cada_iteracion)
% PSO  Optimizacion por Enjambre de Particulas (version global, gbest).
%
%   resultado = pso(problema, params)
%   resultado = pso(problema, params, al_cada_iteracion)
%
%   Entradas y salida segun docs/guia_desarrollo.md, seccion 4.
%   Parametros: ver parametros_pso(representacion).
%
%   Pasos por iteracion:
%       1. v = w*v + c1*r1*(pbest - x) + c2*r2*(gbest - x), limitada a [-vmax, vmax]
%       2. Mover x segun la representacion (ver mover_enjambre)
%       3. Evaluar las soluciones decodificadas
%       4. Actualizar pbest y gbest
%
%   Representaciones:
%       continuo    : x vive en [lb, ub] y es la solucion directamente.
%       binario     : BPSO (Kennedy y Eberhart, 1997); x_ij = 1 con probabilidad sigmoide(v_ij).
%       permutacion : random keys; x en [0, 1]^dim y la ruta es el orden de las llaves.

    if nargin < 3, al_cada_iteracion = []; end
    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);

    [lb, ub, vmax] = espacio_busqueda(problema, params);
    [X, V] = inicializar_enjambre(params.n_particulas, lb, ub, vmax);
    if strcmp(problema.representacion, 'binario')
        X = double(X > 0.5);
    end

    poblacion = decodificar(X, problema.representacion);
    costo_actual = evaluar_enjambre(poblacion, costo);
    evaluaciones = params.n_particulas;

    pbest = X;
    pbest_costo = costo_actual;
    [gbest_costo, idx] = min(pbest_costo);
    gbest = pbest(idx, :);

    hist_valor = zeros(params.n_iteraciones + 1, 1);
    hist_solucion = zeros(params.n_iteraciones + 1, problema.dim);
    hist_poblacion = cell(params.n_iteraciones + 1, 1);
    motivo = 'max_iteraciones';
    sin_mejora = 0;

    for t = 0:params.n_iteraciones
        if t > 0
            V = actualizar_velocidad(V, X, pbest, gbest, params, vmax);
            [X, V] = mover_enjambre(X, V, lb, ub, problema.representacion);

            poblacion = decodificar(X, problema.representacion);
            costo_actual = evaluar_enjambre(poblacion, costo);
            evaluaciones = evaluaciones + params.n_particulas;

            [pbest, pbest_costo] = actualizar_mejores_personales( ...
                X, costo_actual, pbest, pbest_costo);

            costo_previo = gbest_costo;
            [gbest, gbest_costo] = actualizar_mejor_global( ...
                pbest, pbest_costo, gbest, gbest_costo);

            if gbest_costo < costo_previo
                sin_mejora = 0;
            else
                sin_mejora = sin_mejora + 1;
            end
        end

        mejor_solucion = decodificar(gbest, problema.representacion);
        hist_valor(t + 1) = signo * gbest_costo;
        hist_solucion(t + 1, :) = mejor_solucion;
        hist_poblacion{t + 1} = poblacion;

        if ~isempty(al_cada_iteracion)
            estado = struct('iteracion', t, 'n_iteraciones', params.n_iteraciones, ...
                'mejor_valor', signo * gbest_costo, 'mejor_solucion', mejor_solucion, ...
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
    info = info_pso();
    resultado.algoritmo = 'PSO';
    resultado.variante = info.variante;
    resultado.problema = problema;
    resultado.params = params;
    resultado.sentido = problema.sentido;
    resultado.mejor_solucion = mejor_solucion;
    resultado.mejor_valor = signo * gbest_costo;
    resultado.iteraciones = t;
    resultado.motivo_termino = motivo;
    resultado.evaluaciones = evaluaciones;
    resultado.tiempo = toc(t_inicio);
    resultado.historial.mejor_valor = hist_valor(1:n);
    resultado.historial.mejor_solucion = hist_solucion(1:n, :);
    resultado.historial.poblacion = hist_poblacion(1:n);
end

% -------------------------------------------------------------------------
function [lb, ub, vmax] = espacio_busqueda(problema, params)
% Limites del espacio donde se mueven las particulas y su velocidad maxima.
    switch problema.representacion
        case 'continuo'
            lb = problema.lb;
            ub = problema.ub;
            vmax = params.fraccion_vmax * (ub - lb);
        case 'binario'
            lb = zeros(1, problema.dim);
            ub = ones(1, problema.dim);
            vmax = params.vmax * ones(1, problema.dim);
        case 'permutacion'
            lb = zeros(1, problema.dim);
            ub = ones(1, problema.dim);
            vmax = params.fraccion_vmax * (ub - lb);
    end
end

function [X, V] = mover_enjambre(X, V, lb, ub, representacion)
    if strcmp(representacion, 'binario')
        X = actualizar_posicion_binaria(V);
    else
        [X, V] = actualizar_posicion(X, V, lb, ub);
    end
end

function soluciones = decodificar(X, representacion)
    if strcmp(representacion, 'permutacion')
        soluciones = decodificar_llaves(X);
    else
        soluciones = X;
    end
end
