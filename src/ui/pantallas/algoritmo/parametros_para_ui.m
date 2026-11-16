function ui = parametros_para_ui(defs)
% PARAMETROS_PARA_UI  Prepara las definiciones de crear_parametro para la pantalla 3.
%   ui = parametros_para_ui(parametros_pso('continuo'))
%
%   defs : arreglo de structs de crear_parametro (de parametros_<alg>.m)
%   ui   : struct 1 x n con nombre, etiqueta, ayuda, tipo, valor, min, max, opciones
%          ({valor, texto}) y solo_si ({nombre, valor} o vacio).
%
%   Los textos cortos y con acentos viven aqui para no tocar los archivos de cada
%   algoritmo; si un parametro nuevo no esta en la tabla se usan los de su definicion.
%   Los parametros comunes (iteraciones, semilla, paciencia) quedan al final.

    textos = {
        'n_iteraciones', 'Iteraciones',                'Cuántas veces se actualiza la población.'
        'paciencia',     'Paciencia',                  'Se detiene si no mejora en tantas iteraciones. 0 = nunca.'
        'semilla',       'Semilla',                    'Fija los números aleatorios.'
        'n_particulas',  'Número de partículas',       'Tamaño del enjambre.'
        'w',             'Inercia (w)',                'Cuánto conserva cada partícula su velocidad.'
        'c1',            'Coeficiente cognitivo (c₁)', 'Atracción a su propio mejor.'
        'c2',            'Coeficiente social (c₂)',    'Atracción al mejor del grupo.'
        'fraccion_vmax', 'Velocidad máxima',           'Fracción del rango de búsqueda.'
        'vmax',          'Velocidad máxima',           'Límite de la velocidad de cada bit.'
        'tam_poblacion', 'Tamaño de población',        'Individuos en cada generación.'
        'tasa_cruza',    'Tasa de cruza',              'Probabilidad de cruzar cada pareja.'
        'seleccion',     'Selección',                  'Cómo se eligen los padres.'
        'k_torneo',      'Tamaño del torneo (k)',      'Individuos que compiten en cada torneo.'
        'n_elite',       'Élite',                      'Mejores que pasan intactos. 0 = sin élite.'
        'tipo_cruza',    'Cruza',                      'Cómo se combinan dos padres.'
        'alpha_blx',     'Alfa de BLX (α)',            'Cuánto se amplía el intervalo de los padres.'
        'tasa_mutacion', 'Tasa de mutación',           'Probabilidad de mutar en cada hijo.'
        'sigma_ini',     'Sigma inicial (σ₀)',         'Paso de la mutación al inicio, fracción del rango.'
        'sigma_fin',     'Sigma final (σ₁)',           'Paso de la mutación en la última generación.'
        'tipo_mutacion', 'Mutación',                   'Cómo se altera una ruta.'
        'factor_f',      'Factor de mutación (F)',     'Escala la diferencia entre vectores.'
        'tasa_cr',       'Tasa de cruza (CR)',         'Probabilidad de tomar cada gen del mutante.'
        'estrategia',    'Estrategia',                 'De dónde parte el vector mutante.'
    };

    nombres_opcion = {
        'torneo', 'Torneo';  'ruleta', 'Ruleta'
        'blx', 'BLX-α';      'aritmetica', 'Aritmética'
        'un_punto', 'Un punto';  'uniforme', 'Uniforme'
        'swap', 'Intercambio';   'inversion', 'Inversión'
    };

    % Parametros que solo cuentan con cierta opcion elegida: {parametro, depende de, valor}.
    dependencias = {
        'k_torneo',  'seleccion',  'torneo'
        'alpha_blx', 'tipo_cruza', 'blx'
    };

    comunes = {'n_iteraciones', 'paciencia', 'semilla'};
    nombres = {defs.nombre};
    [~, orden] = sort(ismember(nombres, comunes));
    defs = defs(orden);

    ui = repmat(struct('nombre', '', 'etiqueta', '', 'ayuda', '', 'tipo', '', 'valor', [], ...
                       'min', [], 'max', [], 'opciones', [], 'solo_si', []), 1, numel(defs));
    for k = 1:numel(defs)
        d = defs(k);
        fila = strcmp(textos(:, 1), d.nombre);
        if any(fila)
            [etiqueta, ayuda] = textos{fila, 2:3};
        else
            [etiqueta, ayuda] = deal(d.etiqueta, d.descripcion);
        end
        ui(k) = struct('nombre', d.nombre, 'etiqueta', etiqueta, 'ayuda', ayuda, ...
            'tipo', d.tipo, 'valor', d.valor, 'min', d.min, 'max', d.max, ...
            'opciones', {opciones_con_texto(d.opciones, nombres_opcion)}, ...
            'solo_si', {dependencia(d.nombre, dependencias)});
    end
end

function opciones = opciones_con_texto(valores, nombres_opcion)
    opciones = struct('valor', {}, 'texto', {});
    for k = 1:numel(valores)
        fila = strcmp(nombres_opcion(:, 1), valores{k});
        texto = valores{k};
        if any(fila), texto = nombres_opcion{fila, 2}; end
        opciones(k) = struct('valor', valores{k}, 'texto', texto);
    end
end

function d = dependencia(nombre, dependencias)
    fila = strcmp(dependencias(:, 1), nombre);
    if any(fila)
        d = struct('nombre', dependencias{fila, 2}, 'valor', dependencias{fila, 3});
    else
        d = [];
    end
end
