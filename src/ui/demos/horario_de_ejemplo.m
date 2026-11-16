function [problema, config] = horario_de_ejemplo(claves)
% HORARIO_DE_EJEMPLO  Problema del horario con la oferta guardada de datos/siiau, para las demos.
%   [problema, config] = horario_de_ejemplo
%   [problema, config] = horario_de_ejemplo(["V0723" "V0718" "IL364"])
%
%   config tiene la misma forma que lo que regresa pantalla_horario (claves, preferencias,
%   secciones, materias y datos). El problema lo arma horario_materias.

    if nargin < 1
        claves = ["V0723" "V0718" "IL364" "CB224" "V0726"];
    end
    raiz = ruta_proyecto();
    oferta = leer_oferta_guardada(fullfile(raiz, 'datos', 'siiau', 'oferta_info_202620.html'));

    dias_libres = [false false false false true false];
    preferencias = struct('entrada', 9, 'salida', 19, 'dias_libres', dias_libres, ...
        'peso_muertas', 1, 'max_materias_dia', 3, 'max_horas_seguidas', 4, 'solo_cupo', false);
    problema = horario_materias(oferta, cellstr(claves), struct('hora_min', 9, 'hora_max', 19, ...
        'dias_libres', dias_libres, 'peso_muertas', 1, 'max_materias_dia', 3, ...
        'max_horas_seguidas', 4, 'solo_disponibles', false));
    secciones = secciones_para_ui(problema.datos.secciones);

    colores = {'#0072BD', '#D95319', '#7E2F8E', '#2B9FD0', '#A2142F'};
    materias = struct('clave', {}, 'nombre', {}, 'color', {});
    for k = 1:numel(problema.datos.materias)
        m = problema.datos.materias(k);
        materias(end + 1) = struct('clave', m.clave, 'nombre', m.nombre, ...
            'color', colores{mod(k - 1, numel(colores)) + 1}); %#ok<AGROW>
    end
    config = struct('claves', claves, 'preferencias', preferencias, ...
        'secciones', secciones, 'materias', materias, 'datos', problema.datos);
end
