# ACO (Colonia de Hormigas)

Implementacion elitista de Ant System disponible para representaciones `binario` y
`permutacion`. Para continuo, la interfaz debe consultar `info_aco()` y no
ofrecer la combinacion.

- Binario: cada componente de la feromona es la probabilidad de que una hormiga
  active ese bit. La mejor solucion global refuerza las probabilidades.
- Permutacion: las hormigas construyen una ruta sin repetir elementos. La
  feromona se mantiene por arista; si `problema.datos.distancias` tiene forma
  `dim x dim`, se usa su inverso como heuristica. Sin distancias, la heuristica
  es uniforme.
- La ejecucion minimiza internamente y devuelve valores en la escala original,
  con historial, callback, semilla y criterios de parada del contrato comun.

Los pasos estan separados por responsabilidad: `inicializar_aco.m`,
`construir_poblacion_aco.m`, `construir_ruta_aco.m`, `heuristica_aco.m`,
`seleccionar_ruleta_aco.m` y `actualizar_feromona_aco.m`.

Uso: `params = valores_por_defecto(parametros_aco('permutacion'))` y
`resultado = aco(problema, params)`. Para resolver TSP, `tsp(coordenadas)`
crea el problema y guarda la matriz de distancias que ACO puede reutilizar
como heuristica.
