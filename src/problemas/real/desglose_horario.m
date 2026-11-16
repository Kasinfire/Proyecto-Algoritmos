function [f, desglose] = desglose_horario(x, datos)
% DESGLOSE_HORARIO  Costo de un horario y sus terminos (unica fuente de f).
%
%   f = desglose_horario(x, datos)
%   [f, desglose] = desglose_horario(x, datos)
%
%   x     : bits (1 x n o n x 1); x(i) = 1 si se toma la seccion i
%   datos : problema.datos armado por horario_materias
%
%   f(x) = peso_muertas * horas_muertas + fuera * horas_fuera
%        + dia_libre * dias_libres_usados + exceso * (materias_de_mas + horas_seguidas_de_mas)
%        + dura * (materias_sin_seccion + secciones_de_mas + choques + sin_lugares)
%
%   La usan horario_materias (para f) y decodificar_horario (para la interfaz),
%   asi que ambos dan exactamente el mismo valor.

    pref = datos.preferencias;
    pesos = datos.pesos;
    x = x(:) > 0.5;
    xd = double(x);

    % Restricciones duras
    por_materia = datos.matriz_materia * xd;
    materias_sin_seccion = sum(por_materia == 0);
    secciones_de_mas = sum(max(0, por_materia - 1));
    choques = (xd' * datos.choques * xd) / 2;
    sin_lugares = sum(x & datos.sin_lugares);

    % Preferencias, dia por dia
    horas_muertas = 0;
    horas_fuera = 0;
    dias_libres_usados = 0;
    materias_de_mas = 0;
    horas_seguidas_de_mas = 0;
    for d = 1:6
        dia = datos.dias(d);
        usa = x(dia.seccion);
        if ~any(usa)
            continue;
        end
        [inicio, orden] = sort(dia.inicio(usa));
        fin = dia.fin(usa);
        fin = fin(orden);
        materia = dia.materia(usa);

        if pref.dias_libres(d)
            dias_libres_usados = dias_libres_usados + 1;
        end
        horas_fuera = horas_fuera + sum(max(0, pref.hora_min * 60 - inicio) ...
                                      + max(0, fin - pref.hora_max * 60)) / 60;
        materias_de_mas = materias_de_mas ...
            + max(0, numel(unique(materia)) - pref.max_materias_dia);

        % Huecos entre clases (con traslapes el fin se acumula) y bloque mas largo
        fin_acum = cummax(fin);
        huecos = inicio(2:end) - fin_acum(1:end-1);
        horas_muertas = horas_muertas + sum(max(0, huecos)) / 60;
        corte = find(huecos > 0);
        inicio_bloque = [1; corte + 1];
        final_bloque = [corte; numel(inicio)];
        mas_largo = max(fin_acum(final_bloque) - inicio(inicio_bloque)) / 60;
        horas_seguidas_de_mas = horas_seguidas_de_mas ...
            + max(0, mas_largo - pref.max_horas_seguidas);
    end

    f = pref.peso_muertas * horas_muertas + pesos.fuera * horas_fuera ...
      + pesos.dia_libre * dias_libres_usados ...
      + pesos.exceso * (materias_de_mas + horas_seguidas_de_mas) ...
      + pesos.dura * (materias_sin_seccion + secciones_de_mas + choques + sin_lugares);

    if nargout > 1
        desglose = struct('f', f, 'horas_muertas', horas_muertas, ...
            'horas_fuera', horas_fuera, 'dias_libres_usados', dias_libres_usados, ...
            'materias_de_mas', materias_de_mas, ...
            'horas_seguidas_de_mas', horas_seguidas_de_mas, ...
            'materias_sin_seccion', materias_sin_seccion, ...
            'secciones_de_mas', secciones_de_mas, 'choques', choques, ...
            'sin_lugares', sin_lugares);
    end
end
