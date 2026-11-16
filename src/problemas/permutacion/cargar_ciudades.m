function coordenadas = cargar_ciudades(archivo)
% CARGAR_CIUDADES  Lee las columnas x e y de una instancia CSV.
%   coordenadas = cargar_ciudades(archivo)
%   El CSV puede incluir encabezado con columnas llamadas x e y.

    tabla = readtable(archivo, 'VariableNamingRule', 'preserve');
    if width(tabla) < 2 || height(tabla) == 0
        error('cargar_ciudades:formato', ...
            'El CSV debe tener al menos dos columnas y una fila de ciudades.');
    end

    nombres = lower(strtrim(string(tabla.Properties.VariableNames)));
    indice_x = find(nombres == "x", 1);
    indice_y = find(nombres == "y", 1);
    if isempty(indice_x) || isempty(indice_y)
        indice_x = 1;
        indice_y = 2;
    end
    x = tabla{:, indice_x};
    y = tabla{:, indice_y};
    if ~isnumeric(x) || ~isnumeric(y)
        error('cargar_ciudades:numeros', 'Las columnas de coordenadas deben ser numericas.');
    end
    coordenadas = [double(x(:)), double(y(:))];
    if isempty(coordenadas) || any(~isfinite(coordenadas), 'all')
        error('cargar_ciudades:coordenadas', ...
            'Cada ciudad debe tener coordenadas x e y finitas.');
    end
end
