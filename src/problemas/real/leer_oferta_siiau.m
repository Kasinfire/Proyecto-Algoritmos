function [secciones, info] = leer_oferta_siiau(texto)
% LEER_OFERTA_SIIAU  Lee las secciones de una o varias paginas de la consulta de oferta de SIIAU.
%   [secciones, info] = leer_oferta_siiau(texto)
%
%   texto : HTML de la consulta (sspseca.consulta_oferta). Puede traer varias paginas
%           pegadas una tras otra; las secciones repetidas (mismo NRC) se cuentan una vez.
%
%   secciones : struct 1 x n con
%       nrc, clave, materia, seccion       texto, tal como vienen en SIIAU
%       creditos, cupo, disponibles        numeros (CR, CUP y DIS)
%       sesiones   struct 1 x s: inicio y fin (hhmm, por ejemplo 700 y 855), dias
%                  (6 caracteres L M I J V S, con '.' el dia que no hay clase),
%                  edificio y aula. Vacio si SIIAU no trae horario (virtual o por asignar).
%       profesor   nombres separados por ' / ', o '' si no hay
%   info : ciclo, centro y carrera de la consulta ('' si la pagina no lo dice) y
%          paginas (cuantas paginas de la consulta venian en el texto)
%
%   Acepta el HTML original de SIIAU y el que guarda el navegador con Ctrl+S
%   (mayusculas o minusculas, atributos con o sin comillas).

    texto = char(texto);
    td = '<td[^>]*tddatos[^>]*>\s*';
    fin_td = '\s*</td>\s*';
    enlace = '(?:<a[^>]*>)?\s*';
    fin_enlace = '\s*(?:</a>)?';
    patron = [td '(?<nrc>\d+)' fin_td ...
              td enlace '(?<clave>[^<\s]+)' fin_enlace fin_td ...
              td enlace '(?<materia>[^<]*?)' fin_enlace fin_td ...
              td '(?<seccion>[^<\s]+)' fin_td ...
              td '(?<creditos>\d+)' fin_td ...
              td '(?<cupo>\d+)' fin_td ...
              td '(?<disponibles>-?\d+)' fin_td];
    [filas, inicios, finales] = regexpi(texto, patron, 'names', 'start', 'end');

    secciones = repmat(seccion_vacia(), 1, numel(filas));
    for k = 1:numel(filas)
        if k < numel(filas)
            bloque = texto(finales(k) + 1:inicios(k + 1) - 1);
        else
            bloque = texto(finales(k) + 1:end);
        end
        f = filas(k);
        secciones(k) = struct( ...
            'nrc', f.nrc, 'clave', upper(f.clave), 'materia', limpiar(f.materia), ...
            'seccion', upper(f.seccion), 'creditos', str2double(f.creditos), ...
            'cupo', str2double(f.cupo), 'disponibles', str2double(f.disponibles), ...
            'sesiones', leer_sesiones(bloque), 'profesor', leer_profesores(bloque));
    end
    [~, unicas] = unique({secciones.nrc}, 'stable');
    secciones = secciones(unicas);

    info = struct( ...
        'ciclo', primer_valor(texto, 'del ciclo\s+(\w+)'), ...
        'centro', valor_oculto(texto, 'cup'), ...
        'carrera', valor_oculto(texto, 'majrp'), ...
        'paginas', numel(regexpi(texto, 'Consulta de Oferta Acad\S*\s+del ciclo')));
end

function s = seccion_vacia()
    s = struct('nrc', '', 'clave', '', 'materia', '', 'seccion', '', 'creditos', 0, ...
               'cupo', 0, 'disponibles', 0, 'sesiones', sesion_vacia(), 'profesor', '');
end

function s = sesion_vacia()
    s = struct('inicio', {}, 'fin', {}, 'dias', {}, 'edificio', {}, 'aula', {});
end

% Cada sesion es una fila: numero, hhmm-hhmm, dias, edificio, aula y periodo.
function sesiones = leer_sesiones(bloque)
    celda = '\s*<td[^>]*>\s*';
    patron = [celda '\d+\s*</td>' celda '(\d{4})-(\d{4})\s*</td>' ...
              celda '([^<]*)</td>' celda '([^<]*)</td>' celda '([^<]*)</td>'];
    partes = regexpi(bloque, patron, 'tokens');
    sesiones = sesion_vacia();
    for k = 1:numel(partes)
        p = partes{k};
        dias = regexprep(limpiar(p{3}), '\s', '');
        if numel(dias) ~= 6, continue; end
        sesiones(end + 1) = struct('inicio', str2double(p{1}), 'fin', str2double(p{2}), ...
            'dias', upper(dias), 'edificio', limpiar(p{4}), 'aula', limpiar(p{5})); %#ok<AGROW>
    end
end

function profesor = leer_profesores(bloque)
    nombres = regexpi(bloque, 'tdprofesor[^>]*>\s*\d+\s*</td>\s*<td[^>]*tdprofesor[^>]*>([^<]*)</td>', 'tokens');
    nombres = cellfun(@(c) limpiar(c{1}), nombres, 'UniformOutput', false);
    nombres = unique(nombres(~cellfun(@isempty, nombres)), 'stable');
    profesor = strjoin(nombres, ' / ');
end

function valor = primer_valor(texto, patron)
    t = regexpi(texto, patron, 'tokens', 'once');
    if isempty(t), valor = ''; else, valor = upper(t{1}); end
end

function valor = valor_oculto(texto, nombre)
    valor = primer_valor(texto, ['name="?' nombre '"?\s+value="?([^">\s]*)']);
end

function texto = limpiar(texto)
    entidades = {'&nbsp;', ' '; '&aacute;', 'á'; '&eacute;', 'é'; '&iacute;', 'í'; ...
                 '&oacute;', 'ó'; '&uacute;', 'ú'; '&ntilde;', 'ñ'; '&Ntilde;', 'Ñ'; '&amp;', '&'};
    for k = 1:size(entidades, 1)
        texto = strrep(texto, entidades{k, 1}, entidades{k, 2});
    end
    texto = strtrim(regexprep(texto, '\s+', ' '));
end
