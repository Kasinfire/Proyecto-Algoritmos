# AIS (CLONALG)

Implementacion CLONALG para `continuo`, `binario` y `permutacion`.

En cada iteracion selecciona los mejores anticuerpos, crea mas clones de los
rangos superiores y aplica hipermutacion con tasa creciente desde el mejor
hasta el peor seleccionado. Los clones compiten con la poblacion actual y se
reemplazan los peores por anticuerpos aleatorios para conservar diversidad.

La mutacion es gaussiana y limitada al rango en continuo, bit-flip en binario
y swap de dos posiciones en permutacion. La implementacion respeta el contrato
comun de semillas, min/max, historial y callback.

Los pasos estan separados por responsabilidad: `inicializar_anticuerpos_ais.m`,
`evolucionar_anticuerpos_ais.m`, `clonar_anticuerpos_ais.m`,
`mutar_anticuerpo_ais.m` y `reemplazar_anticuerpos_ais.m`.

Uso: `params = valores_por_defecto(parametros_ais('continuo'))` y
`resultado = ais(problema, params)`.
