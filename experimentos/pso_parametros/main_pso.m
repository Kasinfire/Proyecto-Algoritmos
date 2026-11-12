%% MAIN_PSO  Script principal del experimento con PSO.
%
%   Propósito:
%       Ejecuta el algoritmo de Optimización por Enjambre de Partículas (PSO)
%       sobre las problemas de prueba (3, 4, 9, 11 y 15) usando
%       distintas combinaciones de inercia (w), coeficiente cognitivo (c1) y
%       coeficiente social (c2)
%
%   Uso:
%       2. Ejecuta:  main_pso
%
%   Salidas (carpeta "resultados"):
%       - convergencia_<problema>.png  -> mejor valor vs iteración por prueba
%       - espacio_<problema>.png       -> función y posición final del enjambre
%       - tabla_resultados.csv        -> estadísticas de todas las pruebas
%
clear; clc; close all;

% Carpeta de este experimento y raiz del proyecto (dos niveles arriba)
raiz_proyecto = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(raiz_proyecto, '..', '..', 'src')), raiz_proyecto);

%% 1. Configuración del experimento
config     = configurar_experimento();     % parámetros fijos del algoritmo
pruebas    = definir_pruebas();            % combinaciones de w, c1, c2
problemas  = definir_funciones();          % funciones objetivo asignadas

config.carpeta_resultados = fullfile(raiz_proyecto, config.carpeta_resultados);
if ~exist(config.carpeta_resultados, 'dir')
    mkdir(config.carpeta_resultados);
end

n_funciones = numel(problemas);
n_pruebas   = numel(pruebas);

filas_tabla = cell(n_funciones * n_pruebas, 1);
fila = 0;

%% 2. Ciclo principal: cada función con cada combinación de parámetros
for i_f = 1:n_funciones
    problema = problemas(i_f);
    fprintf('\n=== Función: %s ===\n', problema.nombre);

    curvas_promedio   = cell(n_pruebas, 1);   % curva media de convergencia
    resultados_prueba = cell(n_pruebas, 1);   % ejecuciones de cada prueba

    for i_p = 1:n_pruebas
        prueba = pruebas(i_p);

        % Ejecuta varias repeticiones independientes de la misma prueba
        ejecuciones = ejecutar_repeticiones(problema, prueba, config);

        % Resume las repeticiones en estadísticas comparables
        estadisticas = calcular_estadisticas(ejecuciones, problema, config);

        curvas_promedio{i_p}   = estadisticas.curva_promedio;
        resultados_prueba{i_p} = ejecuciones;

        fila = fila + 1;
        filas_tabla{fila} = construir_fila_tabla(problema, prueba, estadisticas);

        imprimir_resumen(prueba, estadisticas);
    end

    %% 3. Gráficas de la función actual
    etiquetas = arrayfun(@(p) sprintf('%s: w=%.2f, c_1=%.2f, c_2=%.2f', ...
                         p.nombre, p.w, p.c1, p.c2), pruebas, 'UniformOutput', false);
    fig = graficar_convergencia(curvas_promedio, etiquetas, ...
        titulo=sprintf('Convergencia del PSO - %s (%d repeticiones)', ...
                       problema.nombre, config.n_repeticiones), ...
        sentido=problema.sentido, f_optimo=problema.f_optimo, ...
        etiqueta_y='Mejor valor encontrado (promedio)');
    guardar_figura(fig, ['convergencia_' problema.nombre], config);

    % El espacio de búsqueda se grafica con la primera repetición de cada
    % prueba para ver dónde terminó el enjambre en cada configuración.
    graficar_espacio_busqueda(problema, pruebas, resultados_prueba, config);
end

%% 4. Tabla comparativa final
tabla_resultados = vertcat(filas_tabla{:});
disp(tabla_resultados);
writetable(tabla_resultados, fullfile(config.carpeta_resultados, 'tabla_resultados.csv'));
fprintf('\nResultados guardados en la carpeta "%s".\n', config.carpeta_resultados);
