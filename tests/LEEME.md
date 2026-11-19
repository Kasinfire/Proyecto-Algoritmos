## Cómo correrlas

Desde la raíz del proyecto, en MATLAB:

```matlab
runtests('tests')                      % todas
runtests('tests/test_binario.m')       % solo OneMax y mochila
runtests('tests/test_horario.m')       % solo el problema de horario
```

No necesitan internet ni configurar el path: cada archivo agrega `src/` con subcarpetas
mediante `PathFixture`.

## Qué se prueba

| Archivo | Qué revisa |
|---|---|
| `test_binario.m` | OneMax y mochila: campos del struct (`representacion`, `sentido`, `sentido_fijo`, `f_optimo`, `x_optimo`, `datos`), penalización de soluciones que se pasan de la capacidad, óptimo por programación dinámica contra fuerza bruta, datos inválidos y el PSO binario sobre ambos problemas. |
| `test_horario.m` | Lector de la oferta de SIIAU y el problema de horario de materias. |

## Criterios para las pruebas de algoritmos

Para cada algoritmo y cada representación que soporte, el resultado debe cumplir
(`docs/guia_desarrollo.md`, sección 4.3):

- Trae todos los campos de `resultado` (`algoritmo`, `variante`, `mejor_solucion`,
  `mejor_valor`, `iteraciones`, `motivo_termino`, `evaluaciones`, `tiempo`, `historial`).
- La solución es válida para la representación:
  - continuo: dentro de `[lb, ub]`;
  - binario: solo ceros y unos;
  - permutación: cada ciudad aparece una vez.
- `mejor_valor` coincide con `problema.f(mejor_solucion)`.
- `historial.mejor_valor` tiene `iteraciones + 1` filas y nunca empeora (según el sentido).
- El mejor valor final es igual o mejor que el de la iteración 0.
- Con la misma semilla, dos corridas dan el mismo resultado.

## Convenciones

- Un archivo `test_<tema>.m` por bloque, como `classdef` que hereda de `matlab.unittest.TestCase`.
- Usar corridas cortas (pocas iteraciones y partículas) y semilla fija para que las pruebas
  sean rápidas y reproducibles.
- Un nombre de prueba describe lo que se verifica (`mochila_factible_y_penalizada`).