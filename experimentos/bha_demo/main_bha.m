%% BLACK HOLE ALGORITHM (BHA)
% Ejecuta el algoritmo BHA sobre una funcion de prueba y muestra
% los resultados obtenidos junto con su curva de convergencia.

clear; clc; close all;

% Raiz del proyecto = dos carpetas arriba de este script
carpeta_raiz = fileparts(fileparts(fileparts(mfilename('fullpath'))));
addpath(genpath(fullfile(carpeta_raiz, 'src')));

nombre_funcion = 'rastrigin';
dimension     = 2;

params = struct();
params.n_estrellas = 30;
params.max_iter = 200;
params.semilla = 2;
params.mostrar_progreso = true;
params.cada_cuanto = 20;

problema = funcion_prueba(nombre_funcion, dimension);

fprintf('BHA en %s (dim %d), %d estrellas, %d iteraciones\n\n', ...
    problema.nombre, problema.dim, params.n_estrellas, params.max_iter);

resultado = bha(problema, params);

fprintf('\nMejor fitness     : %.6e\n', resultado.mejor_fitness);
fprintf('Mejor posicion    : [%s]\n', num2str(resultado.mejor_posicion, '%.5f  '));
fprintf('Absorciones total : %d\n', resultado.total_absorciones);
fprintf('Evaluaciones      : %d\n', resultado.evaluaciones);
fprintf('Tiempo            : %.3f s\n', resultado.tiempo);

graficar_convergencia(resultado.curva, {'BHA'}, ...
    titulo=sprintf('Convergencia del BHA en %s (dim %d)', problema.nombre, problema.dim), ...
    f_optimo=problema.f_optimo);

if problema.dim == 2
    graficar_funcion(resultado);
    animar_bha(resultado);
end
