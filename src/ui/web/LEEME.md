# Detalles de la interfaz
Para el mapa general (qué carpeta es de qué paso y cómo probar) ver [../LEEME.md](../LEEME.md).
Aquí está cómo funciona por dentro.

## Cómo se conecta con MATLAB
Cada pantalla es un HTML que se carga en un `uihtml`. Se comunican por eventos:

```
HTML                                   MATLAB (pantallas/<paso>/pantalla_<paso>.m)
puente.enviar("lista")        ───────► HTMLEventReceivedFcn
                              ◄─────── sendEventToHTMLSource(h, "datos", struct)
puente.enviar("siguiente", …) ───────► callback al_continuar(tipo)
```

- El HTML avisa con `"lista"` cuando ya puede recibir. Si MATLAB mandara antes, el evento se perdería.
- Los structs llegan a JS como objetos y las celdas como arreglos (`jsonencode`).
- `comun/numeros.js` lee y formatea los números que escribe el usuario (acepta `−` y coma decimal).
- Las pantallas encuentran sus HTML y la carpeta `datos/` con `ruta_proyecto(...)`
  (`pantallas/comun/`), así no importa en qué subcarpeta esté cada `.m`.

## Caché de uihtml
uihtml guarda en caché los CSS y JS mientras MATLAB está abierto. Por eso los enlaces
llevan `?v=3`: si cambias un CSS o JS, súbele el número en el HTML (o reinicia MATLAB),
si no se queda la versión vieja.

## Por pantalla

### 1. Tipo de problema
Las ilustraciones de las tarjetas son SVG en línea (`tipo/ilustraciones.js`), con la paleta de
MATLAB (parula, `#0072BD`, `#D95319`): cargan al instante. Las gráficas de datos reales
(convergencia, contorno con la población) van en las pantallas de ejecución y resultados.

### 2. Problema y datos
`pantalla_problema.m` elige la página según el tipo.

**Continuo** (`problema.html`). Las superficies son PNG de MATLAB guardados en
`problema/imagenes/` (`<id>.png` y `<id>_mini.png`). Se crean una sola vez con
`generar_imagenes_problemas` (solo genera las que faltan; `forzar=true` las rehace) y se suben
al repo. Al presionar Siguiente, `armar_problema.m` vuelve a validar y crea el problema con
`crear_problema`.

**Binario** (`problema_binario.html`). Pestañas Mochila y OneMax, la tabla de objetos (peso,
valor, valor por unidad de peso) con su capacidad, y los bits de ejemplo de OneMax. El botón
Cargar CSV lo atiende MATLAB (`leer_objetos_csv.m`). Se puede editar todo aunque falten
`mochila.m` u `onemax.m`, pero Siguiente queda bloqueado hasta que existan en
`src/problemas/binario/`.

**Permutación** (`problema_tsp.html`). Número de ciudades, semilla y el mapa con las ciudades
numeradas. Las coordenadas las genera MATLAB (`ciudades_al_azar.m`, con su propio `RandStream`
para no mover el `rng` de los algoritmos) o las lee de un CSV con columnas `x,y`
(`leer_ciudades_csv.m`); JS solo las dibuja. Siguiente queda bloqueado hasta que exista
`src/problemas/permutacion/tsp.m`.

**Real: horario del semestre** (`horario.html`, MATLAB en `pantallas/horario/`). Tres subpasos
en pastilla: 1 Oferta, 2 Materias y 3 Preferencias. La oferta la consulta MATLAB en SIIAU
página por página (`consultar_oferta_siiau.m`, avisa el avance con el evento `progreso`) o la lee de
páginas guardadas (`leer_oferta_guardada.m`), y se queda en `pantalla_horario.m` para los
siguientes subpasos. La tabla dibuja las filas por tandas al bajar, porque un centro completo
pasa de 5000 secciones. En Preferencias se eligen horas de entrada y salida, días libres, peso
de las horas muertas y carga por día; la fórmula de f se arma con esos valores y la semana
muestra todas las secciones de las materias elegidas con lo que se evita rayado. Cada cambio se
manda a MATLAB (`preferencias`) y Siguiente arma el problema con
`src/problemas/real/horario_materias.m`. Las secciones de `leer_oferta_siiau` traen una sesión
por día en minutos; `secciones_para_ui.m` las junta en bloques con hora `hhmm` y días
`'L.I...'`, que es lo que dibujan las pantallas.

### 3. Algoritmo y parámetros
Se arma sola con lo que hay en `src/algoritmos/`: un algoritmo aparece disponible cuando
existen `<id>.m`, `info_<id>.m` y `parametros_<id>.m` y su `info` incluye la representación
del problema. Las tarjetas salen de `parametros_<id>(representacion)` (tipo, valor, rango);
`parametros_para_ui.m` les pone etiquetas cortas con acentos y marca los que dependen de una
opción (k del torneo, alfa de BLX). Un parámetro nuevo que no esté en su tabla aparece igual,
con la etiqueta de su definición. Al presionar Ejecutar, `armar_parametros.m` vuelve a validar
y entrega el struct `params` completo. Junto al nombre del algoritmo, una pastilla resume su
flujo con las opciones elegidas (GA) o cómo pasa de números a bits o ruta (PSO y DE); en
continuo, PSO y DE no la muestran.

Con el horario es la misma pantalla: el problema es binario y `algoritmos_para_horario.m`
cambia las notas y ayudas para hablar de horarios y secciones y deja los no disponibles al
final. Arriba aparecen el problema, `n` y el sentido, y al pie el presupuesto de evaluaciones
(`tam × (iteraciones + 1)`) para comparar GA, PSO y DE con el mismo.

### 4. Ejecución
El algoritmo corre completo en MATLAB al abrir la pantalla y el HTML reproduce
`resultado.historial` (play, pausa, paso a paso y arrastrar la línea de tiempo). El fondo del
mapa es `f` evaluada por MATLAB y pintada con `parula` (`mapa_de_busqueda.m`); con más de 2
dimensiones es un corte en x1, x2 y con una dimensión es la curva. Detener corta la búsqueda en
la iteración actual: al presionar Ver resultados MATLAB repite la ejecución con la misma
semilla y la detiene ahí, así el resultado trae los datos reales hasta ese punto. La vista del
mapa es solo para problemas continuos; en binario y permutación se muestra la convergencia.

Con el horario, `pantalla_ejecucion` agrega `horario` (de `horario_para_ui.m`: materias con su
color, secciones, preferencias y el mejor horario de cada vez que cambió, con su desglose de
`decodificar_horario.m`). La semana toma el lugar del mapa, las lecturas son generación, mejor f,
choques y horas muertas, y los momentos son miniaturas de la semana. La semana la dibuja
`horario/elegido.js` con el CSS de `horario/semana.css`, que comparte con Materias y
Preferencias.

### 5. Resultados
Recibe el `resultado` que entrega la pantalla 4 y muestra el mapa con la población inicial, la
ruta del mejor y la mejor solución, más las pestañas Convergencia, Historial (las iteraciones
donde mejoró) y Configuración. CSV y JSON los escribe `exportar_resultado.m` tras un diálogo de
guardar, porque uihtml no descarga archivos.

Las pantallas 4 y 5 comparten en MATLAB lo de `pantallas/comun/` (`mapa_de_busqueda.m`,
`algoritmo_para_ui.m`, `parametros_resumen.m`, `numeros_para_js.m`).

Con el horario llega `horario` con una sola solución (la final). La semana final va a la
izquierda con la solución como bits (un color por materia); a la derecha, mejor f, choques,
horas muertas y en qué se va f, la lista de NRC para inscribirse (Copiar NRC usa `clipboard` de
MATLAB, porque uihtml no deja escribir al portapapeles) y las pestañas de siempre.

### Comparar ejecuciones
Recibe las ejecuciones guardadas (`numero` y `resultado`). Solo compara las que tienen el mismo
problema, dimensión, sentido, límites y datos (MATLAB las agrupa); las demás aparecen
desactivadas con el motivo, y al elegir una de ellas se compara su grupo. Las curvas son los
historiales reales. Al maximizar la escala es lineal; al minimizar con óptimo conocido distinto
de 0 se grafica f − f* para poder usar escala log. "Iteración del mejor" es la primera iteración
en que la curva llega a su valor final, y la columna de evaluaciones muestra el presupuesto real
de cada una (no todas evalúan f igual de veces por iteración).
