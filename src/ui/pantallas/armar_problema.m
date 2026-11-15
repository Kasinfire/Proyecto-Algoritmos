function problema = armar_problema(config)
% ARMAR_PROBLEMA  Crea el problema con lo que el usuario configuro en la pantalla 2.
%   problema = armar_problema(config)
%
%   config   : struct con id, dim, lb, ub y sentido ('min' o 'max')
%   problema : struct de crear_problema, listo para cualquier algoritmo.
%   Lanza un error con mensaje legible si la configuracion no es valida.

    limites = limites_problema(config.id);
    if ~(isscalar(config.dim) && config.dim == round(config.dim) ...
            && config.dim >= limites.dim_min && config.dim <= limites.dim_max)
        error('armar_problema:dim', '%s', texto_dim(limites));
    end
    if ~(isfinite(config.lb) && isfinite(config.ub) && config.lb < config.ub)
        error('armar_problema:limites', 'El límite inferior debe ser menor que el superior.');
    end
    if ~isfinite(config.ub - config.lb)
        error('armar_problema:limites', 'El rango es demasiado grande para representarlo.');
    end

    base = funcion_prueba(config.id, config.dim);
    lb = config.lb;
    ub = config.ub;

    % El optimo conocido solo sigue siendo el global si el rango nuevo cabe en el
    % original, lo contiene y el sentido no cambio.
    x_opt = base.x_optimo;
    conserva_optimo = ~isnan(base.f_optimo) && strcmp(config.sentido, base.sentido) ...
        && lb >= base.lb(1) && ub <= base.ub(1) && all(x_opt >= lb & x_opt <= ub);
    if conserva_optimo
        f_optimo = base.f_optimo;
        x_optimo = base.x_optimo;
    else
        f_optimo = NaN;
        x_optimo = [];
    end

    problema = crear_problema(base.nombre, base.f, lb, ub, config.dim, ...
        sentido=config.sentido, f_optimo=f_optimo, x_optimo=x_optimo, ...
        descripcion=base.descripcion);
end

function texto = texto_dim(limites)
    if limites.dim_min == limites.dim_max
        texto = sprintf('Este problema solo existe con dimensión %d.', limites.dim_min);
    else
        texto = sprintf('La dimensión debe ser un entero entre %d y %d.', ...
                        limites.dim_min, limites.dim_max);
    end
end
