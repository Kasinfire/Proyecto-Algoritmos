function [x, y] = leer_ciudades_csv(archivo)
% LEER_CIUDADES_CSV  Lee las coordenadas de las ciudades de un TSP desde un CSV.
%   [x, y] = leer_ciudades_csv(archivo)
%
%   El CSV tiene una fila por ciudad. Si trae encabezado, las columnas se buscan por
%   nombre (x e y); si no, se usan las dos primeras:
%       x,y
%       12.5,40
%       71,8.25
%   x, y : vectores fila. El numero de ciudades lo valida armar_problema_permutacion.

    tabla = readtable(archivo, 'VariableNamingRule', 'preserve');
    if width(tabla) < 2 || height(tabla) == 0
        error('leer_ciudades_csv:formato', ...
              'El CSV debe tener al menos dos columnas (x e y) y una fila por ciudad.');
    end

    nombres = lower(strtrim(string(tabla.Properties.VariableNames)));
    col_x = find(nombres == "x", 1);
    col_y = find(nombres == "y", 1);
    if isempty(col_x) || isempty(col_y)
        col_x = 1;
        col_y = 2;
    end

    x = tabla{:, col_x};
    y = tabla{:, col_y};
    if ~isnumeric(x) || ~isnumeric(y)
        error('leer_ciudades_csv:numeros', 'Las columnas x e y deben tener solo números.');
    end

    vacias = isnan(x) & isnan(y);
    x = reshape(x(~vacias), 1, []);
    y = reshape(y(~vacias), 1, []);
    if any(~isfinite(x) | ~isfinite(y))
        error('leer_ciudades_csv:incompleta', 'Cada ciudad del CSV necesita su x y su y.');
    end
end
