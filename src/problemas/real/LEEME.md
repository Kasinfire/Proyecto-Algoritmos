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

Pendiente: `horario.m` (el problema: codificación, función objetivo y restricciones). Mientras no
exista, la tarjeta de aplicación real de la pantalla 1 no deja continuar.

Detalles de SIIAU:
- Una sección puede traer varias sesiones (por ejemplo lunes en un aula y jueves en otra).
- Las secciones sin horario (virtuales o por asignar) se conservan, pero no entran al horario.
- Con el filtro de lugares disponibles, SIIAU pone el botón "100 Próximos" aunque ya no haya
  más secciones; por eso se para con "Total de registros".
- El calendario siguiente aparece antes de tener horarios (cupo 0 y sin hora), por eso la
  pantalla abre en el calendario actual.
