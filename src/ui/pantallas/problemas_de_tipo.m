function problemas = problemas_de_tipo(tipo)
% PROBLEMAS_DE_TIPO  Catalogo de problemas de un tipo, para las pantallas 1 y 2.
%   problemas = problemas_de_tipo(tipo)
%
%   tipo      : 'continuo', 'binario' o 'permutacion'
%   problemas : struct 1 x n con id, nombre, formula, forma, descripcion, lb, ub, sentido,
%               dim_min, dim_max, dim_defecto, f_optimo, x_optimo y disponible.
%               f_optimo trae un valor por dimension (f_optimo(n), NaN si no se conoce);
%               x_optimo es el optimo con dim_defecto. disponible es false cuando la
%               funcion del problema todavia no existe en src/.

    switch tipo
        case 'continuo'
            problemas = continuos();
        case 'binario'
            problemas = pendientes({'onemax', 'OneMax', 'f(x) = Σ xᵢ'; ...
                                    'mochila', 'Mochila', 'f(x) = Σ vᵢxᵢ  con  Σ wᵢxᵢ ≤ C'});
        case 'permutacion'
            problemas = pendientes({'tsp', 'TSP', 'f(π) = Σ d(π₍ᵢ₎, π₍ᵢ₊₁₎)'});
        otherwise
            error('problemas_de_tipo:tipo', 'Tipo desconocido: "%s".', tipo);
    end
end

function problemas = continuos()
    ids = funcion_prueba('lista');
    problemas = repmat(entrada_vacia(), 1, numel(ids));
    for k = 1:numel(ids)
        limites = limites_problema(ids{k});
        p = funcion_prueba(ids{k}, limites.dim_defecto);
        [formula, forma, descripcion] = textos_continuos(ids{k});
        problemas(k).id = ids{k};
        problemas(k).nombre = p.nombre;
        problemas(k).formula = formula;
        problemas(k).forma = forma;
        problemas(k).descripcion = descripcion;
        problemas(k).lb = p.lb(1);
        problemas(k).ub = p.ub(1);
        problemas(k).sentido = p.sentido;
        problemas(k).dim_min = limites.dim_min;
        problemas(k).dim_max = limites.dim_max;
        problemas(k).dim_defecto = limites.dim_defecto;
        problemas(k).f_optimo = optimos_por_dim(ids{k}, limites);
        problemas(k).x_optimo = p.x_optimo;
        problemas(k).disponible = true;
    end
end

function f = optimos_por_dim(id, limites)
    f = nan(1, limites.dim_max);
    for n = limites.dim_min:limites.dim_max
        f(n) = funcion_prueba(id, n).f_optimo;
    end
end

function problemas = pendientes(catalogo)
% catalogo: celda n x 3 con {funcion, nombre visible, formula}.
    n = size(catalogo, 1);
    problemas = repmat(entrada_vacia(), 1, n);
    for k = 1:n
        problemas(k).id = catalogo{k, 1};
        problemas(k).nombre = catalogo{k, 2};
        problemas(k).formula = catalogo{k, 3};
        limites = limites_problema(catalogo{k, 1});
        problemas(k).dim_min = limites.dim_min;
        problemas(k).dim_max = limites.dim_max;
        problemas(k).dim_defecto = limites.dim_defecto;
        problemas(k).disponible = exist(catalogo{k, 1}, 'file') == 2;
    end
end

function e = entrada_vacia()
    e = struct('id', '', 'nombre', '', 'formula', '', 'forma', '', 'descripcion', '', ...
               'lb', NaN, 'ub', NaN, 'sentido', 'min', 'dim_min', 2, 'dim_max', 2, ...
               'dim_defecto', 2, 'f_optimo', NaN, 'x_optimo', NaN, ...
               'disponible', false);
end

function [formula, forma, descripcion] = textos_continuos(id)
% Solo para mostrar; las formulas que se evaluan viven en funcion_prueba.m.
    textos = {
        'parabolica',  'f(x) = 4 − Σ xᵢ²', 'unimodal', ...
            'Una colina con un solo pico en x = 0. La más fácil: sirve para empezar.'
        'seno',        'f(x) = Σ (sin 10πxᵢ + 1)', 'multimodal', ...
            'Muchas crestas seguidas. Todas llegan a la misma altura, así que hay varios máximos.'
        'lineal',      'f(x) = Σ (5 − 2xᵢ)', 'monótona', ...
            'Un plano inclinado. El máximo está en una orilla del rango, no adentro.'
        'exponencial', 'f(x) = e^(−Σ xᵢ²)', 'unimodal', ...
            'Una campana con un solo pico en el origen. Lejos del centro casi no tiene pendiente.'
        'coseno',      'f(x) = Σ (cos 5xᵢ + 2)', 'multimodal', ...
            'Varias ondas iguales dentro del rango. El algoritmo puede detenerse en cualquiera.'
        'esfera',      'f(x) = Σ xᵢ²', 'unimodal', ...
            'Un solo valle liso y simétrico. Sirve para comprobar que el algoritmo converge.'
        'rastrigin',   'f(x) = 10n + Σ (xᵢ² − 10 cos 2πxᵢ)', 'multimodal', ...
            'Una cuadrícula de muchos mínimos locales. El algoritmo puede quedarse atrapado en un hoyo que no es el mejor.'
        'himmelblau',  'f(x, y) = (x² + y − 11)² + (x + y² − 7)²', 'multimodal', ...
            'Cuatro mínimos globales igual de buenos. Sirve para ver cuál encuentra cada algoritmo.'
        'ackley',      'f(x) = −20 e^(−0.2 √(Σ xᵢ² / n)) − e^(Σ cos 2πxᵢ / n) + 20 + e', 'multimodal', ...
            'Casi plana por fuera, con un hoyo profundo al centro rodeado de pequeñas ondas.'
        'schwefel',    'f(x) = 418.9829n − Σ xᵢ sin √|xᵢ|', 'multimodal', ...
            'Engañosa: el mejor punto está lejos del segundo mejor, cerca de la orilla del rango.'
        'eggholder',   'f(x, y) = −(y + 47) sin √|x/2 + y + 47| − x sin √|x − (y + 47)|', 'multimodal', ...
            'Muy caótica, con valles y picos profundos. El mínimo está pegado a la orilla.'
        'griewank',    'f(x) = Σ xᵢ² / 4000 − Π cos(xᵢ / √i) + 1', 'multimodal', ...
            'Muchos mínimos locales muy parecidos entre sí, montados sobre una curva suave.'
        'rosenbrock',  'f(x) = Σ 100(xᵢ₊₁ − xᵢ²)² + (xᵢ − 1)²', 'unimodal', ...
            'Un valle largo y curvo. Llegar al valle es fácil; recorrerlo hasta el mínimo, no.'
        'michalewicz', 'f(x) = −Σ sin(xᵢ) sin(i xᵢ² / π)^20', 'multimodal', ...
            'Mesetas planas con zanjas angostas. Casi no hay pendiente que lleve al mínimo.'
        'levy',        'f(x) = sin²(πw₁) + Σ (wᵢ − 1)²(1 + 10 sin²(πwᵢ + 1)) + (wₙ − 1)²(1 + sin²(2πwₙ))', 'multimodal', ...
            'Una superficie irregular con varios valles. Usa wᵢ = 1 + (xᵢ − 1)/4.'
        'zakharov',    'f(x) = Σ xᵢ² + (Σ 0.5xᵢ)² + (Σ 0.5xᵢ)⁴', 'unimodal', ...
            'Un solo valle, sin mínimos locales, que se alarga al subir la dimensión.'
    };
    fila = strcmp(textos(:, 1), id);
    if ~any(fila)
        [formula, forma, descripcion] = deal('');
        return;
    end
    [formula, forma, descripcion] = textos{fila, 2:4};
end
