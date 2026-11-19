classdef test_binario < matlab.unittest.TestCase
% TEST_BINARIO  Pruebas de OneMax y la mochila.
%
%   Correr con: runtests('tests/test_binario.m')

    methods (TestClassSetup)
        function agregar_ruta(testCase)
            raiz = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(raiz, 'src'), 'IncludeSubfolders', true));
        end
    end

    methods (Test)
        function onemax_campos(testCase)
            p = onemax(12);
            testCase.verifyEqual(p.representacion, 'binario');
            testCase.verifyEqual(p.sentido, 'max');
            testCase.verifyTrue(p.sentido_fijo);
            testCase.verifyEqual(p.dim, 12);
            testCase.verifyEqual(p.f_optimo, 12);
            testCase.verifyEqual(p.x_optimo, ones(1, 12));
            testCase.verifyEqual(p.f([1 0 1 1 0 0 0 0 0 0 0 1]), 4);
            testCase.verifyEqual(p.f(p.x_optimo), p.f_optimo);
        end

        function mochila_campos(testCase)
            p = mochila([12 7 11 8 9 6], [4 2 6 5 6 3], 30);
            testCase.verifyEqual(p.representacion, 'binario');
            testCase.verifyEqual(p.sentido, 'max');
            testCase.verifyTrue(p.sentido_fijo);
            testCase.verifyEqual(p.dim, 6);
            testCase.verifyEqual(p.datos.capacidad, 30);
            testCase.verifyEqual(p.datos.pesos, [12 7 11 8 9 6]);
            testCase.verifyFalse(isempty(p.descripcion));
        end

        function mochila_factible_y_penalizada(testCase)
            p = mochila([12 7 11 8 9 6], [4 2 6 5 6 3], 30);
            testCase.verifyEqual(p.f([0 0 0 0 0 0]), 0);
            testCase.verifyEqual(p.f([1 0 1 0 0 0]), 10);     % peso 23
            testCase.verifyEqual(p.f([1 1 1 1 0 0]), -8);     % peso 38, exceso 8
            testCase.verifyLessThan(p.f([1 1 1 1 1 1]), 0);
        end

        function mochila_optimo_dinamico_coincide_con_fuerza_bruta(testCase)
            rng(3);
            for k = 1:5
                n = 10;
                w = randi(20, 1, n);
                v = randi(30, 1, n);
                cap = floor(sum(w) / 2);
                p = mochila(w, v, cap);
                X = double(bitget(uint32((0:2^n - 1)'), 1:n));
                tot = X * v';
                tot(X * w' > cap) = -Inf;
                testCase.verifyEqual(p.f_optimo, max(tot));
                testCase.verifyEqual(p.f(p.x_optimo), p.f_optimo);
                testCase.verifyLessThanOrEqual(sum(w .* p.x_optimo), cap);
            end
        end

        function mochila_pesos_no_enteros(testCase)
            p = mochila([1.5 2.5 3.5], [3 4 6], 5);
            testCase.verifyEqual(p.f_optimo, 9);              % objetos 1 y 3: peso 5
            testCase.verifyEqual(p.x_optimo, [1 0 1]);
        end

        function mochila_datos_invalidos(testCase)
            testCase.verifyError(@() mochila([1 2], [1 2 3], 5), 'mochila:objetos');
            testCase.verifyError(@() mochila([0 2], [1 2], 5), 'mochila:pesos');
            testCase.verifyError(@() mochila([1 2], [-1 2], 5), 'mochila:valores');
            testCase.verifyError(@() mochila([1 2], [1 2], 0), 'mochila:capacidad');
        end

        function pso_resuelve_onemax(testCase)
            p = onemax(20);
            r = pso(p, valores_por_defecto(parametros_pso('binario')));
            testCase.verifyGreaterThanOrEqual(r.mejor_valor, r.historial.mejor_valor(1));
            testCase.verifyEqual(r.mejor_valor, sum(r.mejor_solucion));
        end

        function pso_en_mochila_da_solucion_factible(testCase)
            p = mochila([12 7 11 8 9 6], [4 2 6 5 6 3], 30);
            r = pso(p, valores_por_defecto(parametros_pso('binario')));
            testCase.verifyGreaterThanOrEqual(r.mejor_valor, r.historial.mejor_valor(1));
            testCase.verifyGreaterThanOrEqual(r.mejor_valor, 0);      % factible
            testCase.verifyLessThanOrEqual(r.mejor_valor, p.f_optimo);
        end
    end
end