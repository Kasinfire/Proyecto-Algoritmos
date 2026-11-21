function problema = mochila(pesos, valores, capacidad)
% MOCHILA  Problema de la mochila 0/1 con pesos, valores y capacidad configurables.
%
%   problema = mochila(pesos, valores, capacidad)
%
%   pesos, valores : vectores fila 1 x n (peso > 0, valor >= 0)
%   capacidad      : escalar > 0
%
%   La solucion x es un vector de n bits: x(j) = 1 mete el objeto j en la mochila.
%   Se maximiza el valor total sin pasar la capacidad.
%
%   Restriccion (penalizacion, regla "factible siempre gana"):
%       peso   = sum(pesos .* x)
%       Si peso <= capacidad:   f(x) = sum(valores .* x)         (solucion factible, f >= 0)
%       Si peso >  capacidad:   f(x) = -(peso - capacidad)       (solucion no factible, f < 0)
%   Asi cualquier solucion factible vale mas que cualquier no factible, y entre las no
%   factibles gana la que menos se pasa, lo que empuja a los algoritmos hacia la zona
%   factible. La mochila vacia (todo ceros) siempre es factible y vale 0.
%
%   f_optimo y x_optimo se calculan al crear el problema: por programacion dinamica si
%   los pesos y la capacidad son enteros, por fuerza bruta si no y n <= 18; si no se
%   pueden calcular quedan en NaN y [].

    arguments
        pesos (1,:) double
        valores (1,:) double
        capacidad (1,1) double
    end

    n = numel(pesos);
    if n < 1 || numel(valores) ~= n
        error('mochila:objetos', 'pesos y valores deben tener el mismo numero de objetos (>= 1).');
    end
    if any(~isfinite(pesos) | pesos <= 0)
        error('mochila:pesos', 'Cada peso debe ser un numero mayor que 0.');
    end
    if any(~isfinite(valores) | valores < 0)
        error('mochila:valores', 'Cada valor debe ser un numero mayor o igual que 0.');
    end
    if ~isfinite(capacidad) || capacidad <= 0
        error('mochila:capacidad', 'La capacidad debe ser un numero mayor que 0.');
    end

    f = @(x) valor_penalizado(x, pesos, valores, capacidad);

    [f_optimo, x_optimo] = optimo_conocido(pesos, valores, capacidad);

    descripcion = sprintf(['La solucion es una cadena de %d bits: el bit j en 1 mete el objeto j ' ...
        'en la mochila. f(x) es el valor total de los objetos elegidos si su peso no pasa la ' ...
        'capacidad (%g). Si se pasa, f(x) = -(peso - capacidad): toda solucion factible vale ' ...
        'mas que cualquiera que se pase, y entre las que se pasan gana la que menos exceso ' ...
        'tiene (penalizacion).'], n, capacidad);

    problema = crear_problema('Mochila', f, 0, 1, n, ...
        representacion = 'binario', ...
        sentido = 'max', ...
        sentido_fijo = true, ...
        f_optimo = f_optimo, ...
        x_optimo = x_optimo, ...
        datos = struct('pesos', pesos, 'valores', valores, 'capacidad', capacidad), ...
        descripcion = descripcion);
end

function v = valor_penalizado(x, pesos, valores, capacidad)
    x = x(:)' > 0.5;
    peso = sum(pesos(x));
    if peso <= capacidad
        v = sum(valores(x));
    else
        v = -(peso - capacidad);
    end
end

function [f_opt, x_opt] = optimo_conocido(pesos, valores, capacidad)
    n = numel(pesos);
    f_opt = NaN;
    x_opt = [];
    enteros = all(pesos == round(pesos)) && capacidad == floor(capacidad);
    if enteros && n * capacidad <= 5e6
        [f_opt, x_opt] = optimo_dinamico(pesos, valores, capacidad);
    elseif n <= 18
        [f_opt, x_opt] = optimo_fuerza_bruta(pesos, valores, capacidad);
    end
end

function [f_opt, x_opt] = optimo_dinamico(pesos, valores, capacidad)
% Programacion dinamica 0/1: mejor(c + 1) = mejor valor con capacidad <= c.
    n = numel(pesos);
    mejor = zeros(1, capacidad + 1);
    tomar = false(n, capacidad + 1);
    for i = 1:n
        w = pesos(i);
        if w > capacidad, continue; end
        c = w:capacidad;
        candidato = mejor(c - w + 1) + valores(i);   % usa el mejor de la fila anterior
        gana = candidato > mejor(c + 1);
        tomar(i, c + 1) = gana;
        mejor(c + 1) = max(candidato, mejor(c + 1));
    end
    f_opt = mejor(capacidad + 1);
    x_opt = zeros(1, n);
    c = capacidad;
    for i = n:-1:1
        if tomar(i, c + 1)
            x_opt(i) = 1;
            c = c - pesos(i);
        end
    end
end

function [f_opt, x_opt] = optimo_fuerza_bruta(pesos, valores, capacidad)
    n = numel(pesos);
    X = double(bitget(repmat(uint32((0:2^n - 1)'), 1, n), repmat(1:n, 2^n, 1)));
    ok = X * pesos' <= capacidad;
    totales = X * valores';
    totales(~ok) = -Inf;
    [f_opt, i] = max(totales);
    x_opt = X(i, :);
end