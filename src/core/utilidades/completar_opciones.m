function opciones = completar_opciones(opciones, por_defecto)
% COMPLETAR_OPCIONES  Rellena los campos que falten con valores por defecto.
%
%   opciones = completar_opciones(opciones, por_defecto)
%
%   Funcion de apoyo para que las graficas acepten opciones parciales.

    campos = fieldnames(por_defecto);
    for k = 1:numel(campos)
        if ~isfield(opciones, campos{k})
            opciones.(campos{k}) = por_defecto.(campos{k});
        end
    end
end
