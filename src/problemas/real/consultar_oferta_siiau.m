function paginas = consultar_oferta_siiau(ciclo, centro, carrera, opciones)
% CONSULTAR_OFERTA_SIIAU  Descarga la oferta academica de SIIAU (todas las paginas).
%
%   paginas = consultar_oferta_siiau('202620', 'D', 'INCO')
%   paginas = consultar_oferta_siiau('202620', 'D', 'INCO', solo_disponibles=true, ...
%                                    guardar_en=fullfile('datos', 'siiau'))
%
%   ciclo   : p. ej. '202620' (Calendario 26 B)
%   centro  : p. ej. 'D' (CUCEI)
%   carrera : clave de 4 letras de la carrera
%
%   solo_disponibles : true pide solo secciones con lugares (dispp = 'D')
%   materia          : clave de una sola materia ('' = todas)
%   por_pagina       : 100, 200 o 500 resultados por pagina
%   guardar_en       : carpeta donde guardar cada pagina como
%                      oferta_<ciclo>_<centro>_<carrera>_p<k>.html
%
%   Regresa una celda 1 x k con el HTML de cada pagina. Se sigue pidiendo mientras
%   la respuesta traiga el formulario de paginacion (p_start).

    arguments
        ciclo {mustBeTextScalar}
        centro {mustBeTextScalar}
        carrera {mustBeTextScalar}
        opciones.solo_disponibles (1,1) logical = false
        opciones.materia {mustBeTextScalar} = ''
        opciones.por_pagina (1,1) double {mustBeMember(opciones.por_pagina, [100 200 500])} = 500
        opciones.guardar_en {mustBeTextScalar} = ''
    end

    ciclo = char(ciclo);
    centro = char(centro);
    carrera = char(carrera);
    url = 'http://consulta.siiau.udg.mx/wco/sspseca.consulta_oferta';
    max_paginas = 50;   % tope de seguridad por si la paginacion no termina

    if opciones.solo_disponibles, disponibles = 'D'; else, disponibles = ''; end
    web = weboptions('CharacterEncoding', 'ISO-8859-1', 'Timeout', 30, ...
                     'ContentType', 'text');

    paginas = {};
    p_start = 0;
    while numel(paginas) < max_paginas
        campos = {'ciclop', ciclo, 'cup', centro, 'majrp', carrera, ...
            'crsep', char(opciones.materia), 'materiap', '', 'horaip', '', 'horafp', '', ...
            'lup', '', 'map', '', 'mip', '', 'jup', '', 'vip', '', 'sap', '', ...
            'edifp', '', 'aulap', '', 'dispp', disponibles, 'ordenp', '0', ...
            'mostrarp', num2str(opciones.por_pagina), 'p_start', num2str(p_start)};
        try
            html = webwrite(url, campos{:}, web);
        catch
            error('horario:siiau', ...
                  'No se pudo consultar SIIAU. Revisa tu conexión o usa la oferta guardada.');
        end
        html = char(html);
        if ~isempty(paginas) && strcmp(html, paginas{end})
            break;
        end
        paginas{end + 1} = html; %#ok<AGROW>

        hay_mas = ~isempty(regexp(html, 'NAME="p_start"', 'once', 'ignorecase'));
        if ~hay_mas
            break;
        end
        p_start = p_start + opciones.por_pagina;
    end

    if ~isempty(char(opciones.guardar_en))
        guardar_paginas(paginas, char(opciones.guardar_en), ciclo, centro, carrera);
    end
end

% -------------------------------------------------------------------------
function guardar_paginas(paginas, carpeta, ciclo, centro, carrera)
    if ~isfolder(carpeta)
        mkdir(carpeta);
    end
    for k = 1:numel(paginas)
        nombre = sprintf('oferta_%s_%s_%s_p%d.html', ciclo, centro, carrera, k);
        fid = fopen(fullfile(carpeta, nombre), 'w', 'n', 'ISO-8859-1');
        fprintf(fid, '%s', paginas{k});
        fclose(fid);
    end
end
