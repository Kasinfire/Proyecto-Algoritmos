function [problema, config] = horario_de_ejemplo(claves)
% HORARIO_DE_EJEMPLO  Problema del horario con la oferta guardada de datos/siiau, para las demos.
%   [problema, config] = horario_de_ejemplo
%   [problema, config] = horario_de_ejemplo(["V0723" "V0718" "IL364"])
%
%   config tiene la misma forma que lo que regresa pantalla_horario (claves, preferencias,
%   secciones y materias). Si existe horario.m se usa para armar el problema; si no, f es
%   el desglose_horario de la solucion con las preferencias por defecto.

    if nargin < 1
        claves = ["V0723" "V0718" "IL364" "CB224" "V0726"];
    end
    raiz = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    oferta = leer_oferta_guardada(fullfile(raiz, 'datos', 'siiau', 'oferta_info_202620.html'));

    con_horario = arrayfun(@(s) ~isempty(s.sesiones), oferta);
    secciones = oferta(ismember(string({oferta.clave}), claves) & con_horario);
    preferencias = struct('entrada', 9, 'salida', 19, 'dias_libres', [false false false false true false], ...
        'peso_muertas', 1, 'max_materias_dia', 3, 'max_horas_seguidas', 4, 'solo_cupo', false);

    if exist('horario', 'file') == 2
        problema = horario(secciones, preferencias);
    else
        f = @(x) valor_de(desglose_horario(x, secciones, preferencias));
        problema = crear_problema('Horario de materias', f, 0, 1, numel(secciones), ...
            representacion='binario', sentido='min', sentido_fijo=true);
    end

    colores = {'#0072BD', '#D95319', '#7E2F8E', '#2B9FD0', '#A2142F'};
    materias = struct('clave', {}, 'nombre', {}, 'color', {});
    for k = 1:numel(claves)
        s = secciones(strcmp({secciones.clave}, claves(k)));
        if isempty(s), continue; end
        materias(end + 1) = struct('clave', char(claves(k)), 'nombre', s(1).materia, ...
            'color', colores{mod(k - 1, numel(colores)) + 1}); %#ok<AGROW>
    end
    config = struct('claves', claves, 'preferencias', preferencias, ...
        'secciones', secciones, 'materias', materias);
end

function f = valor_de(desglose)
    f = desglose.f;
end
