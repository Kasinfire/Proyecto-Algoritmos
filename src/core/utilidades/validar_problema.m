function validar_problema(problema)
% Comprueba que la estructura del problema tenga los
% campos y valores necesarios para ejecutar el algoritmo.

requeridos = {'nombre', 'representacion', 'f', 'lb', 'ub', 'dim', 'sentido'};

for k = 1:numel(requeridos)
    if ~isfield(problema, requeridos{k})
        error('validar_problema:campo', ...
            'Al problema le falta el campo "%s". Usa crear_problema().', ...
            requeridos{k});
    end
end

if ~isa(problema.f, 'function_handle')
    error('validar_problema:f', 'problema.f debe ser un function handle.');
end

if ~any(strcmp(problema.sentido, {'min', 'max'}))
    error('validar_problema:sentido', 'problema.sentido debe ser ''min'' o ''max''.');
end

% En permutacion no hay limites: la solucion es un orden de 1..dim
if strcmp(problema.representacion, 'permutacion')
    return;
end

if numel(problema.lb) ~= problema.dim || numel(problema.ub) ~= problema.dim
    error('validar_problema:limites', ...
        'lb y ub deben tener dim = %d elementos.', problema.dim);
end

if any(problema.lb >= problema.ub)
    error('validar_problema:limites', 'Cada lb debe ser menor que su ub.');
end
end
