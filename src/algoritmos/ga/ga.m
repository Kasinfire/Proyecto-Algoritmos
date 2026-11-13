function resultado = ga(problema, params, al_cada_iteracion)
% GA  Algoritmo genetico generacional con elitismo.
%
%   resultado = ga(problema, params)
%   resultado = ga(problema, params, al_cada_iteracion)
%
%   Entradas y salida segun docs/guia_desarrollo.md, seccion 4.
%   Parametros: ver parametros_ga(representacion).
%
%   Pasos por generacion:
%       1. Seleccion de padres (torneo o ruleta).
%       2. Cruza por parejas con probabilidad tasa_cruza.
%       3. Mutacion de los hijos.
%       4. Evaluacion de los hijos.
%       5. Elitismo: los n_elite mejores padres reemplazan a los peores hijos.
%
%   Operadores por representacion:
%       continuo    : cruza BLX-alfa o aritmetica; mutacion gaussiana con sigma decreciente.
%       binario     : cruza de un punto o uniforme; mutacion bit-flip.
%       permutacion : cruza OX; mutacion swap o inversion.
%   Las soluciones se guardan directamente en la representacion del problema.

    if nargin < 3, al_cada_iteracion = []; end
    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);

    N = params.tam_poblacion;
    poblacion = inicializar_poblacion_ga(problema, N);
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
            sigma = calcular_sigma(problema, params, t);
            hijos = generar_hijos(poblacion, costos, params, problema, sigma);
            costos_hijos = evaluar_individuos(hijos, costo);
            evaluaciones = evaluaciones + N;

            [hijos, costos_hijos] = aplicar_elitismo( ...
                hijos, costos_hijos, poblacion, costos, params.n_elite);
            poblacion = hijos;
            costos = costos_hijos;

            % El mejor global se guarda aparte: con n_elite = 0 el mejor de
            % la poblacion actual podria empeorar.
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
    info = info_ga();
    resultado.algoritmo = 'GA';
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
