# Problema de aplicación real (bonus +10)
Todos. Explicar la situación real, variables de decisión, función objetivo, restricciones y origen de los datos.

## Horario del semestre
Elegir una sección por materia de la oferta real de la UdeG, sin choques y con pocas horas muertas.

Origen de los datos: la consulta pública de oferta académica de SIIAU.

| Archivo | Qué hace |
|---|---|
| `opciones_siiau.m` | ciclos (calculados con la fecha), centros y carreras de CUCEI para el formulario |
| `consultar_siiau.m` | descarga la oferta página por página (`p_start`) hasta la que trae "Total de registros" |
| `leer_oferta_siiau.m` | convierte el HTML de SIIAU en un struct de secciones con sus sesiones (hora, días, aula) |
| `leer_oferta_guardada.m` | lo mismo desde páginas guardadas con Ctrl+S (UTF-8 o ISO-8859-1) |
| `desglose_horario.m` | cuenta cada castigo de f para una solución (choques, horas muertas, ...) y su suma |

Pendiente: `horario.m` (el problema: codificación, función objetivo y restricciones). Mientras no
exista, la tarjeta de aplicación real de la pantalla 1 no deja continuar y Siguiente en
Preferencias avisa que falta.

### Contrato de `horario.m`
`problema = horario(secciones, preferencias)` regresa un struct de `crear_problema` con
`representacion='binario'`, `sentido='min'` y `sentido_fijo=true`.

- `secciones`: solo las que tienen horario de las materias elegidas, mismo formato que
  `leer_oferta_siiau`. Cada una es un bit: `x(i) = 1` si se inscribe la sección `i`.
- `preferencias` (lo que manda la pantalla):

| Campo | Ejemplo | Qué es |
|---|---|---|
| `entrada`, `salida` | `9`, `19` | horas (enteras) fuera de las cuales no se quiere clase |
| `dias_libres` | `[0 0 0 0 1 0]` | lógico 1 x 6, de lunes a sábado |
| `peso_muertas` | `1` | 0 a 5, qué tanto molestan las horas muertas |
| `max_materias_dia` | `3` | |
| `max_horas_seguidas` | `4` | |
| `solo_cupo` | `true` | las secciones sin lugares no cuentan como opción |

Función objetivo que muestra la pantalla (los pesos 2, 5, 10 y 100 son fijos):

```
f(x) = peso_muertas·horas muertas + 2·horas fuera de entrada–salida
     + 5·días libres ocupados
     + 10·(materias de más en un día + horas seguidas de más)
     + 100·(choques + materias sin sección)
```

"Materias sin sección" cuenta las materias con cero o con más de una sección elegida (una
sección por materia); con `solo_cupo`, una sección sin lugares no cuenta como elegida.

`desglose_horario(x, secciones, preferencias)` ya calcula cada término y `f`; las pantallas
de ejecución y resultados lo usan para mostrar choques y horas muertas. `horario.m` puede
usarlo como función objetivo (`f = desglose.f`) o calcular la suya, pero si cambia los
pesos o los términos hay que cambiarlos también ahí para que la pantalla diga lo mismo.
Mientras no exista `horario.m`, `horario_de_ejemplo` (en `src/ui/demos`) arma el problema
con este desglose para probar las pantallas.

Detalles de SIIAU:
- Una sección puede traer varias sesiones (por ejemplo lunes en un aula y jueves en otra).
- Las secciones sin horario (virtuales o por asignar) se conservan, pero no entran al horario.
- Con el filtro de lugares disponibles, SIIAU pone el botón "100 Próximos" aunque ya no haya
  más secciones; por eso se para con "Total de registros".
- El calendario siguiente aparece antes de tener horarios (cupo 0 y sin hora), por eso la
  pantalla abre en el calendario actual.
