# Problema de aplicación real (bonus +10): horario de materias

## 1. Situación

Cada semestre los alumnos de la Universidad de Guadalajara arman su horario a mano: eligen
una sección (NRC) por materia entre cientos de opciones, cuidando que no se encimen, que
queden pocas horas muertas y que respeten sus preferencias (no entrar muy temprano, tener
un día libre, no tener demasiadas materias en un día). Es un problema que todos resuelven en
cada inscripción y que crece rápido: 5 materias con 5 secciones cada una son 3 125
combinaciones, y como vector binario son 2^25 posibilidades.

## 2. Formulación

- **Variables:** `x ∈ {0,1}^n`, con `x(i) = 1` si se toma la sección `i`. Solo entran las
  secciones de las materias que el alumno pide y que tienen horario.
- **Función objetivo (minimizar):**
  `f = peso_muertas·horas_muertas + 2·horas_fuera + 5·días_libres_ocupados
  + 10·(materias_de_más + horas_seguidas_de_más) + 1000·(materias_sin_sección
  + secciones_de_más + choques + secciones_sin_lugares)`. `f = 0` es un horario perfecto
  según las preferencias. El cálculo vive en `desglose_horario.m` y lo usan tanto el
  problema como la interfaz.
- **Restricciones duras** (una sección por materia, sin choques, con lugares disponibles) se
  manejan con penalización dentro de `f`, igual que la mochila. El peso de 1000 es mayor que
  cualquier combinación razonable de las preferencias, para que un horario con choque nunca
  salga mejor que uno válido.
- **Restricciones blandas** son las preferencias, con pesos menores: horas muertas
  (configurable de 0 a 5), horas fuera de `[hora_min, hora_max]`, días libres, máximo de
  materias por día y máximo de horas seguidas.
- **Supuesto:** cada materia se cubre con **una** sección. Si alguna materia exige tomar
  dos NRC (teoría y práctica), habría que ampliar el modelo.

## 3. Datos

Oferta académica pública de SIIAU (Universidad de Guadalajara), consultada en
`http://consulta.siiau.udg.mx/wco/sspseca.forma_consulta`. Las páginas HTML usadas están en
`datos/siiau/`, junto con un LEEME que indica la fecha de descarga y los filtros (ciclo,
centro, carrera). `consultar_oferta_siiau` las descarga y `leer_oferta_siiau` las convierte
en secciones; `oferta_ejemplo` las carga sin internet, para que los resultados sean
reproducibles.

## 4. Representación y algoritmos

Binaria, porque cada sección se toma o no (misma familia que la mochila). GA, PSO y DE ya
soportan la representación binaria. Como las restricciones están en la penalización, cualquier
vector de bits se puede evaluar y los algoritmos no necesitan operadores de reparación. Una
alternativa sería un índice entero por materia (qué sección toma), pero el contrato del
proyecto solo maneja representaciones continua, binaria y permutación. Los algoritmos se
comparan con la misma semilla y el mismo presupuesto en la pantalla Comparar.

## Archivos

| archivo | qué hace |
|---|---|
| `consultar_oferta_siiau.m` | descarga todas las páginas de la oferta |
| `leer_oferta_siiau.m` | convierte el HTML en secciones, materias e ignoradas |
| `horario_materias.m` | arma el problema con `crear_problema` |
| `desglose_horario.m` | calcula `f` y sus términos (única fuente del costo) |
| `decodificar_horario.m` | traduce `x` a NRC elegidos y el desglose (lo usa la interfaz) |
| `oferta_ejemplo.m` | carga la oferta guardada en `datos/siiau/` |

Pruebas: `runtests('tests/test_horario.m')`.
