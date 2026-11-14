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

## Probar
En MATLAB, desde `Proyecto/`:
```matlab
addpath(genpath('src')); demo_pantalla_tipo
```
Para diseñar en el navegador sin MATLAB: abre `tipo.html` directamente (o sirve la
carpeta con `python3 -m http.server`). Sin MATLAB usa datos de ejemplo y los eventos
salen en la consola.
