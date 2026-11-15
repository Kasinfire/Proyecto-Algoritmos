function [secciones, info] = consultar_siiau(ciclo, centro, carrera, opciones)
% CONSULTAR_SIIAU  Descarga la oferta academica de la consulta publica de SIIAU (UdeG).
%   [secciones, info] = consultar_siiau('202620', 'D', 'INFO')
%   [secciones, info] = consultar_siiau(..., solo_cupo=true, al_leer_pagina=@(k, n) ...)
%
%   ciclo, centro, carrera : claves de SIIAU (ver opciones_siiau). carrera = '' trae
%                            todo el centro.
%   solo_cupo      : true para pedir solo las secciones con lugares disponibles
%   al_leer_pagina : se llama tras cada pagina con k (paginas leidas) y n (secciones
%                    acumuladas), para mostrar el avance
%
%   SIIAU entrega la oferta en paginas de 100 secciones con un boton "100 Proximos".
%   Se piden paginas (p_start = 0, 100, 200, ...) hasta la ultima, que es la que trae
%   "Total de registros". No basta con que falte el boton: con el filtro de lugares
%   disponibles SIIAU lo sigue poniendo aunque ya no haya secciones.
%   secciones e info tienen la forma de leer_oferta_siiau; ademas info.texto guarda el
%   HTML de todas las paginas, por si se quiere guardar como ejemplo.

    arguments
        ciclo {mustBeTextScalar}
        centro {mustBeTextScalar}
        carrera {mustBeTextScalar} = ''
        opciones.solo_cupo (1,1) logical = false
        opciones.al_leer_pagina function_handle = @(k, n) []
        opciones.por_pagina (1,1) double {mustBeMember(opciones.por_pagina, [100 200 500])} = 100
        opciones.max_paginas (1,1) double {mustBePositive} = 80
    end

    url = 'http://consulta.siiau.udg.mx/wco/sspseca.consulta_oferta';
    web_opciones = weboptions('Timeout', 40, 'CharacterEncoding', 'ISO-8859-1', 'ContentType', 'text');
    disponibles = '';
    if opciones.solo_cupo, disponibles = 'D'; end

    paginas = {};
    n_secciones = 0;
    for k = 1:opciones.max_paginas
        pagina = webwrite(url, ...
            'ciclop', ciclo, 'cup', centro, 'majrp', upper(carrera), 'majrdescp', '', ...
            'crsep', '', 'materiap', '', 'horaip', '', 'horafp', '', ...
            'lup', '', 'map', '', 'mip', '', 'jup', '', 'vip', '', 'sap', '', ...
            'edifp', '', 'aulap', '', 'dispp', disponibles, 'ordenp', '0', ...
            'mostrarp', num2str(opciones.por_pagina), ...
            'p_start', num2str((k - 1) * opciones.por_pagina), web_opciones);
        paginas{end + 1} = char(pagina); %#ok<AGROW>

        n_pagina = numel(leer_oferta_siiau(pagina));
        n_secciones = n_secciones + n_pagina;
        opciones.al_leer_pagina(k, n_secciones);
        if es_ultima(pagina, n_pagina), break; end
    end

    texto = strjoin(paginas, newline);
    [secciones, info] = leer_oferta_siiau(texto);
    info.ciclo = char(ciclo);
    info.centro = char(centro);
    info.carrera = upper(char(carrera));
    info.paginas = numel(paginas);
    info.por_pagina = opciones.por_pagina;
    info.texto = texto;
end

function ultima = es_ultima(pagina, n_secciones)
    ultima = n_secciones == 0 || ~isempty(regexpi(pagina, 'Total de registros', 'once')) ...
        || isempty(regexpi(pagina, 'name="?p_start', 'once'));
end
