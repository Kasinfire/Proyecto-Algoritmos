# Interfaz
Responsable: bloque A. La app se abre con `MetaheuristicasApp` (en la raíz de `Proyecto/`).

## La idea en una línea
Cada pantalla es una página HTML dentro de un `uihtml`. **MATLAB calcula** (problemas,
algoritmos, gráficas) y **el HTML solo dibuja** lo que MATLAB le manda. Se hablan por eventos
(ver [web/LEEME.md](web/LEEME.md)).

## El recorrido
La app es un recorrido de cinco pasos. Cada paso tiene dos mitades con el mismo nombre:
una carpeta de MATLAB en `pantallas/` y una página en `web/`.

| Paso | MATLAB (`pantallas/`) | Página (`web/`) | Demo |
|---|---|---|---|
| 1. Tipo de problema | `tipo/` | `tipo.html` | `demo_pantalla_tipo` |
| 2. Problema y datos | `problema/` | `problema.html`, `problema_binario.html`, `problema_tsp.html` | `demo_pantalla_problema` |
| 2. Problema real (horario) | `horario/` | `horario.html` | `demo_pantalla_problema('real')` |
| 3. Algoritmo y parámetros | `algoritmo/` | `algoritmo.html` | `demo_pantalla_algoritmo` |
| 4. Ejecución | `ejecucion/` | `ejecucion.html` | `demo_pantalla_ejecucion` |
| 5. Resultados | `resultados/` | `resultados.html` | `demo_pantalla_resultados` |
| Comparar ejecuciones | `comparar/` | `comparar.html` | `demo_pantalla_comparar` |

`MetaheuristicasApp.m` las une: abre una, espera su evento de "siguiente" y abre la otra.

## Carpetas
```
src/ui/
├─ pantallas/
│  ├─ <paso>/       pantalla_<paso>.m (crea el uihtml y atiende sus eventos)
│  │                y las funciones que solo usa ese paso
│  ├─ horario/      lo del problema real; también lo usan los pasos 3, 4 y 5
│  └─ comun/        lo que usan varias pantallas (rutas, números para JS,
│                   mapa de búsqueda, resumen del algoritmo)
├─ demos/           abre una pantalla sola, sin recorrer la app
└─ web/
   ├─ <paso>.html   las páginas, todas al mismo nivel
   ├─ <paso>/       css y js de cada página
   └─ comun/        estilos base, puente con MATLAB, riel de pasos, gráficas
```
Los `.html` no van dentro de su carpeta porque `uihtml` solo carga archivos de la carpeta del
HTML o de sus subcarpetas; así todas las páginas alcanzan `comun/`.

Para empezar a leer una pantalla: abre `pantallas/<paso>/pantalla_<paso>.m` (qué recibe y
qué eventos atiende) y luego `web/<paso>/<paso>.js` (cómo lo dibuja).

## Probar
En MATLAB, desde `Proyecto/`:
```matlab
addpath(genpath('src'));
demo_pantalla_tipo
demo_pantalla_problema        % o ('binario'), ('permutacion') o ('real')
demo_pantalla_algoritmo       % o ('ackley', 10) u ('horario')
demo_pantalla_ejecucion       % o ('ackley', 5, 'de') u ('horario')
demo_pantalla_resultados      % o ('ackley', 5, 'de') u ('horario')
demo_pantalla_comparar
```
Sin MATLAB: abre cualquier `.html` de `web/` en el navegador (o sirve la carpeta con
`python3 -m http.server`). Usa datos de ejemplo y los eventos salen en la consola. Con
`?horario` al final (`ejecucion.html?horario`) se ve la versión del horario.

Requiere MATLAB R2023a o más reciente. Todo es local (sin CDN), funciona sin internet.

## Más detalle
[web/LEEME.md](web/LEEME.md): cómo funciona el puente, la caché de `uihtml` y qué hace cada
pantalla por dentro.
