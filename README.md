# Entorno interactivo de metaheurísticas (MATLAB)

Aplicación en MATLAB para configurar, ejecutar y comparar **GA, ACO, PSO, AIS y DE** sobre problemas 
**continuos, binarios y de permutación (TSP)**, con visualización de la convergencia en vivo y exportación de resultados.

> Estado: **en organización**. El reparto de trabajo está en [`TAREAS.md`](TAREAS.md).
> Reglas de código y contrato entre módulos: [`docs/guia_desarrollo.md`](docs/guia_desarrollo.md).

## Requisitos
- MATLAB **R2023a o más reciente** (usamos R2026a). Solo se necesita MATLAB base.
- (Opcional) VS Code con la extensión **MATLAB** de MathWorks (`.vscode/extensions.json`).

## Estructura

```
Proyecto/
├─ src/
│  ├─ algoritmos/
│  │  ├─ pso/
│  │  ├─ ga/
│  │  ├─ aco/                [falta]
│  │  ├─ ais/                [falta]
│  │  ├─ de/
│  │  └─ comunes/
│  ├─ problemas/
│  │  ├─ comun/
│  │  ├─ continuo/
│  │  ├─ binario/            [falta]   OneMax, mochila
│  │  ├─ permutacion/        [falta]   TSP
│  │  └─ real/               [falta]   problema de aplicación real (bonus)
│  ├─ core/utilidades/
│  ├─ graficas/
│  └─ ui/                    interfaz: empezar por src/ui/LEEME.md
│     ├─ pantallas/          un .m por pantalla, agrupados por paso
│     ├─ demos/
│     └─ web/
├─ experimentos/
│  └─ pso_parametros/
├─ extras/bha/
├─ datos/                    [falta]   instancias (ciudades TSP, mochila, datos reales)
└─ tests/                    [falta]   pruebas automáticas (matlab.unittest) ? 
```

## Cómo correr lo que ya existe
Abrir MATLAB en la carpeta `Proyecto/` y escribir en la ventana de comandos :

```matlab
MetaheuristicasApp                              % la aplicación completa
run('experimentos/pso_parametros/main_pso.m')   % experimento PSO (tabla + gráficas en resultados/)
run('extras/bha/main_bha.m')                    % demo BHA en Rastrigin 2D (ver extras/)
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
