function params = parametros_bha(params)
% Establece los valores por defecto de los parametros
% del algoritmo y verifica que la configuracion sea valida.

if nargin < 1 || isempty(params)
    params = struct();
end

por_defecto = struct( ...
    'n_estrellas', 30, ...
    'max_iter', 200, ...
    'semilla', [], ...
    'mostrar_progreso', false, ...
    'cada_cuanto', 10);

params = completar_opciones(params, por_defecto);

if params.n_estrellas < 2 || params.n_estrellas ~= round(params.n_estrellas)
    error('parametros_bha:n_estrellas', ...
        'n_estrellas debe ser un entero mayor o igual a 2.');
end

if params.max_iter < 1 || params.max_iter ~= round(params.max_iter)
    error('parametros_bha:max_iter', ...
        'max_iter debe ser un entero positivo.');
end
end