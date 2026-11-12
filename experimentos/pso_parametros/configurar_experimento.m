function config = configurar_experimento()
%CONFIGURAR_EXPERIMENTO  Define los parámetros FIJOS del experimento.
%
%   config = CONFIGURAR_EXPERIMENTO() devuelve una estructura con los valores
%   que se mantienen constantes en todas las pruebas, para que la única
%   diferencia entre pruebas sean w, c1 y c2.
%
%   Campos de salida:
%       n_particulas       - Número de partículas del enjambre.
%       n_iteraciones      - Número de iteraciones por ejecución.
%       n_repeticiones     - Ejecuciones independientes por prueba (para
%                           obtener promedio y desviación estándar).
%       semilla_base       - Semilla inicial; la repetición r usa
%                           semilla_base + r en TODAS las pruebas.
%       fraccion_vmax      - Velocidad máxima como fracción del rango del
%                           dominio: vmax = fraccion_vmax * (ub - lb).
%       tolerancia        - Error máximo respecto al óptimo conocido para
%                           considerar que el algoritmo convergió.
%       carpeta_resultados - Carpeta donde se guardan gráficas y tablas.

    config.n_particulas       = 30;
    config.n_iteraciones      = 100;
    config.n_repeticiones     = 10;
    config.semilla_base       = 1;
    config.fraccion_vmax      = 0.2;
    config.tolerancia        = 1e-4;
    config.carpeta_resultados = 'resultados';
end
