function ejecuciones = ejecutar_repeticiones(problema, prueba, config)
%EJECUTAR_REPETICIONES  Corre el PSO varias veces con semillas controladas.
%
%   ejecuciones = EJECUTAR_REPETICIONES(problema, prueba, config)
%
%   Como el PSO es estocástico, una sola corrida puede ser engañosa. Por
%   eso cada prueba se repite config.n_repeticiones veces. La repetición r
%   usa la semilla (semilla_base + r) en TODAS las pruebas, así cada prueba
%   parte de los mismos enjambres iniciales y la comparación es justa.
%
%   Entradas:
%       problema - Problema creado con funcion_prueba (ver definir_funciones).
%       prueba  - Parámetros w, c1, c2 (ver definir_pruebas).
%       config  - Configuración fija (ver configurar_experimento).
%
%   Salida:
%       ejecuciones - Arreglo de estructuras devueltas por pso().

    params = valores_por_defecto(parametros_pso('continuo'));
    params.n_particulas  = config.n_particulas;
    params.n_iteraciones = config.n_iteraciones;
    params.fraccion_vmax = config.fraccion_vmax;
    params.w  = prueba.w;
    params.c1 = prueba.c1;
    params.c2 = prueba.c2;

    for r = config.n_repeticiones:-1:1          % orden inverso: prealoca el arreglo
        params.semilla = config.semilla_base + r;
        ejecuciones(r) = pso(problema, params);
    end
end
