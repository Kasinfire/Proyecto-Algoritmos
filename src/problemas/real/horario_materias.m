function problema = horario_materias(oferta, claves, preferencias)
% HORARIO_MATERIAS  Problema binario: elegir una seccion por materia sin choques.
%
%   problema = horario_materias(oferta, claves)
%   problema = horario_materias(oferta, claves, preferencias)
%
%   oferta       : struct de leer_oferta_siiau
%   claves       : celda con las claves de las materias a tomar (1 a 8)
%   preferencias : struct; los campos que falten toman su valor por defecto
%       hora_min (7), hora_max (21), dias_libres (false(1,6), L..S),
%       peso_muertas (1, de 0 a 5), max_materias_dia (6), max_horas_seguidas (14),
%       solo_disponibles (true)
%
%   Solo entran las secciones de esas claves que tienen horario: dim = n secciones,
%   x(i) = 1 si se toma la seccion i. Ver desglose_horario para la funcion objetivo.

    arguments
        oferta (1,1) struct
        claves cell
        preferencias (1,1) struct = struct()
    end

    claves = unique(cellfun(@char, claves, 'UniformOutput', false), 'stable');
    if isempty(claves)
        error('horario:claves', 'Elige al menos una materia para armar el horario.');
    end
    if numel(claves) > 8
        error('horario:claves', ...
              'Elegiste %d materias y el máximo es 8. Quita %d para continuar.', ...
              numel(claves), numel(claves) - 8);
    end
    pref = completar_preferencias(preferencias);

    % Secciones de las materias elegidas, en el orden de los bits
    claves_oferta = {oferta.secciones.clave};
    indices = [];
    indice_materia = [];
    materias = struct('clave', {}, 'nombre', {}, 'n_secciones', {});
    for m = 1:numel(claves)
        pos = find(strcmp({oferta.materias.clave}, claves{m}), 1);
        if isempty(pos)
            error('horario:clave', ['La materia con clave "%s" no está en la oferta ' ...
                  'cargada. Revisa la clave o consulta de nuevo la oferta.'], claves{m});
        end
        propias = find(strcmp(claves_oferta, claves{m}));
        if isempty(propias)
            error('horario:sin_horario', ['La materia "%s" (%s) no tiene secciones con ' ...
                  'horario, así que no se puede incluir en el horario.'], ...
                  oferta.materias(pos).nombre, claves{m});
        end
        materias(end + 1) = oferta.materias(pos); %#ok<AGROW>
        indices = [indices, propias]; %#ok<AGROW>
        indice_materia = [indice_materia, repmat(m, 1, numel(propias))]; %#ok<AGROW>
    end
    secciones = oferta.secciones(indices);
    n = numel(secciones);

    datos = struct();
    datos.secciones = secciones;
    datos.materias = materias;
    datos.preferencias = pref;
    datos.vista = 'horario';
    datos.pesos = struct('fuera', 2, 'dia_libre', 5, 'exceso', 10, 'dura', 1000);
    datos.indice_materia = indice_materia;
    datos.matriz_materia = double(indice_materia == (1:numel(materias))');
    datos.sin_lugares = pref.solo_disponibles & ([secciones.disponibles]' == 0);
    datos.dias = sesiones_por_dia(secciones, indice_materia);
    datos.choques = matriz_choques(datos.dias, n);

    f = @(x) desglose_horario(x, datos);
    descripcion = ['x(i) = 1 si se toma la sección i de la oferta de SIIAU (se eligen ' ...
        'solo las materias pedidas). f = 0 es un horario perfecto según las ' ...
        'preferencias. Restricciones duras con penalización alta: una sección por ' ...
        'materia, sin choques y con lugares disponibles. Preferencias con pesos ' ...
        'menores: horas muertas, horario permitido, días libres, materias por día ' ...
        'y horas seguidas.'];

    problema = crear_problema('Horario de materias', f, 0, 1, n, ...
        representacion='binario', sentido='min', sentido_fijo=true, ...
        datos=datos, descripcion=descripcion);
end

% -------------------------------------------------------------------------
function pref = completar_preferencias(entrada)
    pref = struct('hora_min', 7, 'hora_max', 21, 'dias_libres', false(1, 6), ...
        'peso_muertas', 1, 'max_materias_dia', 6, 'max_horas_seguidas', 14, ...
        'solo_disponibles', true);
    for campo = fieldnames(entrada)'
        if ~isfield(pref, campo{1})
            error('horario:preferencia', ...
                  'La preferencia "%s" no existe. Las válidas son: %s.', ...
                  campo{1}, strjoin(fieldnames(pref)', ', '));
        end
        pref.(campo{1}) = entrada.(campo{1});
    end

    numericas = {'hora_min', 'hora_max', 'peso_muertas', 'max_materias_dia', 'max_horas_seguidas'};
    for campo = numericas
        valor = pref.(campo{1});
        if ~isnumeric(valor) || ~isscalar(valor) || ~isfinite(valor)
            error('horario:preferencia', 'La preferencia "%s" debe ser un número.', campo{1});
        end
    end
    if pref.hora_min < 0 || pref.hora_max > 24 || pref.hora_min >= pref.hora_max
        error('horario:horas', ['La hora mínima debe ser menor que la hora máxima ' ...
              'y estar entre 0 y 24 (por ejemplo 7 y 21).']);
    end
    if pref.peso_muertas < 0 || pref.peso_muertas > 5
        error('horario:preferencia', 'El peso de las horas muertas debe estar entre 0 y 5.');
    end
    if pref.max_materias_dia < 1 || pref.max_horas_seguidas <= 0
        error('horario:preferencia', ['El máximo de materias por día debe ser al menos 1 ' ...
              'y el de horas seguidas mayor que 0.']);
    end
    if numel(pref.dias_libres) ~= 6
        error('horario:preferencia', ['Los días libres deben ser 6 valores (L M I J V S), ' ...
              'por ejemplo [0 0 0 0 1 0] para el viernes.']);
    end
    pref.dias_libres = reshape(logical(pref.dias_libres), 1, 6);
    pref.solo_disponibles = logical(pref.solo_disponibles);
end

function dias = sesiones_por_dia(secciones, indice_materia)
% Todas las sesiones de cada dia (L..S) como columnas: seccion, materia, inicio, fin.
    dias = repmat(struct('seccion', zeros(0, 1), 'materia', zeros(0, 1), ...
        'inicio', zeros(0, 1), 'fin', zeros(0, 1)), 1, 6);
    for i = 1:numel(secciones)
        for s = secciones(i).sesiones
            d = s.dia;
            dias(d).seccion(end + 1, 1) = i;
            dias(d).materia(end + 1, 1) = indice_materia(i);
            dias(d).inicio(end + 1, 1) = s.inicio;
            dias(d).fin(end + 1, 1) = s.fin;
        end
    end
end

function choques = matriz_choques(dias, n)
% choques(i, j) = 1 si las secciones i y j tienen sesiones que se encimas el mismo dia.
    choques = zeros(n, n);
    for d = 1:6
        dia = dias(d);
        encima = dia.inicio < dia.fin' & dia.inicio' < dia.fin;
        distintas = dia.seccion ~= dia.seccion';
        [a, b] = find(encima & distintas);
        choques(sub2ind([n n], dia.seccion(a), dia.seccion(b))) = 1;
    end
end
