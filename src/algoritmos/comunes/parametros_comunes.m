function defs = parametros_comunes()
% PARAMETROS_COMUNES  Parametros que comparten todos los algoritmos.
%
%   Cada parametros_<alg>.m debe incluirlos:  defs = [parametros_comunes(), ...]

    defs = [
        crear_parametro('n_iteraciones', 'Número de iteraciones', 'entero', 200, ...
            min=1, max=10000, descripcion='Iteraciones (o generaciones) máximas.')
        crear_parametro('semilla', 'Semilla aleatoria', 'entero', 42, ...
            min=0, max=2^31, descripcion='Misma semilla = misma ejecución (reproducible).')
        crear_parametro('paciencia', 'Paciencia', 'entero', 0, ...
            min=0, max=10000, descripcion=['Detener si el mejor valor no mejora en ' ...
            'este número de iteraciones. 0 = desactivado.'])
    ]';
end
