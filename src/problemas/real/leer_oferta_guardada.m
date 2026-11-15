function [secciones, info] = leer_oferta_guardada(rutas)
% LEER_OFERTA_GUARDADA  Lee la oferta de SIIAU desde paginas guardadas en disco.
%   [secciones, info] = leer_oferta_guardada('datos/siiau/oferta_info_202620.html')
%   [secciones, info] = leer_oferta_guardada({'pagina1.html', 'pagina2.html'})
%
%   Sirve sin internet: cada archivo es una pagina de la consulta guardada con Ctrl+S,
%   o varias pegadas en un solo archivo. SIIAU manda ISO-8859-1, pero el navegador puede
%   guardarla en UTF-8; se prueba UTF-8 y, si no es valido, se lee como ISO-8859-1.
%   La forma de secciones e info es la de leer_oferta_siiau.

    rutas = cellstr(rutas);
    textos = cell(size(rutas));
    for k = 1:numel(rutas)
        textos{k} = leer_texto(rutas{k});
    end
    [secciones, info] = leer_oferta_siiau(strjoin(textos, newline));
    if isempty(secciones)
        error('leer_oferta_guardada:vacia', ...
              'El archivo no trae secciones de la consulta de oferta de SIIAU.');
    end
end

function texto = leer_texto(ruta)
    archivo = fopen(ruta, 'r');
    if archivo < 0
        error('leer_oferta_guardada:archivo', 'No se pudo abrir %s.', ruta);
    end
    bytes = fread(archivo, Inf, '*uint8')';
    fclose(archivo);
    texto = native2unicode(bytes, 'UTF-8');
    if any(texto == char(65533))
        texto = native2unicode(bytes, 'ISO-8859-1');
    end
end
