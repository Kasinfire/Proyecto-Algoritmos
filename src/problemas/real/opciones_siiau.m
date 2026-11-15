function opciones = opciones_siiau(hoy)
% OPCIONES_SIIAU  Ciclos, centros y carreras para la consulta de oferta de SIIAU.
%   opciones = opciones_siiau()
%   opciones = opciones_siiau(hoy)     hoy : datetime (para probar con otra fecha)
%
%   opciones.ciclos   : struct id/nombre, del siguiente calendario hacia atras
%   opciones.centros  : struct id/nombre (claves de SIIAU, 'D' = CUCEI)
%   opciones.carreras : struct id/nombre de las carreras vigentes de CUCEI
%   opciones.defecto  : ciclo, centro, carrera y solo_cupo con que abre la pantalla
%
%   Los ciclos se calculan con la fecha para no depender de internet: el calendario A
%   (AAAA10) va de enero a junio y el B (AAAA20) de agosto a diciembre. El calendario
%   siguiente aparece en SIIAU antes de tener horarios, por eso abre en el actual.

    if nargin < 1, hoy = datetime('now'); end

    anio = year(hoy);
    if month(hoy) >= 7
        actual = [anio, 20];
    else
        actual = [anio, 10];
    end
    ciclos = repmat(struct('id', '', 'nombre', ''), 1, 5);
    ciclo = siguiente_de(actual);
    for k = 1:numel(ciclos)
        ciclos(k) = describir(ciclo);
        ciclo = anterior_de(ciclo);
    end

    centros = struct( ...
        'id',     {'D', 'C', 'A', 'B', 'E', 'F', 'Q', 'O'}, ...
        'nombre', {'CUCEI', 'CUCEA', 'CUAAD', 'CUCBA', 'CUCS', 'CUCSH', 'CUCEI Sede Norte', 'CUCEI Sede Valles'});

    carreras = struct( ...
        'id', {'INFO', 'ICOM', 'INRO', 'INBI', 'INCE', 'INME', 'INDU', 'ICIV', 'INQU', ...
               'IGFO', 'ITOG', 'ILOT', 'INEA', 'IMEI', 'ICIM', 'LIMA', 'LFIS', 'LIQU', 'LQFB', 'LIAB'}, ...
        'nombre', {'Ing. Informática', 'Ing. en Computación', 'Ing. Robótica', 'Ing. Biomédica', ...
                   'Ing. en Comunicaciones y Electrónica', 'Ing. Mecánica Eléctrica', 'Ing. Industrial', ...
                   'Ing. Civil', 'Ing. Química', 'Ing. Fotónica', 'Ing. en Topografía Geomática', ...
                   'Ing. en Logística y Transporte', 'Ing. en Electromovilidad y Autotrónica', ...
                   'Ing. en Mecatrónica Inteligente', 'Ing. en Ciencia de Materiales', ...
                   'Lic. en Matemáticas', 'Lic. en Física', 'Lic. en Química', ...
                   'Lic. en Químico Farmacéutico Biólogo', 'Lic. en Ing. en Alimentos y Biotecnología'});

    opciones = struct('ciclos', ciclos, 'centros', centros, 'carreras', carreras, ...
        'defecto', struct('ciclo', ciclos(2).id, 'centro', 'D', 'carrera', 'INFO', 'solo_cupo', false));
end

function c = siguiente_de(c)
    if c(2) == 10, c(2) = 20; else, c = [c(1) + 1, 10]; end
end

function c = anterior_de(c)
    if c(2) == 20, c(2) = 10; else, c = [c(1) - 1, 20]; end
end

function ciclo = describir(c)
    letra = 'A';
    if c(2) == 20, letra = 'B'; end
    ciclo = struct('id', sprintf('%d%d', c(1), c(2)), ...
                   'nombre', sprintf('Calendario %02d %s', mod(c(1), 100), letra));
end
