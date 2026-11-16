function oferta = leer_oferta_guardada(rutas)
% LEER_OFERTA_GUARDADA  Lee la oferta de SIIAU desde paginas guardadas con el navegador.
%   oferta = leer_oferta_guardada('datos/siiau/oferta_info_202620.html')
%   oferta = leer_oferta_guardada({'pagina1.html', 'pagina2.html'})
%
%   SIIAU manda ISO-8859-1, pero el navegador puede guardar la pagina en UTF-8 con Ctrl+S;
%   se prueba UTF-8 y, si no es valido, se lee como ISO-8859-1. La forma de oferta es la
%   de leer_oferta_siiau.

    rutas = cellstr(rutas);
    textos = cellfun(@leer_texto, rutas, 'UniformOutput', false);
    oferta = leer_oferta_siiau(textos);
    if isempty(oferta.secciones) && isempty(oferta.ignoradas)
        error('horario:lector', ...
              'El archivo no trae secciones de la consulta de oferta de SIIAU.');
    end
end

function texto = leer_texto(ruta)
    archivo = fopen(ruta, 'r');
    if archivo < 0
        error('horario:lector', 'No se pudo abrir %s.', ruta);
    end
    bytes = fread(archivo, Inf, '*uint8')';
    fclose(archivo);
    texto = native2unicode(bytes, 'UTF-8');
    if any(texto == char(65533))
        texto = native2unicode(bytes, 'ISO-8859-1');
    end
end
