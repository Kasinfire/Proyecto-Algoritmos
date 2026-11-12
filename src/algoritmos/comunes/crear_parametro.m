function p = crear_parametro(nombre, etiqueta, tipo, valor, opciones)
% CREAR_PARAMETRO  Define un parametro configurable desde la interfaz.
%
%   p = crear_parametro('tam_poblacion', 'Tamano de poblacion', 'entero', 50, ...
%                       min=2, max=1000, descripcion='Numero de individuos.')
%   p = crear_parametro('seleccion', 'Metodo de seleccion', 'opcion', 'torneo', ...
%                       opciones={'torneo', 'ruleta'})
%
%   tipo: 'entero', 'real' u 'opcion'. La interfaz usa estos datos para
%   dibujar el control, mostrar la ayuda y validar el rango.

    arguments
        nombre
        etiqueta
        tipo {mustBeMember(tipo, {'entero', 'real', 'opcion'})}
        valor
        opciones.min (1,1) double = -Inf
        opciones.max (1,1) double = Inf
        opciones.opciones cell = {}
        opciones.descripcion = ''
    end

    p = struct('nombre', nombre, 'etiqueta', etiqueta, 'tipo', tipo, ...
               'valor', valor, 'min', opciones.min, 'max', opciones.max, ...
               'opciones', {opciones.opciones}, 'descripcion', opciones.descripcion);
end
