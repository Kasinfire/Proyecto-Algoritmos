function problema = onemax(n)
% ONEMAX  Problema binario OneMax: encender todos los bits.
%
%   problema = onemax(n)
%
%   n : numero de bits (entero >= 1).
%
%   f(x) = sum(x)  -> cuantos unos tiene la solucion. Se maximiza.
%   Optimo conocido: f = n en x = (1, ..., 1).

    arguments
        n (1,1) double {mustBeInteger, mustBePositive}
    end

    f = @(x) sum(x);

    descripcion = sprintf(['La solucion es una cadena de %d bits. f(x) es el numero de unos ' ...
        'de x; el optimo es la cadena con todos los bits en 1 (f = %d). No tiene restricciones.'], n, n);

    problema = crear_problema('OneMax', f, 0, 1, n, ...
        representacion = 'binario', ...
        sentido = 'max', ...
        sentido_fijo = true, ...
        f_optimo = n, ...
        x_optimo = ones(1, n), ...
        descripcion = descripcion);
end