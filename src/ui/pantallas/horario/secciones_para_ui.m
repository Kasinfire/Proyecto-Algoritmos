function lista = secciones_para_ui(secciones)
% SECCIONES_PARA_UI  Pasa las secciones de leer_oferta_siiau a la forma que dibujan las pantallas.
%   lista = secciones_para_ui(oferta.secciones)
%
%   leer_oferta_siiau da una sesion por dia (dia 1..6, inicio y fin en minutos, fin con los
%   5 minutos de las :55 ya sumados). Las pantallas usan una sesion por bloque de SIIAU:
%   inicio y fin en hhmm (700 y 855) y dias como texto de 6 caracteres ('L.I...').
%   Las sesiones del mismo horario y aula se juntan en una sola con todos sus dias.

    lista = secciones;
    for k = 1:numel(secciones)
        lista(k).sesiones = agrupar(secciones(k).sesiones);
    end
end

function grupos = agrupar(sesiones)
    grupos = struct('inicio', {}, 'fin', {}, 'dias', {}, 'edificio', {}, 'aula', {});
    letras = 'LMIJVS';
    for s = sesiones(:)'
        inicio = a_hhmm(s.inicio);
        fin = a_hhmm(s.fin - 5);
        k = find([grupos.inicio] == inicio & [grupos.fin] == fin ...
            & strcmp({grupos.edificio}, s.edificio) & strcmp({grupos.aula}, s.aula), 1);
        if isempty(k)
            grupos(end + 1) = struct('inicio', inicio, 'fin', fin, 'dias', '......', ...
                'edificio', s.edificio, 'aula', s.aula); %#ok<AGROW>
            k = numel(grupos);
        end
        grupos(k).dias(s.dia) = letras(s.dia);
    end
end

function hhmm = a_hhmm(minutos)
    hhmm = floor(minutos / 60) * 100 + mod(minutos, 60);
end
