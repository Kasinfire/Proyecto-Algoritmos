function algoritmos = algoritmos_para_horario(algoritmos)
% ALGORITMOS_PARA_HORARIO  Ajusta el catalogo de la pantalla 3 al problema del horario.
%   algoritmos = algoritmos_para_horario(algoritmos_de_tipo('binario'))
%
%   Cambia las notas y las ayudas de los parametros para hablar de horarios y secciones
%   en vez de bits e individuos, y deja los algoritmos no disponibles al final.

    notas = {
        'ga',  'cruza y mutación de bits'
        'pso', 'binario con sigmoide'
        'de',  'binario por umbral'
    };

    % {algoritmo ('*' = todos), parametro, etiqueta ('' = la misma), ayuda}
    textos = {
        '*',   'semilla',       '',             'La misma semilla da el mismo horario.'
        'ga',  'n_iteraciones', 'Generaciones', 'Cuántas veces se mejora la población.'
        'ga',  'tam_poblacion', 'Población',    'Horarios candidatos en cada generación.'
        'ga',  'tasa_cruza',    '',             'Qué tan seguido se mezclan dos horarios.'
        'ga',  'k_torneo',      '',             'Horarios que compiten para ser padres.'
        'ga',  'n_elite',       '',             'Mejores horarios que pasan intactos. 0 = sin élite.'
        'ga',  'tipo_cruza',    '',             'Cómo se combinan dos horarios.'
        'ga',  'tasa_mutacion', '',             'Por bit: tomar o soltar una sección al azar.'
        'pso', 'n_iteraciones', '',             'Cuántas veces se mueve el enjambre.'
        'pso', 'n_particulas',  '',             'Horarios candidatos que se mueven juntos.'
        'pso', 'vmax',          '',             'Con 4, ninguna sección queda fija del todo.'
        'de',  'n_iteraciones', '',             'Cuántas veces se mejora la población.'
        'de',  'tam_poblacion', '',             'Horarios candidatos en cada generación.'
        'de',  'tasa_cr',       '',             'Probabilidad de tomar cada sección del mutante.'
    };

    for k = 1:numel(algoritmos)
        a = algoritmos(k);
        if ~a.disponible, continue; end
        fila = strcmp(notas(:, 1), a.id);
        if any(fila), algoritmos(k).nota = notas{fila, 2}; end
        for j = 1:numel(a.parametros)
            p = a.parametros(j);
            fila = ismember(textos(:, 1), {'*', a.id}) & strcmp(textos(:, 2), p.nombre);
            if ~any(fila), continue; end
            fila = find(fila, 1, 'last');
            if ~isempty(textos{fila, 3}), p.etiqueta = textos{fila, 3}; end
            p.ayuda = textos{fila, 4};
            algoritmos(k).parametros(j) = p;
        end
    end

    [~, orden] = sort(~[algoritmos.disponible]);
    algoritmos = algoritmos(orden);
end
