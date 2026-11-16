function d = decodificar_horario(x, datos)
% DECODIFICAR_HORARIO  Traduce un vector de bits a las secciones elegidas.
%
%   d = decodificar_horario(x, datos)      % datos = problema.datos
%
%   d.elegidas : indices de las secciones con x = 1
%   d.choca    : logical 1 x numel(elegidas); true si esa seccion choca con otra elegida
%   d.desglose : terminos de f (f, horas_muertas, horas_fuera, dias_libres_usados,
%                materias_de_mas, horas_seguidas_de_mas, materias_sin_seccion,
%                secciones_de_mas, choques, sin_lugares); d.desglose.f == problema.f(x)
%   d.nrcs     : celda con los NRC elegidos, en el orden de datos.materias

    arguments
        x {mustBeNumericOrLogical}
        datos (1,1) struct
    end

    if numel(x) ~= numel(datos.secciones)
        error('horario:decodificar', ...
              'El vector tiene %d bits y el problema tiene %d secciones.', ...
              numel(x), numel(datos.secciones));
    end

    x = x(:)' > 0.5;
    d.elegidas = find(x);
    d.choca = any(datos.choques(d.elegidas, d.elegidas) > 0, 2)';
    [~, d.desglose] = desglose_horario(x, datos);

    d.nrcs = {};
    for m = 1:numel(datos.materias)
        propias = d.elegidas(datos.indice_materia(d.elegidas) == m);
        d.nrcs = [d.nrcs, {datos.secciones(propias).nrc}]; %#ok<AGROW>
    end
end
