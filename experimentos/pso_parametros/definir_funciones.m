function problemas = definir_funciones()
% DEFINIR_FUNCIONES  Funciones objetivo asignadas al experimento (3, 4, 9, 11 y 15).
%
%   problemas = definir_funciones() devuelve un arreglo de problemas creados
%   con funcion_prueba; solo se les cambia el nombre para la tabla y las graficas.

    asignadas = {
        'F3 Lineal',      'lineal',      1
        'F4 Exponencial', 'exponencial', 1
        'F9 Schwefel',    'schwefel',    2
        'F11 Griewank',   'griewank',    2
        'F15 Zakharov',   'zakharov',    2
    };

    for k = size(asignadas, 1):-1:1
        problema = funcion_prueba(asignadas{k, 2}, asignadas{k, 3});
        problema.nombre = asignadas{k, 1};
        problemas(k) = problema;
    end
end
