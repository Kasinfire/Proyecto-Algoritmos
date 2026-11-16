function problema = armar_problema_binario(config)
% ARMAR_PROBLEMA_BINARIO  Crea el problema binario que el usuario configuro en la pantalla 2.
%   problema = armar_problema_binario(config)
%
%   config   : struct con id y los datos del problema
%              'onemax'  -> dim (numero de bits)
%              'mochila' -> pesos, valores y capacidad
%   problema : struct de crear_problema, listo para cualquier algoritmo.
%   Lanza un error con mensaje legible si la configuracion no es valida.
%
%   Las funciones de los problemas viven en src/problemas/binario/:
%       problema = onemax(n)
%       problema = mochila(pesos, valores, capacidad)

    if exist(config.id, 'file') ~= 2
        error('armar_problema_binario:falta', ...
              'Este problema todavía está en desarrollo: falta %s.m en src/problemas/binario.', ...
              config.id);
    end

    limites = limites_problema(config.id);
    switch config.id
        case 'onemax'
            n = config.dim;
            if ~(es_numero(n) && n == round(n) && n >= limites.dim_min && n <= limites.dim_max)
                error('armar_problema_binario:dim', ...
                      'El número de bits debe ser un entero entre %d y %d.', ...
                      limites.dim_min, limites.dim_max);
            end
            problema = onemax(n);

        case 'mochila'
            pesos = reshape(double(config.pesos), 1, []);
            valores = reshape(double(config.valores), 1, []);
            capacidad = config.capacidad;
            n = numel(pesos);
            if n ~= numel(valores) || n < limites.dim_min || n > limites.dim_max
                error('armar_problema_binario:objetos', ...
                      'La mochila debe tener entre %d y %d objetos, cada uno con peso y valor.', ...
                      limites.dim_min, limites.dim_max);
            end
            if any(~isfinite(pesos) | pesos <= 0)
                error('armar_problema_binario:pesos', 'Cada peso debe ser un número mayor que 0.');
            end
            if any(~isfinite(valores) | valores < 0)
                error('armar_problema_binario:valores', 'Cada valor debe ser un número mayor o igual que 0.');
            end
            if ~(es_numero(capacidad) && capacidad > 0)
                error('armar_problema_binario:capacidad', 'La capacidad debe ser un número mayor que 0.');
            end
            problema = mochila(pesos, valores, capacidad);

        otherwise
            error('armar_problema_binario:id', 'Problema binario desconocido: "%s".', config.id);
    end
end

function si = es_numero(x)
    si = isnumeric(x) && isscalar(x) && isfinite(x);
end
