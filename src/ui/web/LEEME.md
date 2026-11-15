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
   ├─ comun/            lo compartido: base.css, puente.js, riel.js, fuentes/
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

## Caché de uihtml
uihtml guarda en caché los CSS y JS mientras MATLAB está abierto. Por eso los enlaces
llevan `?v=3`: si cambias un CSS o JS, súbele el número en el HTML (o reinicia MATLAB),
si no se queda la versión vieja.

## Probar
En MATLAB, desde `Proyecto/`:
```matlab
addpath(genpath('src')); demo_pantalla_tipo
addpath(genpath('src')); demo_pantalla_problema          % o ('binario') o ('permutacion')
```
Para diseñar en el navegador sin MATLAB: abre cualquiera de los `.html` directamente (o sirve la
carpeta con `python3 -m http.server`). Sin MATLAB usa datos de ejemplo y los eventos
salen en la consola.
