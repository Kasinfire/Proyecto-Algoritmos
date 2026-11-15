function v = numeros_para_js(v)
% NUMEROS_PARA_JS  Redondea a 6 cifras y deja pasar Inf y NaN hacia el HTML.
%   v = numeros_para_js(historial.mejor_valor)
%
%   jsonencode convierte Inf y NaN en null. Si hay alguno, v se vuelve celda y esos
%   valores van como texto ('Infinity', '-Infinity', 'NaN'), que Number() de JS recupera.

    v = round(v, 6, 'significant');
    malos = ~isfinite(v);
    if ~any(malos(:)), return; end
    texto = cellstr(strrep(string(v(malos)), "Inf", "Infinity"));
    v = num2cell(v);
    v(malos) = texto;
end
