# Paneles HTML/CSS para uihtml
Responsable: bloque A. Todo local (sin CDN) para que funcione sin internet.
Requiere MATLAB R2023a o más reciente (`sendEventToHTMLSource` / `sendEventToMATLAB`).

## Cómo se conecta con MATLAB
Cada pantalla es un HTML que se carga en un `uihtml`. Se comunican por eventos:

```
HTML                                   MATLAB (src/ui/pantallas/pantalla_<nombre>.m)
puente.enviar("lista")        ───────► HTMLEventReceivedFcn
                              ◄─────── sendEventToHTMLSource(h, "datos", struct)
puente.enviar("siguiente", …) ───────► callback al_continuar(tipo)
```

- El HTML avisa con `"lista"` cuando ya puede recibir. Si MATLAB mandara antes, el evento se perdería.
- Las ilustraciones de las tarjetas son SVG en línea (`tipo/ilustraciones.js`), con la paleta de
  MATLAB (parula, `#0072BD`, `#D95319`): cargan al instante. Las gráficas de datos reales
  (convergencia, contorno con la población) van en las pantallas de ejecución y resultados.
- Los structs llegan a JS como objetos y las celdas como arreglos (`jsonencode`).
- `comun/numeros.js` lee y formatea los números que escribe el usuario (acepta `−` y coma decimal).

## Organización
```
src/ui/
├─ pantallas/     un .m por pantalla: crea el uihtml y atiende sus eventos
├─ demos/         abre una pantalla sola para probarla
└─ web/
   ├─ <pantalla>.html   los HTML van aquí, al mismo nivel
   ├─ comun/            lo compartido: base.css, puente.js, riel.js, fuentes/,
   │                    paneles.css y graficas.js (mapa y convergencia de ejecución y resultados)
   └─ <pantalla>/       css, js e imágenes propias de esa pantalla
```
Los `.html` no van dentro de su carpeta porque uihtml solo deja cargar archivos de la
misma carpeta del HTML o de subcarpetas; así cada pantalla puede usar `comun/`.

Pantallas hechas:
| HTML | MATLAB | qué es |
|---|---|---|
| `tipo.html` + `tipo/` | `pantallas/pantalla_tipo.m`, `pantallas/tipos_de_problema.m` | 1. tipo de problema |
| `problema.html` + `problema/` | `pantallas/pantalla_problema.m`, `problemas_de_tipo.m`, `armar_problema.m`, `limites_problema.m`, `generar_imagenes_problemas.m` | 2. problema y datos |
| `problema_binario.html` + `problema_binario/` | `pantallas/pantalla_problema.m`, `armar_problema_binario.m`, `leer_objetos_csv.m` | 2. problema y datos (binario) |
| `problema_tsp.html` + `problema_tsp/` | `pantallas/pantalla_problema.m`, `armar_problema_permutacion.m`, `ciudades_al_azar.m`, `leer_ciudades_csv.m` | 2. problema y datos (TSP) |
| `horario.html` + `horario/` | `pantallas/pantalla_horario.m` (la abre `pantalla_problema` con tipo `real`) y `src/problemas/real/` | 2. problema real: horario del semestre |
| `algoritmo.html` + `algoritmo/` | `pantallas/pantalla_algoritmo.m`, `algoritmos_de_tipo.m`, `parametros_para_ui.m`, `armar_parametros.m` | 3. algoritmo y parámetros |
| `ejecucion.html` + `ejecucion/` | `pantallas/pantalla_ejecucion.m`, `pantallas/mapa_de_busqueda.m` | 4. ejecución |
| `resultados.html` + `resultados/` | `pantallas/pantalla_resultados.m`, `exportar_resultado.m` | 5. resultados |
| `comparar.html` + `comparar/` | `pantallas/pantalla_comparar.m`, `exportar_comparacion.m` | comparar ejecuciones (botón del riel) |

Las superficies de la pantalla 2 son PNG de MATLAB guardados en `problema/imagenes/`
(`<id>.png` y `<id>_mini.png`). Se crean una sola vez con `generar_imagenes_problemas`
(solo genera las que faltan; `forzar=true` las rehace) y se suben al repo. Al presionar
Siguiente, `armar_problema.m` vuelve a validar y crea el problema con `crear_problema`.

Con tipo binario, `pantalla_problema.m` carga `problema_binario.html`: pestañas Mochila y
OneMax, la tabla de objetos (peso, valor, valor por unidad de peso) con su capacidad, y los
bits de ejemplo de OneMax. El botón Cargar CSV lo atiende MATLAB (`leer_objetos_csv.m`).
Se puede editar todo aunque falten `mochila.m` u `onemax.m`, pero Siguiente queda
bloqueado hasta que existan en `src/problemas/binario/`.

Con tipo permutación carga `problema_tsp.html`: número de ciudades, semilla y el mapa con
las ciudades numeradas. Las coordenadas las genera MATLAB (`ciudades_al_azar.m`, con su
propio `RandStream` para no mover el `rng` de los algoritmos) o las lee de un CSV con
columnas `x,y` (`leer_ciudades_csv.m`); JS solo las dibuja. Siguiente queda bloqueado hasta
que exista `src/problemas/permutacion/tsp.m`.

Con tipo real carga `horario.html`, con tres subpasos en pastilla: 1 Oferta, 2 Materias y
3 Preferencias (por ahora solo Oferta). La oferta la consulta MATLAB en SIIAU página por página
(`consultar_siiau.m`, avisa el avance con el evento `progreso`) o la lee de páginas guardadas
(`leer_oferta_guardada.m`), y se queda en `pantalla_horario.m` para los siguientes subpasos.
La tabla dibuja las filas por tandas al bajar, porque un centro completo pasa de 5000 secciones.

En la pantalla 4 el algoritmo corre completo en MATLAB al abrirla y el HTML reproduce
`resultado.historial` (play, pausa, paso a paso y arrastrar la línea de tiempo). El fondo del
mapa es `f` evaluada por MATLAB y pintada con `parula` (`mapa_de_busqueda.m`, que también
sirve para la pantalla de resultados); con más de 2 dimensiones es un corte en x1, x2 y con
una dimensión es la curva. Detener corta la búsqueda en la iteración actual: al presionar
Ver resultados MATLAB repite la ejecución con la misma semilla y la detiene ahí, así el
resultado trae los datos reales hasta ese punto. La vista del mapa es solo para problemas
continuos; en binario y permutación se muestra la convergencia.

Las pantallas 4 y 5 comparten en MATLAB `mapa_de_busqueda.m`, `algoritmo_para_ui.m`,
`parametros_resumen.m` y `numeros_para_js.m`. La pantalla 5 recibe el `resultado` que entrega
la 4 y muestra el mapa con la población inicial, la ruta del mejor y la mejor solución, más
las pestañas Convergencia, Historial (las iteraciones donde mejoró) y Configuración. CSV y
JSON los escribe `exportar_resultado.m` tras un diálogo de guardar, porque uihtml no descarga
archivos.

La pantalla de comparar recibe las ejecuciones guardadas (`numero` y `resultado`). Solo
compara las que tienen el mismo problema, dimensión, sentido, límites y datos (MATLAB las
agrupa); las demás aparecen desactivadas con el motivo, y al elegir una de ellas se compara
su grupo. Las curvas son los historiales reales. Al maximizar la escala es lineal; al
minimizar con óptimo conocido distinto de 0 se grafica f − f* para poder usar escala log.
"Iteración del mejor" es la primera iteración en que la curva llega a su valor final, y la
columna de evaluaciones muestra el presupuesto real de cada una (no todas evalúan f igual
de veces por iteración).

La pantalla 3 se arma sola con lo que hay en `src/algoritmos/`: un algoritmo aparece
disponible cuando existen `<id>.m`, `info_<id>.m` y `parametros_<id>.m` y su `info` incluye
la representación del problema. Las tarjetas salen de `parametros_<id>(representacion)`
(tipo, valor, rango); `parametros_para_ui.m` les pone etiquetas cortas con acentos y marca
los que dependen de una opción (k del torneo, alfa de BLX). Un parámetro nuevo que no esté
en su tabla aparece igual, con la etiqueta de su definición. Al presionar Ejecutar,
`armar_parametros.m` vuelve a validar y entrega el struct `params` completo.

## Caché de uihtml
uihtml guarda en caché los CSS y JS mientras MATLAB está abierto. Por eso los enlaces
llevan `?v=3`: si cambias un CSS o JS, súbele el número en el HTML (o reinicia MATLAB),
si no se queda la versión vieja.

## Probar
En MATLAB, desde `Proyecto/`:
```matlab
addpath(genpath('src')); demo_pantalla_tipo
addpath(genpath('src')); demo_pantalla_problema          % o ('binario'), ('permutacion') o ('real')
addpath(genpath('src')); demo_pantalla_algoritmo         % o demo_pantalla_algoritmo('ackley', 10)
addpath(genpath('src')); demo_pantalla_ejecucion         % o demo_pantalla_ejecucion('ackley', 5, 'de')
addpath(genpath('src')); demo_pantalla_resultados        % o demo_pantalla_resultados('ackley', 5, 'de')
addpath(genpath('src')); demo_pantalla_comparar
```
Para diseñar en el navegador sin MATLAB: abre cualquier `.html` directamente (o sirve la
carpeta con `python3 -m http.server`). Sin MATLAB usa datos de ejemplo y los eventos
salen en la consola.
