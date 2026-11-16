function oferta = oferta_ejemplo()
% OFERTA_EJEMPLO  Carga la oferta de SIIAU guardada en datos/siiau/ (sin internet).
%
%   oferta = oferta_ejemplo()
%
%   Lee todos los archivos oferta_*.html de datos/siiau/ en orden alfabetico con
%   leer_oferta_siiau. Es lo que usan la app sin internet, las pruebas y los
%   experimentos (resultados reproducibles).

    raiz = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    carpeta = fullfile(raiz, 'datos', 'siiau');
    archivos = dir(fullfile(carpeta, 'oferta_*.html'));
    if isempty(archivos)
        error('horario:sin_datos', ...
              ['No hay páginas guardadas en "%s". Descárgalas con ' ...
               'consultar_oferta_siiau(..., guardar_en=fullfile(''datos'', ''siiau'')).'], carpeta);
    end
    [~, orden] = sort({archivos.name});
    rutas = fullfile({archivos(orden).folder}, {archivos(orden).name});
    oferta = leer_oferta_siiau(rutas);
end
