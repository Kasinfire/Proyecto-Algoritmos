# Datos de prueba

Instancias de TSP (coordenadas), mochila (pesos/valores/capacidad) y datos del problema real, en CSV.

## siiau/

`oferta_info_202620.html`: consulta pública de la oferta académica de SIIAU (Universidad de Guadalajara), tal como la manda el servidor (ISO-8859-1). Es información pública y no requiere iniciar sesión.

- **Origen:** `http://consulta.siiau.udg.mx/wco/sspseca.consulta_oferta`
- **Descarga:** 15/11/2026
- **Filtros:** ciclo 202620 (Calendario 26 B), centro D (CUCEI), carrera INFO, solo con lugares disponibles: no.
- **Contenido:** 7 páginas de 100 resultados pegadas en un solo archivo, 627 secciones en total.
  - 604 con horario (entran al problema).
  - 23 sin horario (virtuales o por asignar), que se ignoran.
  - 53 materias distintas entre las secciones con horario.
- **Uso:** es la oferta de ejemplo sin internet para la pantalla del horario, las pruebas y los experimentos (resultados reproducibles). Se lee con `oferta_ejemplo()`, que usa `leer_oferta_siiau`.

Cualquier archivo `oferta_*.html` que se agregue a esta carpeta lo toma `oferta_ejemplo()`.