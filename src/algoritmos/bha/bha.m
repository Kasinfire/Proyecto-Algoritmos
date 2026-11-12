function resultado = bha(problema, params)
% Black Hole Algorithm (Hatamlou, 2013) para minimizar f(x).
%
% Pasos por iteracion:
%   1. Mover:     x_i = x_i + r * (x_BH - x_i)
%   2. Limitar:   x_ij = min(max(x_ij, lb_j), ub_j)
%   3. Evaluar:   f_i = f(x_i)
%   4. Si alguna f_i < f_BH, esa estrella pasa a ser el agujero negro
%   5. Radio:     R = |f_BH| / sum |f_i|
%   6. Absorber:  si ||x_i - x_BH|| < R, x_i se reemplaza por una aleatoria
%
% x_i = estrellas(i,:),  f_i = fitness(i),  BH = idx_bh
%
% Uso: resultado = bha(problema, params)   (ver main_BHA.m)

if nargin < 1
    error('bha:entrada', ...
        'Falta el problema. Corre main_BHA.m en vez de este archivo.');
end
if nargin < 2
    params = struct();
end
params = parametros_bha(params);
validar_problema(problema);
if strcmp(problema.sentido, 'max')
    error('bha:sentido', 'Esta version del BHA solo minimiza.');
end

if ~isempty(params.semilla)
    rng(params.semilla);
end

n_e      = params.n_estrellas;
max_iter = params.max_iter;
dim     = problema.dim;

t_inicio = tic;

% Poblacion inicial
estrellas = inicializar_estrellas(n_e, problema.lb, problema.ub);
fitness = evaluar_estrellas(problema.f, estrellas);
evaluaciones = n_e;

[~, idx_bh] = min(fitness);

curva          = zeros(max_iter + 1, 1);
historial_bh    = zeros(max_iter + 1, dim);
historial_radio = zeros(max_iter + 1, 1);
absorciones    = zeros(max_iter + 1, 1);
historial_estrellas = zeros(n_e, dim, max_iter + 1);

curva(1)          = fitness(idx_bh);
historial_bh(1, :) = estrellas(idx_bh, :);
historial_radio(1) = radio_horizonte(fitness, idx_bh);
historial_estrellas(:, :, 1) = estrellas;

for iter = 1:max_iter

    % 1 y 2
    estrellas = mover_estrellas(estrellas, idx_bh);
    estrellas = limitar_a_rango(estrellas, problema.lb, problema.ub);

    % 3
    fitness = evaluar_estrellas(problema.f, estrellas);
    evaluaciones = evaluaciones + n_e;

    % 4
    [mejor_fit, idx_mejor] = min(fitness);
    if mejor_fit < fitness(idx_bh)
        idx_bh = idx_mejor;
    end

    % 5
    R = radio_horizonte(fitness, idx_bh);

    % 6
    [estrellas, fitness, n_absorbidas] = absorber_estrellas( ...
        estrellas, fitness, idx_bh, R, problema);
    evaluaciones = evaluaciones + n_absorbidas;

    curva(iter + 1)          = fitness(idx_bh);
    historial_bh(iter + 1, :) = estrellas(idx_bh, :);
    historial_radio(iter + 1) = R;
    absorciones(iter + 1)    = n_absorbidas;
    historial_estrellas(:, :, iter + 1) = estrellas;

    if params.mostrar_progreso && mod(iter, params.cada_cuanto) == 0
        fprintf('  iter %4d | mejor f = %.6e | R = %.3e | absorbidas = %d\n', ...
            iter, fitness(idx_bh), R, n_absorbidas);
    end
end

resultado = struct();
resultado.algoritmo        = 'BHA';
resultado.problema         = problema;
resultado.params           = params;
resultado.mejor_posicion    = estrellas(idx_bh, :);
resultado.mejor_fitness     = fitness(idx_bh);
resultado.curva            = curva;
resultado.historial_bh      = historial_bh;
resultado.historial_radio   = historial_radio;
resultado.absorciones      = absorciones;
resultado.historial_estrellas = historial_estrellas;
resultado.total_absorciones = sum(absorciones);
resultado.evaluaciones     = evaluaciones;
resultado.tiempo           = toc(t_inicio);
end
