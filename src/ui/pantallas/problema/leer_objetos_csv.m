function [pesos, valores] = leer_objetos_csv(archivo)
% LEER_OBJETOS_CSV  Lee los objetos de una mochila desde un CSV.
%   [pesos, valores] = leer_objetos_csv(archivo)
%
%   El CSV tiene una fila por objeto. Si trae encabezado, las columnas se buscan por
%   nombre (peso/pesos y valor/valores); si no, se usan las dos primeras:
%       peso,valor
%       12,4
%       7,2
%   pesos, valores : vectores fila. Las celdas vacias llegan como NaN para que la
%                    pantalla las marque; la validacion final es de armar_problema_binario.

    tabla = readtable(archivo, 'VariableNamingRule', 'preserve');
    if width(tabla) < 2 || height(tabla) == 0
        error('leer_objetos_csv:formato', ...
              'El CSV debe tener al menos dos columnas (peso y valor) y una fila por objeto.');
    end

    nombres = lower(strtrim(string(tabla.Properties.VariableNames)));
    col_peso = find(ismember(nombres, ["peso", "pesos"]), 1);
    col_valor = find(ismember(nombres, ["valor", "valores"]), 1);
    if isempty(col_peso) || isempty(col_valor)
        col_peso = 1;
        col_valor = 2;
    end

    pesos = tabla{:, col_peso};
    valores = tabla{:, col_valor};
    if ~isnumeric(pesos) || ~isnumeric(valores)
        error('leer_objetos_csv:numeros', 'Las columnas de peso y valor deben tener solo números.');
    end

    vacias = isnan(pesos) & isnan(valores);
    pesos = reshape(pesos(~vacias), 1, []);
    valores = reshape(valores(~vacias), 1, []);
end
