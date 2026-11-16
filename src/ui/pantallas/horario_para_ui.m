function h = horario_para_ui(config, X)
% HORARIO_PARA_UI  Lo que necesitan las pantallas de ejecucion y resultados para dibujar horarios.
%   h = horario_para_ui(config, resultado.historial.mejor_solucion)   % ejecucion
%   h = horario_para_ui(config, resultado.mejor_solucion)             % resultados
%
%   config : lo que regreso la pantalla del horario (secciones, materias, preferencias y
%            datos, el problema.datos de horario_materias)
%   X      : una solucion por fila (vectores de bits en el orden de config.secciones)
%
%   h : struct con
%       materias     clave, nombre y color de cada materia
%       secciones    nrc, seccion, profesor, cupo, disponibles, sesiones y materia (indice
%                    desde 0 en materias)
%       preferencias entrada, salida y dias_libres (para rayar lo que se quiere evitar)
%       cambios      filas de X (desde 0) donde la solucion cambia; con el historial son
%                    las iteraciones donde cambio el mejor horario
%       soluciones   una por cambio: elegidas (indices desde 0), bits y el desglose de f
%                    (el de decodificar_horario, el mismo f que optimizan los algoritmos)

    COLORES = {'#0072BD', '#D95319', '#7E2F8E', '#2B9FD0', '#A2142F', '#4E8A22', '#B07A0C', '#4A4D57'};

    secciones = config.secciones;
    preferencias = struct();
    if isfield(config, 'preferencias'), preferencias = config.preferencias; end

    if isfield(config, 'materias') && ~isempty(config.materias)
        materias = config.materias;
    else
        [claves, k] = unique({secciones.clave}, 'stable');
        materias = struct('clave', claves, 'nombre', {secciones(k).materia}, 'color', '');
    end
    for k = 1:numel(materias)
        if isempty(materias(k).color)
            materias(k).color = COLORES{mod(k - 1, numel(COLORES)) + 1};
        end
    end

    [~, materia_de] = ismember({secciones.clave}, {materias.clave});
    lista = struct('nrc', {secciones.nrc}, 'seccion', {secciones.seccion}, ...
        'profesor', {secciones.profesor}, 'cupo', {secciones.cupo}, ...
        'disponibles', {secciones.disponibles}, 'materia', num2cell(materia_de - 1));
    for k = 1:numel(secciones)
        % En celda para que jsonencode mande siempre una lista, aunque sea una sesion.
        lista(k).sesiones = num2cell(secciones(k).sesiones);
    end

    X = logical(round(X));
    cambios = find([true; any(diff(X, 1, 1) ~= 0, 2)]);
    soluciones = cell(numel(cambios), 1);
    for k = 1:numel(cambios)
        x = X(cambios(k), :);
        d = decodificar_horario(x, config.datos).desglose;
        d.elegidas = find(x) - 1;
        d.bits = double(x);
        soluciones{k} = d;
    end

    h = struct( ...
        'materias', materias, ...
        'secciones', lista, ...
        'preferencias', preferencias_para_ui(preferencias), ...
        'cambios', {cambios - 1}, ...
        'soluciones', {soluciones});
end

function p = preferencias_para_ui(preferencias)
    p = struct('entrada', 9, 'salida', 19, 'dias_libres', {false(1, 6)});
    for campo = fieldnames(p)'
        if isfield(preferencias, campo{1}), p.(campo{1}) = preferencias.(campo{1}); end
    end
    p.dias_libres = logical(p.dias_libres(:)');
end
