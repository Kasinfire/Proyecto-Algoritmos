function d = desglose_horario(x, secciones, preferencias)
% DESGLOSE_HORARIO  Cuenta cada castigo de la funcion objetivo del horario para una solucion.
%   d = desglose_horario(x, secciones, preferencias)
%
%   x            : vector 1 x n de 0 y 1; x(i) = 1 si se inscribe la seccion i
%   secciones    : struct 1 x n con el formato de leer_oferta_siiau (solo las que tienen horario)
%   preferencias : lo que manda la pantalla de Preferencias (ver LEEME.md); los campos
%                  que falten toman el valor por defecto
%
%   d : struct con
%       choques               pares de sesiones de secciones distintas que se enciman
%       horas_muertas         huecos entre clases del mismo dia, en horas
%       horas_fuera           horas de clase antes de la entrada o despues de la salida
%       dias_libres_ocupados  dias marcados como libres que tienen clase
%       materias_de_mas       materias por encima del maximo por dia, sumadas en la semana
%       horas_seguidas_de_mas horas por encima del maximo seguidas, sumadas en la semana
%       materias_sin_seccion  materias con cero o con mas de una seccion elegida
%       pesos                 peso de cada castigo (muertas, fuera, dia_libre, carga, choque)
%       f                     la suma con pesos, la misma que muestra la pantalla
%
%   SIIAU termina las clases a los :55; aqui se redondean a la hora para que dos clases
%   seguidas (7:00-8:55 y 9:00-10:55) no dejen 5 minutos muertos.

    p = con_valores_por_defecto(preferencias);
    x = logical(x(:)');
    n = numel(secciones);

    claves = {secciones.clave};
    [materias, ~, materia_de] = unique(claves, 'stable');
    cuenta = x;
    if p.solo_cupo
        cuenta = x & [secciones.disponibles] > 0;
    end
    por_materia = accumarray(materia_de(:), double(cuenta(:)), [numel(materias) 1]);
    d.materias_sin_seccion = sum(por_materia ~= 1);

    % Una fila por sesion y dia: [seccion, materia, dia, inicio, fin] en minutos.
    filas = zeros(0, 5);
    for i = find(x(1:n))
        for s = secciones(i).sesiones(:)'
            for dia = find(s.dias ~= '.' & s.dias ~= ' ')
                filas(end + 1, :) = [i, materia_de(i), dia, minutos(s.inicio), minutos(s.fin) + 5]; %#ok<AGROW>
            end
        end
    end

    d.choques = 0;
    d.horas_muertas = 0;
    d.horas_fuera = 0;
    d.dias_libres_ocupados = 0;
    d.materias_de_mas = 0;
    d.horas_seguidas_de_mas = 0;

    entrada = p.entrada * 60;
    salida = p.salida * 60;
    for dia = 1:6
        del_dia = sortrows(filas(filas(:, 3) == dia, :), [4 5]);
        if isempty(del_dia), continue; end
        ini = del_dia(:, 4);
        fin = del_dia(:, 5);

        enciman = ini < fin' & ini' < fin & del_dia(:, 1) ~= del_dia(:, 1)';
        d.choques = d.choques + nnz(triu(enciman, 1));

        d.horas_fuera = d.horas_fuera + sum(max(0, min(fin, entrada) - ini) ...
            + max(0, fin - max(ini, salida))) / 60;

        if p.dias_libres(dia)
            d.dias_libres_ocupados = d.dias_libres_ocupados + 1;
        end
        d.materias_de_mas = d.materias_de_mas ...
            + max(0, numel(unique(del_dia(:, 2))) - p.max_materias_dia);

        % Se juntan las sesiones que se tocan en bloques seguidos.
        bloques = [ini(1) fin(1)];
        for k = 2:numel(ini)
            if ini(k) <= bloques(end, 2)
                bloques(end, 2) = max(bloques(end, 2), fin(k));
            else
                bloques(end + 1, :) = [ini(k) fin(k)]; %#ok<AGROW>
            end
        end
        d.horas_muertas = d.horas_muertas + sum(bloques(2:end, 1) - bloques(1:end - 1, 2)) / 60;
        largo = (bloques(:, 2) - bloques(:, 1)) / 60;
        d.horas_seguidas_de_mas = d.horas_seguidas_de_mas + sum(max(0, largo - p.max_horas_seguidas));
    end

    d.pesos = struct('muertas', p.peso_muertas, 'fuera', 2, 'dia_libre', 5, 'carga', 10, 'choque', 100);
    d.f = d.pesos.muertas * d.horas_muertas + d.pesos.fuera * d.horas_fuera ...
        + d.pesos.dia_libre * d.dias_libres_ocupados ...
        + d.pesos.carga * (d.materias_de_mas + d.horas_seguidas_de_mas) ...
        + d.pesos.choque * (d.choques + d.materias_sin_seccion);
end

function m = minutos(hhmm)
    m = floor(hhmm / 100) * 60 + mod(hhmm, 100);
end

function p = con_valores_por_defecto(preferencias)
    p = struct('entrada', 9, 'salida', 19, 'dias_libres', false(1, 6), 'peso_muertas', 1, ...
        'max_materias_dia', 3, 'max_horas_seguidas', 4, 'solo_cupo', true);
    if isempty(preferencias), return; end
    for campo = fieldnames(p)'
        if isfield(preferencias, campo{1})
            p.(campo{1}) = preferencias.(campo{1});
        end
    end
    p.dias_libres = logical(p.dias_libres(:)');
    p.solo_cupo = logical(p.solo_cupo);
end
