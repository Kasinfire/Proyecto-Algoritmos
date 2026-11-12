function problema = crear_problema(nombre, f, lb, ub, dim, opciones)
% CREAR_PROBLEMA  Arma el struct de un problema (continuo, binario o permutacion).
%
%   problema = crear_problema(nombre, f, lb, ub, dim)
%   problema = crear_problema(nombre, f, lb, ub, dim, sentido="max", f_optimo=5, x_optimo=0)
%   problema = crear_problema('Mochila', f, 0, 1, n, representacion='binario', ...
%                             sentido='max', sentido_fijo=true, datos=datos)
%
%   nombre         : texto para titulos y tablas
%   f              : function handle que recibe un vector fila (1 x dim) y regresa un escalar
%   lb, ub         : limites; escalares o vectores 1 x dim ([] en permutacion)
%   dim            : numero de variables (bits, ciudades, ...)
%   representacion : 'continuo' (por defecto), 'binario' o 'permutacion'
%   sentido        : 'min' (por defecto) o 'max'
%   sentido_fijo   : true si el problema define el sentido (TSP = min, mochila = max)
%   f_optimo       : valor optimo conocido (NaN si no se conoce)
%   x_optimo       : posicion del optimo conocido ([] si no se conoce)
%   datos          : struct con los datos propios del problema (pesos, coordenadas, ...)
%   descripcion    : que representa la solucion y como se calcula f

    arguments
        nombre
        f function_handle
        lb double
        ub double
        dim (1,1) double {mustBeInteger, mustBePositive}
        opciones.representacion {mustBeMember(opciones.representacion, ...
            {'continuo', 'binario', 'permutacion'})} = 'continuo'
        opciones.sentido {mustBeMember(opciones.sentido, {'min', 'max'})} = 'min'
        opciones.sentido_fijo (1,1) logical = false
        opciones.f_optimo (1,1) double = NaN
        opciones.x_optimo double = []
        opciones.datos struct = struct()
        opciones.descripcion = ''
    end

    if isscalar(lb), lb = repmat(lb, 1, dim); end
    if isscalar(ub), ub = repmat(ub, 1, dim); end

    x_optimo = opciones.x_optimo;
    if isscalar(x_optimo), x_optimo = repmat(x_optimo, 1, dim); end

    problema = struct();
    problema.nombre         = nombre;
    problema.representacion = char(opciones.representacion);
    problema.f              = f;
    problema.lb             = reshape(lb, 1, []);
    problema.ub             = reshape(ub, 1, []);
    problema.dim            = dim;
    problema.sentido        = char(opciones.sentido);
    problema.sentido_fijo   = opciones.sentido_fijo;
    problema.f_optimo       = opciones.f_optimo;
    problema.x_optimo       = reshape(x_optimo, 1, []);
    problema.datos          = opciones.datos;
    problema.descripcion    = opciones.descripcion;

    validar_problema(problema);
end
