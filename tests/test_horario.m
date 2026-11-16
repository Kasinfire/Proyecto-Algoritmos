classdef test_horario < matlab.unittest.TestCase
% TEST_HORARIO  Pruebas del problema de horario de materias.
%
%   Correr con: runtests('tests/test_horario.m')
%
%   Usa una pagina de SIIAU armada aqui mismo (misma estructura que la real), asi
%   que no necesita internet ni datos/siiau/.
%
%   Secciones de la pagina de ejemplo (orden de los bits con A1000, B2000, C3000):
%       1: 10001 A1000  L,I 0900-1055         2: 10002 A1000  L,I 1100-1255
%       3: 20001 B2000  L,I 1100-1255         4: 20002 B2000  M,J 1500-1655 (0 lugares)
%       5: 30001 C3000  M 1600-1655 y V 0900-0955
%   Ademas: 40001 sin horario (ignorada) y 50001 D4000 (sabado).

    methods (TestClassSetup)
        function agregar_ruta(testCase)
            raiz = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(raiz, 'src'), 'IncludeSubfolders', true));
        end
    end

    methods (Test)
        % ---------------- Lector ----------------
        function lector_lee_campos(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            testCase.verifyEqual(oferta.ciclo, '202620');
            testCase.verifyEqual(numel(oferta.secciones), 6);
            testCase.verifyEqual(oferta.ignoradas, {'40001'});

            s = oferta.secciones(1);
            testCase.verifyEqual(s.nrc, '10001');
            testCase.verifyEqual(s.clave, 'A1000');
            testCase.verifyEqual(s.materia, 'ALGORITMIA');
            testCase.verifyEqual(s.seccion, 'D01');
            testCase.verifyEqual(s.creditos, 8);
            testCase.verifyEqual(s.cupo, 35);
            testCase.verifyEqual(s.disponibles, 20);
            testCase.verifyEqual(s.profesor, 'GARCIA PEREZ, ANA');
        end

        function lector_convierte_dias_y_horas(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            ses = oferta.secciones(4).sesiones;            % 20002: M,J 1500-1655
            testCase.verifyEqual([ses.dia], [2 4]);
            testCase.verifyEqual([ses.inicio], [900 900]);
            testCase.verifyEqual([ses.fin], [1020 1020]);
        end

        function lector_junta_sesiones_del_mismo_nrc(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            ses = oferta.secciones(5).sesiones;            % 30001: M 1600-1655 y V 0900-0955
            testCase.verifyEqual(numel(ses), 2);
            testCase.verifyEqual([ses.dia], [2 5]);
            testCase.verifyEqual(ses(2).inicio, 540);      % 0900
            testCase.verifyEqual(ses(2).fin, 600);         % 0955 + 5 min
            testCase.verifyEqual(ses(2).edificio, '');
        end

        function lector_decodifica_entidades_y_ordena_materias(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            nombres = {oferta.materias.nombre};
            testCase.verifyTrue(ismember(['DISE' char(209) 'O WEB'], nombres));
            testCase.verifyEqual(oferta.materias(1).clave, 'A1000');
            testCase.verifyEqual(oferta.materias(1).n_secciones, 2);
        end

        function lector_no_duplica_nrc_entre_paginas(testCase)
            html = test_horario.html_ejemplo();
            oferta = leer_oferta_siiau({html, html});
            testCase.verifyEqual(numel(oferta.secciones), 6);
        end

        % ---------------- horario_materias ----------------
        function falla_con_clave_inexistente(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            testCase.verifyError(@() horario_materias(oferta, {'X9999'}), 'horario:clave');
        end

        function falla_con_horas_invertidas(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            pref = struct('hora_min', 20, 'hora_max', 8);
            testCase.verifyError(@() horario_materias(oferta, {'A1000'}, pref), 'horario:horas');
        end

        function falla_sin_materias(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            testCase.verifyError(@() horario_materias(oferta, {}), 'horario:claves');
        end

        function arma_el_problema_binario(testCase)
            p = test_horario.problema_ejemplo();
            testCase.verifyEqual(p.representacion, 'binario');
            testCase.verifyEqual(p.dim, 5);
            testCase.verifyEqual(p.sentido, 'min');
            testCase.verifyTrue(p.sentido_fijo);
            testCase.verifyEqual(p.datos.vista, 'horario');
            testCase.verifyEqual(numel(p.datos.secciones), 5);
        end

        % ---------------- Funcion objetivo ----------------
        function horario_factible_cuesta_cero(testCase)
            p = test_horario.problema_ejemplo();
            d = decodificar_horario([1 0 1 0 1], p.datos);
            testCase.verifyEqual(d.desglose.choques, 0);
            testCase.verifyEqual(p.f([1 0 1 0 1]), 0);
            testCase.verifyEqual(d.nrcs, {'10001', '20001', '30001'});
        end

        function horas_fuera_del_rango_cuestan_2_por_hora(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            p = horario_materias(oferta, {'A1000', 'B2000', 'C3000'}, struct('hora_min', 10));
            % Antes de las 10:00: lunes y miercoles 1 h cada uno y viernes 1 h
            d = decodificar_horario([1 0 1 0 1], p.datos);
            testCase.verifyEqual(d.desglose.horas_fuera, 3);
            testCase.verifyEqual(p.f([1 0 1 0 1]), 2 * 3);
        end

        function dos_secciones_que_se_encima_son_un_choque(testCase)
            p = test_horario.problema_ejemplo();
            d = decodificar_horario([0 1 1 0 1], p.datos);   % 10002 y 20001 en el mismo horario
            testCase.verifyEqual(d.desglose.choques, 1);
            testCase.verifyEqual(d.choca, [true true false]);
            testCase.verifyEqual(p.f([0 1 1 0 1]), p.datos.pesos.dura);
        end

        function clases_pegadas_no_chocan(testCase)
            p = test_horario.problema_ejemplo();
            % 10001 termina a las 11:00 y 20001 empieza a las 11:00
            testCase.verifyEqual(p.datos.choques(1, 3), 0);
        end

        function seccion_sin_lugares_se_castiga(testCase)
            p = test_horario.problema_ejemplo();
            d = decodificar_horario([1 0 0 1 1], p.datos);   % 20002 sin lugares y choca con 30001
            testCase.verifyEqual(d.desglose.sin_lugares, 1);
            testCase.verifyEqual(d.desglose.choques, 1);
            testCase.verifyEqual(p.f([1 0 0 1 1]), 2 * p.datos.pesos.dura);
        end

        function materia_faltante_y_repetida_se_castigan(testCase)
            p = test_horario.problema_ejemplo();
            d = decodificar_horario([1 1 0 0 0], p.datos);   % dos de A1000, nada de B2000 ni C3000
            testCase.verifyEqual(d.desglose.secciones_de_mas, 1);
            testCase.verifyEqual(d.desglose.materias_sin_seccion, 2);
        end

        function dia_libre_ocupado_cuesta_5(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            pref = struct('dias_libres', [0 0 0 0 1 0] == 1);
            p = horario_materias(oferta, {'A1000', 'B2000', 'C3000'}, pref);
            testCase.verifyEqual(p.f([1 0 1 0 1]), 5);       % 30001 tiene clase el viernes
        end

        function horario_compacto_no_tiene_penalizaciones(testCase)
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            p = horario_materias(oferta, {'A1000', 'B2000'}, struct('peso_muertas', 2));
            % 10001 (L,I 09:00-11:00) con 20001 (L,I 11:00-13:00): clases pegadas, sin huecos
            testCase.verifyEqual(p.f([1 0 1 0]), 0);
            % 10001 con 20002 (M,J 15:00-17:00): un dia por seccion, sin huecos
            testCase.verifyEqual(p.f([1 0 0 1]), 1000);      % 20002 sin lugares
        end

        function decodificar_coincide_con_f(testCase)
            p = test_horario.problema_ejemplo();
            rng(3);
            for k = 1:50
                x = double(rand(1, p.dim) > 0.5);
                d = decodificar_horario(x, p.datos);
                testCase.verifyEqual(d.desglose.f, p.f(x));
            end
        end

        function decodificar_valida_el_largo(testCase)
            p = test_horario.problema_ejemplo();
            testCase.verifyError(@() decodificar_horario([1 0 1], p.datos), 'horario:decodificar');
        end

        % ---------------- Algoritmos ----------------
        function ga_de_y_pso_encuentran_un_horario_factible(testCase)
            p = test_horario.problema_ejemplo();
            algoritmos = {@ga, @de, @pso};
            parametros = {@parametros_ga, @parametros_de, @parametros_pso};
            for a = 1:numel(algoritmos)
                for semilla = 1:3
                    params = valores_por_defecto(parametros{a}('binario'));
                    params.semilla = semilla;
                    params.n_iteraciones = 60;
                    r = algoritmos{a}(p, params, []);
                    d = decodificar_horario(r.mejor_solucion, p.datos);
                    testCase.verifyLessThanOrEqual(r.mejor_valor, r.historial.mejor_valor(1));
                    testCase.verifyEqual(d.desglose.choques, 0);
                    testCase.verifyEqual(d.desglose.materias_sin_seccion, 0);
                    testCase.verifyEqual(d.desglose.secciones_de_mas, 0);
                    testCase.verifyEqual(d.desglose.sin_lugares, 0);
                end
            end
        end
    end

    methods (Static, Access = private)
        function p = problema_ejemplo()
            oferta = leer_oferta_siiau({test_horario.html_ejemplo()});
            p = horario_materias(oferta, {'A1000', 'B2000', 'C3000'});
        end

        function html = html_ejemplo()
            filas = [ ...
                test_horario.fila('10001', 'A1000', 'ALGORITMIA', 'D01', 20, ...
                    {'0900-1055', 'L . I . . .', 'DEDX', 'A021'}), ...
                test_horario.fila('10002', 'A1000', 'ALGORITMIA', 'D02', 20, ...
                    {'1100-1255', 'L . I . . .', 'DEDX', 'A021'}), ...
                test_horario.fila('20001', 'B2000', 'BASES DE DATOS', 'D01', 10, ...
                    {'1100-1255', 'L . I . . .', 'DEDX', 'A022'}), ...
                test_horario.fila('20002', 'B2000', 'BASES DE DATOS', 'D02', 0, ...
                    {'1500-1655', '. M . J . .', 'DEDX', 'A022'}), ...
                test_horario.fila('30001', 'C3000', 'REDES', 'D01', 5, ...
                    {'1600-1655', '. M . . . .', 'DEDX', 'A023'; ...
                     '0900-0955', '. . . . V .', '', ''}), ...
                test_horario.fila('40001', 'V4000', 'VIRTUAL', 'D01', 5, cell(0, 4)), ...
                test_horario.fila('50001', 'D4000', 'DISE&Ntilde;O WEB', 'D01', 5, ...
                    {'1000-1155', '. . . . . S', 'DEDX', 'A024'})];
            html = ['<HTML><BODY><FORM><INPUT TYPE="hidden" NAME="ciclop" VALUE="202620">' ...
                '</FORM><TABLE><TR><TD class=tdtitulo>NRC</TD><TD class=tdtitulo>CLAVE</TD></TR>' ...
                filas '</TABLE></BODY></HTML>'];
        end

        function texto = fila(nrc, clave, materia, seccion, disponibles, sesiones)
            tabla = '';
            for i = 1:size(sesiones, 1)
                tabla = [tabla sprintf(['<TR><TD>01</TD><TD>%s</TD><TD>%s</TD><TD>%s</TD>' ...
                    '<TD>%s</TD><TD>17/08/26 - 11/12/26</TD></TR>'], sesiones{i, :})]; %#ok<AGROW>
            end
            texto = sprintf(['<TR style="background-color:#e5e5e5;">\n' ...
                '<TD class=tddatos>%s</TD>\n' ...
                '<TD class=tddatos><A HREF="x">%s</A></TD>\n' ...
                '<TD class=tddatos><A HREF="x">%s</A></TD>\n' ...
                '<TD class=tddatos>%s</TD>\n<TD class=tddatos>8</TD>\n' ...
                '<TD class=tddatos>35</TD>\n<TD class=tddatos>%d</TD>\n' ...
                '<TD align="center"><TABLE class="td1">%s</TABLE></td>\n' ...
                '<TD class=tddatos><TABLE><TR><TD class="tdprofesor">01</TD>' ...
                '<TD class="tdprofesor">GARCIA PEREZ, ANA</TD></TR></TABLE></TD>\n</TR>\n'], ...
                nrc, clave, materia, seccion, disponibles, tabla);
        end
    end
end
