function params = armar_parametros(id, representacion, valores)
% ARMAR_PARAMETROS  Valida lo que el usuario configuro en la pantalla 3 y arma params.
%   params = armar_parametros('pso', 'continuo', struct('w', 0.8, 'n_particulas', 40))
%
%   id             : 'ga', 'aco', 'pso', 'ais' o 'de'
%   representacion : la del problema ('continuo', 'binario' o 'permutacion')
%   valores        : struct con un campo por parametro; los que falten toman su valor
%                    por defecto
%   params         : struct completo, listo para <id>(problema, params)
%   Lanza un error con mensaje legible si algun valor no es valido.

    defs = parametros_para_ui(feval(['parametros_' id], representacion));
    params = struct();
    for k = 1:numel(defs)
        d = defs(k);
        valor = d.valor;
        if isfield(valores, d.nombre)
            valor = valores.(d.nombre);
        end
        if isstring(valor), valor = char(valor); end
        mensaje = revisar(d, valor);
        if ~isempty(mensaje)
            error('armar_parametros:valor', '%s: %s', d.etiqueta, mensaje);
        end
        params.(d.nombre) = valor;
    end
end

function mensaje = revisar(d, valor)
    mensaje = '';
    switch d.tipo
        case 'opcion'
            if ~(ischar(valor) && any(strcmp({d.opciones.valor}, valor)))
                mensaje = sprintf('elige una de estas opciones: %s.', strjoin({d.opciones.texto}, ', '));
            end
        case 'entero'
            if ~(es_numero(valor) && valor == round(valor) && valor >= d.min && valor <= d.max)
                mensaje = sprintf('usa un entero entre %.15g y %.15g.', d.min, d.max);
            end
        case 'real'
            if ~(es_numero(valor) && valor >= d.min && valor <= d.max)
                mensaje = sprintf('usa un valor entre %.15g y %.15g.', d.min, d.max);
            end
    end
end

function si = es_numero(valor)
    si = isnumeric(valor) && isscalar(valor) && isfinite(valor);
end
