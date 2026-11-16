function oferta = leer_oferta_siiau(paginas)
% LEER_OFERTA_SIIAU  Convierte el HTML de la oferta de SIIAU en un struct de secciones.
%
%   oferta = leer_oferta_siiau(paginas)
%   oferta = leer_oferta_siiau({'datos/siiau/oferta_202620_D_INCO_p1.html'})
%
%   paginas : celda con el HTML (char) de cada pagina, o con rutas a archivos .html
%             guardados (se leen como ISO-8859-1, igual que responde SIIAU). Tambien
%             acepta un solo texto con varias paginas pegadas.
%
%   oferta.ciclo, .centro, .carrera : se leen del HTML si estan, si no ''
%   oferta.paginas   : cuantas paginas de la consulta venian en el texto
%   oferta.secciones : struct 1 x n con nrc, clave, materia, seccion, profesor,
%                      creditos, cupo, disponibles y sesiones (dia 1..6 = L..S,
%                      inicio y fin en minutos desde las 00:00, edificio, aula)
%   oferta.materias  : struct 1 x m con clave, nombre y n_secciones (por nombre)
%   oferta.ignoradas : celda con los NRC sin horario (no entran al problema)
%
%   Un NRC repetido en varias paginas se cuenta una sola vez. Las clases terminan
%   a las :55, asi que fin = hora de fin + 5 min (0900-1055 dura 120 min).
%   Acepta el HTML original de SIIAU y el que guarda el navegador con Ctrl+S
%   (mayusculas o minusculas, atributos con o sin comillas).

    if ischar(paginas) || isstring(paginas)
        paginas = cellstr(paginas);
    end
    if ~iscell(paginas) || isempty(paginas)
        error('horario:lector', ...
              'Se esperaba una celda con el HTML (o las rutas) de las páginas de SIIAU.');
    end
    texto = strjoin(cellfun(@obtener_html, paginas, 'UniformOutput', false), newline);

    oferta = struct();
    oferta.ciclo = primer_valor(texto, 'del ciclo\s+(\w+)');
    if isempty(oferta.ciclo), oferta.ciclo = valor_oculto(texto, 'ciclop'); end
    oferta.centro = valor_oculto(texto, 'cup');
    oferta.carrera = valor_oculto(texto, 'majrp');
    oferta.paginas = max(1, numel(regexpi(texto, 'Consulta de Oferta Acad\S*\s+del ciclo')));

    [lista, ignoradas] = leer_secciones(texto);
    if isempty(lista)
        oferta.secciones = struct('nrc', {}, 'clave', {}, 'materia', {}, 'seccion', {}, ...
            'profesor', {}, 'creditos', {}, 'cupo', {}, 'disponibles', {}, 'sesiones', {});
    else
        oferta.secciones = [lista{:}];
    end
    oferta.materias = armar_materias(oferta.secciones);
    oferta.ignoradas = ignoradas;
end

% -------------------------------------------------------------------------
function html = obtener_html(item)
    item = char(item);
    if contains(item, '<')
        html = item;
    elseif isfile(item)
        html = fileread(item, 'Encoding', 'ISO-8859-1');
    else
        error('horario:lector', 'No se encontró el archivo "%s".', item);
    end
end

function [lista, ignoradas] = leer_secciones(texto)
% Una fila por NRC: siete celdas tddatos seguidas (NRC, clave, materia, seccion,
% CR, CUP y DIS). Lo que hay hasta la siguiente fila son sus sesiones y profesores.
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

    lista = {};
    ignoradas = {};
    vistos = containers.Map('KeyType', 'char', 'ValueType', 'logical');
    for k = 1:numel(inicios)
        if k < numel(inicios)
            bloque = texto(finales(k) + 1:inicios(k + 1) - 1);
        else
            bloque = texto(finales(k) + 1:end);
        end
        f = filas(k);
        if isKey(vistos, f.nrc)
            continue;
        end
        vistos(f.nrc) = true;

        sesiones = leer_sesiones(bloque);
        if isempty(sesiones)
            ignoradas{end + 1} = f.nrc; %#ok<AGROW>
            continue;
        end
        lista{end + 1} = struct('nrc', f.nrc, 'clave', upper(f.clave), ...
            'materia', limpiar(f.materia), 'seccion', upper(f.seccion), ...
            'profesor', leer_profesores(bloque), 'creditos', str2double(f.creditos), ...
            'cupo', str2double(f.cupo), 'disponibles', str2double(f.disponibles), ...
            'sesiones', sesiones); %#ok<AGROW>
    end
end

function sesiones = leer_sesiones(bloque)
% Cada fila de sesion: numero, hhmm-hhmm, dias, edificio, aula y periodo. Se crea
% una sesion por cada dia con clase (en los dias, '.' = no hay clase).
    celda = '\s*<td[^>]*>\s*';
    patron = [celda '\d+\s*</td>' celda '(\d{4})-(\d{4})\s*</td>' ...
              celda '([^<]*)</td>' celda '([^<]*)</td>' celda '([^<]*)</td>'];
    partes = regexpi(bloque, patron, 'tokens');
    lista = {};
    for k = 1:numel(partes)
        p = partes{k};
        dias = regexprep(limpiar(p{3}), '\s', '');
        if numel(dias) ~= 6
            continue;
        end
        inicio = a_minutos(p{1});
        fin = a_minutos(p{2}) + 5;
        for dia = find(dias ~= '.')
            lista{end + 1} = struct('dia', dia, 'inicio', inicio, 'fin', fin, ...
                'edificio', limpiar(p{4}), 'aula', limpiar(p{5})); %#ok<AGROW>
        end
    end
    if isempty(lista)
        sesiones = [];
    else
        sesiones = [lista{:}];
    end
end

function profesor = leer_profesores(bloque)
    nombres = regexpi(bloque, ['tdprofesor[^>]*>\s*\d+\s*</td>\s*' ...
                      '<td[^>]*tdprofesor[^>]*>([^<]*)</td>'], 'tokens');
    nombres = cellfun(@(c) limpiar(c{1}), nombres, 'UniformOutput', false);
    nombres = unique(nombres(~cellfun(@isempty, nombres)), 'stable');
    profesor = strjoin(nombres, ' / ');
end

function minutos = a_minutos(hhmm)
    valor = str2double(hhmm);
    minutos = floor(valor / 100) * 60 + mod(valor, 100);
end

function materias = armar_materias(secciones)
    materias = struct('clave', {}, 'nombre', {}, 'n_secciones', {});
    if isempty(secciones)
        return;
    end
    claves = {secciones.clave};
    [unicas, primera] = unique(claves, 'stable');
    nombres = {secciones(primera).materia};
    [~, orden] = sort(nombres);
    for i = orden
        materias(end + 1) = struct('clave', unicas{i}, 'nombre', nombres{i}, ...
            'n_secciones', sum(strcmp(claves, unicas{i}))); %#ok<AGROW>
    end
end

function valor = primer_valor(texto, patron)
    t = regexpi(texto, patron, 'tokens', 'once');
    if isempty(t), valor = ''; else, valor = upper(t{1}); end
end

function valor = valor_oculto(texto, nombre)
    valor = primer_valor(texto, ['name="?' nombre '"?\s+value="?([^">\s]*)']);
end

function texto = limpiar(texto)
% Quita etiquetas, decodifica entidades y normaliza espacios.
    texto = regexprep(texto, '<[^>]*>', '');
    texto = decodificar_entidades(texto);
    texto = strtrim(regexprep(texto, '\s+', ' '));
end

function texto = decodificar_entidades(texto)
    nombres = {'nbsp', 'Aacute', 'Eacute', 'Iacute', 'Oacute', 'Uacute', 'aacute', ...
               'eacute', 'iacute', 'oacute', 'uacute', 'Ntilde', 'ntilde', 'Uuml', ...
               'uuml', 'lt', 'gt', 'quot', 'apos', 'amp'};
    codigos = [32 193 201 205 211 218 225 233 237 243 250 209 241 220 252 60 62 34 39 38];
    for k = 1:numel(nombres)
        texto = strrep(texto, ['&' nombres{k} ';'], char(codigos(k)));
    end
    encontradas = regexp(texto, '&#(\d+);', 'tokens');
    numericas = unique(cellfun(@(c) c{1}, encontradas, 'UniformOutput', false));
    for k = 1:numel(numericas)
        texto = strrep(texto, ['&#' numericas{k} ';'], char(str2double(numericas{k})));
    end
end
