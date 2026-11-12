# Entorno interactivo de metaheurísticas (MATLAB)

Aplicación en MATLAB (App Designer + paneles HTML/CSS con `uihtml`) para configurar, ejecutar y comparar
**GA, ACO, PSO, AIS y DE** sobre problemas **continuos, binarios y de permutación (TSP)**, con
visualización de la convergencia en vivo y exportación de resultados.

> Estado: **en organización**. El reparto de trabajo está en [`TAREAS.md`](TAREAS.md).
> Reglas de código y contrato entre módulos: [`docs/guia_desarrollo.md`](docs/guia_desarrollo.md).

## Requisitos
- MATLAB **R2023a o más reciente** (el equipo usa R2026a). Solo se necesita MATLAB base.
- (Opcional) VS Code con la extensión **MATLAB** de MathWorks (`.vscode/extensions.json` la sugiere).

## Estructura
`[listo]` = ya hay código (lo que teníamos, reorganizado). `[falta]` = pendiente, ver `TAREAS.md`.
```
Proyecto/
├─ src/                                Código de la aplicación (se agrega al path con genpath)
│  ├─ algoritmos/
│  │  ├─ pso/               *[listo]*   PSO continuo, binario y TSP; ejemplo del contrato
│  │  ├─ bha/               *[listo]*   Black Hole Algorithm (extra, de BHA_MATLAB)
│  │  ├─ ga/                 [falta]
│  │  ├─ aco/                [falta]
│  │  ├─ ais/                [falta]
│  │  ├─ de/                 [falta]
│  │  └─ comunes/           *[listo]*   crear_parametro, parametros_comunes, decodificar_llaves...
│  ├─ problemas/
│  │  ├─ comun/             *[listo]*   crear_problema (formato único de problema)
│  │  ├─ continuo/          *[listo]*   funcion_prueba (9 funciones)
│  │  ├─ binario/            [falta]   OneMax, mochila
│  │  ├─ permutacion/        [falta]   TSP
│  │  └─ real/               [falta]   problema de aplicación real (bonus)
│  ├─ core/utilidades/      *[listo]*   validar_problema, limitar_a_rango, completar_opciones
│  ├─ graficas/             *[listo]*   convergencia, superficie/contorno, animación
│  └─ ui/web/                [falta]   HTML/CSS de los paneles uihtml
├─ experimentos/
│  ├─ pso_parametros/       *[listo]*   experimento de w, c1, c2 (main_pso.m)
│  └─ bha_demo/             *[listo]*   demo del BHA (main_bha.m)
├─ datos/                    [falta]   instancias (ciudades TSP, mochila, datos reales)
└─ tests/                    [falta]   pruebas automáticas (matlab.unittest)
```
La interfaz (`MetaheuristicasApp.mlapp`) todavía no existe.

## Cómo correr lo que ya existe
Abrir MATLAB en la carpeta `Proyecto/` y ejecutar:
```matlab
run('experimentos/pso_parametros/main_pso.m')   % experimento PSO (tabla + gráficas en resultados/)
run('experimentos/bha_demo/main_bha.m')         % demo BHA en Rastrigin 2D
```
Cada script agrega `src/` al path por su cuenta.

## Trabajo en equipo 
1. `git clone https://github.com/Kasinfire/Proyecto-Algoritmos.git`
2. Crear una rama por tarea: `git switch -c feature/ga`
3. Trabajar **solo en tu carpeta asignada** (ver `TAREAS.md`) para no chocar.
4. Subir la rama y abrir un Pull Request; otra persona del equipo lo revisa.

**Importante:** los archivos `.mlapp` (App Designer) son binarios y git no puede mezclarlos.
Solo **una persona** edita la interfaz; los demás trabajan en archivos `.m`.

## Convenciones de código
- Todo en `snake_case` y en español: archivos, funciones, variables y campos de structs
  (`seleccion_torneo.m`, `mejor_valor`, `n_particulas`). Sin camelCase.
- Cada función lleva un encabezado corto: qué hace, entradas y salidas.
- Comentarios solo donde algo no es obvio. Que se entienda por los nombres, no por comentar cada línea.
- Nada de números mágicos: los valores por defecto de los parámetros se definen en un solo lugar.
- Toda ejecución acepta una **semilla** (`rng(semilla, 'twister')`) para ser reproducible.
