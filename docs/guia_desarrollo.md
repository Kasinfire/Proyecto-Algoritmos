# Guía de desarrollo

Reglas y contrato común del proyecto. Todo el equipo programa contra este documento;
si algo no está definido aquí, se acuerda con el equipo antes de implementarlo. El
contrato (sección 4) no se cambia sin avisar, porque los demás bloques dependen de él.

### 1. El proyecto
Aplicación con interfaz gráfica para configurar, ejecutar y comparar cinco
metaheurísticas sobre tres tipos de problema.

- Algoritmos: **GA** (genético), **ACO** (colonia de hormigas), **PSO** (enjambre de
  partículas), **AIS** (sistema inmune artificial, p. ej. CLONALG) y **DE** (evolución diferencial).
- Representaciones:
  - **continuo**: la solución es un vector de reales dentro de `[lb, ub]`.
  - **binario**: la solución es un vector de 0 y 1 (tipo `double`).
  - **permutacion**: la solución es un orden de los enteros `1..dim` (p. ej., la ruta en un TSP).
- Requisitos del profesor que afectan a los algoritmos:
  - Cada algoritmo hace una búsqueda real, con su implementación identificable y comentada.
  - Si un algoritmo no soporta una representación, se declara (sección 4.4) y la interfaz la bloquea.
  - Si se usa una adaptación (p. ej. random keys para TSP, PSO binario), se documenta.
  - Se guarda el historial completo, porque la interfaz muestra las iteraciones 0, 1/3, 2/3 y la final.
  - Hay que poder minimizar o maximizar.
  - Las ejecuciones son reproducibles con una semilla.
  - Motivos de término: límite de iteraciones, convergencia anticipada o detenido por el usuario.

### 2. Reglas de código (obligatorias)
- Todo en **snake_case y en español**: archivos, funciones, variables y campos de structs
  (`seleccion_torneo.m`, `mejor_valor`, `tam_poblacion`). Nada de camelCase.
- Una función por archivo `.m` y funciones cortas con una sola responsabilidad. Se permiten
  funciones locales al final del archivo cuando solo las usa ese archivo.
- Cada función empieza con un encabezado corto: qué hace, entradas y salidas.
- Comentarios solo donde algo no es obvio (por qué se hace así o la ecuación del paso).
  No comentes cada línea.
- **Sin emojis** en código, comentarios ni documentos.
- Sin números mágicos: los valores por defecto viven en `parametros_<alg>.m`.
- No uses toolboxes: solo MATLAB base.
- No uses `clear`, `clc`, `close all` ni `disp` o `fprintf` dentro de los algoritmos.
- Vectoriza cuando sea natural, pero prefiere la claridad.

### 3. Estructura del repositorio
```
Proyecto/
├─ src/
│  ├─ algoritmos/
│  │  ├─ comunes/        crear_parametro, parametros_comunes, valores_por_defecto,
│  │  │                  decodificar_llaves (ya existen)
│  │  ├─ ga/ aco/ ais/ de/   por hacer
│  │  ├─ pso/            listo y cumple el contrato: es el EJEMPLO DE REFERENCIA
│  │  └─ bha/            algoritmo extra, no se toca
│  ├─ problemas/
│  │  ├─ comun/          crear_problema.m (ya existe)
│  │  ├─ continuo/       funcion_prueba.m con 9 funciones (ya existe)
│  │  ├─ binario/        por hacer (onemax, mochila)
│  │  ├─ permutacion/    por hacer (tsp)
│  │  └─ real/           por hacer (problema real, bonus)
│  ├─ core/utilidades/   validar_problema, limitar_a_rango, completar_opciones (ya existen)
│  ├─ graficas/          graficar_convergencia, graficar_funcion, malla_funcion, animar_bha (ya existen)
│  └─ ui/                interfaz (por hacer)
├─ datos/                CSV de instancias (ciudades, mochila, datos reales)
├─ experimentos/         scripts de experimentos
└─ tests/                pruebas con matlab.unittest
```
Todo `src/` se agrega al path con `addpath(genpath('src'))`. Dos funciones no pueden
llamarse igual aunque estén en carpetas distintas.

### 4. Contrato (lo que todos deben respetar)

#### 4.1 Problema
Todos los problemas se crean con `crear_problema` (ya existe):
```matlab
problema = crear_problema(nombre, f, lb, ub, dim, ...
    representacion='continuo', ... % 'continuo' | 'binario' | 'permutacion'
    sentido='min', ...             % 'min' | 'max'
    sentido_fijo=false, ...        % true si el problema define el sentido (TSP = min, mochila = max)
    f_optimo=NaN, ...              % valor óptimo si se conoce
    x_optimo=[], ...               % solución óptima si se conoce
    datos=struct(), ...            % datos propios: pesos, valores, coordenadas, distancias...
    descripcion='');               % qué representa la solución y cómo se calcula f
```
Campos del struct resultante: `nombre, representacion, f, lb, ub, dim, sentido,
sentido_fijo, f_optimo, x_optimo, datos, descripcion`.

- `f` recibe **una solución como vector fila 1 x dim** y regresa un escalar, en la escala
  real del problema (sin cambiarle el signo).
- Binario: `lb = 0`, `ub = 1`. Permutación: `lb = []`, `ub = []`.
- Las restricciones (p. ej. la capacidad de la mochila) se manejan **dentro de `f`** con
  penalización, y se explican en `descripcion`.
- Ejemplo continuo que ya existe: `problema = funcion_prueba('rastrigin', 2)`.
  Nombres disponibles: `funcion_prueba('lista')`.

#### 4.2 Firma de un algoritmo
```matlab
resultado = ga(problema, params, al_cada_iteracion)
```
- `problema`: struct de la sección 4.1.
- `params`: struct con un campo por parámetro (sección 4.4). Siempre incluye
  `n_iteraciones`, `semilla` y `paciencia`.
- `al_cada_iteracion` (opcional, puede ser `[]`): handle que se llama así:
  `detener = al_cada_iteracion(estado)`. Se llama en la iteración 0 (después de
  inicializar) y al final de cada iteración. Si regresa `true`, el algoritmo termina con
  motivo `'detenido'`. La interfaz lo usa para dibujar en vivo y para el botón Detener.

`estado` es un struct con:
| campo | contenido |
|---|---|
| `iteracion` | iteración actual (0 = inicialización) |
| `n_iteraciones` | total configurado |
| `mejor_valor` | mejor valor encontrado hasta ahora, en escala real |
| `mejor_solucion` | vector fila 1 x dim de esa solución |
| `poblacion` | matriz N x dim con las soluciones actuales (decodificadas, en la representación del problema) |
| `evaluaciones` | número de evaluaciones de `f` hasta ahora |

#### 4.3 Resultado
```matlab
resultado.algoritmo        % 'GA', 'ACO', 'PSO', 'AIS' o 'DE'
resultado.variante         % texto corto, p. ej. 'DE/rand/1/bin'
resultado.problema         % el struct problema recibido
resultado.params           % el struct params usado (completo)
resultado.sentido          % 'min' o 'max'
resultado.mejor_solucion   % 1 x dim
resultado.mejor_valor      % escalar en escala real
resultado.iteraciones      % iteraciones ejecutadas
resultado.motivo_termino   % 'max_iteraciones' | 'convergencia' | 'detenido'
resultado.evaluaciones     % total de evaluaciones de f
resultado.tiempo           % segundos (tic/toc)
resultado.historial.mejor_valor     % (iteraciones+1) x 1; fila 1 = iteración 0
resultado.historial.mejor_solucion  % (iteraciones+1) x dim
resultado.historial.poblacion       % celda (iteraciones+1) x 1; cada celda N x dim
```
`historial.mejor_valor` es el mejor valor **acumulado** (nunca empeora), así la gráfica
de convergencia sale del historial real.

#### 4.4 Parámetros e información de cada algoritmo
Cada carpeta de algoritmo tiene, además del algoritmo, dos funciones:

```matlab
function info = info_ga()
    info.id = 'ga';
    info.nombre = 'Algoritmo Genético';
    info.variante = 'GA generacional con elitismo';
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
```
```matlab
function defs = parametros_ga(representacion)
% Regresa los parámetros pertinentes para esa representación.
    defs = [parametros_comunes(), ...
        crear_parametro('tam_poblacion', 'Tamaño de población', 'entero', 50, ...
            min=4, max=1000, descripcion='Número de individuos por generación.'), ...
        crear_parametro('tasa_cruza', 'Tasa de cruza', 'real', 0.9, ...
            min=0, max=1, descripcion='Probabilidad de cruzar cada pareja.')];
    switch representacion
        case 'continuo'
            defs = [defs, crear_parametro('sigma_mutacion', ...)];
        case 'permutacion'
            defs = [defs, crear_parametro('tipo_mutacion', 'Mutación', 'opcion', 'swap', ...
                        opciones={'swap', 'inversion'})];
    end
end
```
Funciones que ya existen en `src/algoritmos/comunes/`:
- `crear_parametro(nombre, etiqueta, tipo, valor, min=, max=, opciones=, descripcion=)`,
  donde `tipo` es `'entero' | 'real' | 'opcion'`.
- `parametros_comunes()` regresa `n_iteraciones` (200), `semilla` (42) y `paciencia` (0 = desactivada).
- `valores_por_defecto(defs)` convierte los parámetros en el struct `params`.
- `decodificar_llaves(llaves)` convierte random keys (N x D reales) en permutaciones.

Todos los algoritmos usan los mismos nombres para lo común: `n_iteraciones`,
`tam_poblacion` (o `n_hormigas`, `n_particulas`, `n_anticuerpos` si es más claro), `semilla`, `paciencia`.

#### 4.5 Reglas internas de todos los algoritmos
- **Semilla**: al inicio, `rng(params.semilla, 'twister')`.
- **Min/max**: internamente siempre se minimiza
  `costo = @(x) signo * problema.f(x)`, con `signo = -1` si `problema.sentido` es `'max'`.
  Todo lo que se reporta (`estado`, `resultado`, `historial`) va en escala real (`signo * costo`).
- **Paciencia**: si `params.paciencia > 0` y el mejor valor no mejora en esa cantidad de
  iteraciones, termina con `motivo_termino = 'convergencia'`.
- **Factibilidad**: las soluciones siempre son válidas para su representación (continuo
  dentro de `[lb, ub]` con `limitar_a_rango`, binario solo 0/1, permutación sin repetidos).
- **Representaciones no naturales**: se permite trabajar en otro espacio y decodificar.
  Por ejemplo, random keys (`[~, ruta] = sort(llaves)`) para permutación en PSO y DE, o
  umbral `x > 0.5` para binario. Se documenta en `info.variante`.

#### 4.6 Plantilla de un algoritmo
```matlab
function resultado = nombre_alg(problema, params, al_cada_iteracion)
% NOMBRE_ALG  Descripción en una línea.
%   resultado = nombre_alg(problema, params, al_cada_iteracion)
%   Ver docs/guia_desarrollo.md, sección 4, para el formato de entradas y salidas.

    if nargin < 3, al_cada_iteracion = []; end
    rng(params.semilla, 'twister');
    t_inicio = tic;
    signo = 1 - 2 * strcmp(problema.sentido, 'max');
    costo = @(x) signo * problema.f(x);

    % Inicialización: poblacion (N x dim), costos (N x 1)
    ...
    evaluaciones = N;
    [mejor_costo, i] = min(costos);
    mejor_solucion = poblacion(i, :);

    hist_valor = zeros(params.n_iteraciones + 1, 1);
    hist_solucion = zeros(params.n_iteraciones + 1, problema.dim);
    hist_poblacion = cell(params.n_iteraciones + 1, 1);
    motivo = 'max_iteraciones';
    sin_mejora = 0;

    for t = 0:params.n_iteraciones
        if t > 0
            % Un paso del algoritmo: genera nuevas soluciones, las evalúa
            % y actualiza mejor_costo / mejor_solucion si alguna es mejor.
            ...
        end

        hist_valor(t + 1) = signo * mejor_costo;
        hist_solucion(t + 1, :) = mejor_solucion;
        hist_poblacion{t + 1} = poblacion;

        if ~isempty(al_cada_iteracion)
            estado = struct('iteracion', t, 'n_iteraciones', params.n_iteraciones, ...
                'mejor_valor', signo * mejor_costo, 'mejor_solucion', mejor_solucion, ...
                'poblacion', poblacion, 'evaluaciones', evaluaciones);
            if al_cada_iteracion(estado)
                motivo = 'detenido'; break;
            end
        end
        if params.paciencia > 0 && sin_mejora >= params.paciencia
            motivo = 'convergencia'; break;
        end
    end

    n = t + 1;
    info = info_nombre_alg();
    resultado.algoritmo = 'NOMBRE';
    resultado.variante = info.variante;
    resultado.problema = problema;
    resultado.params = params;
    resultado.sentido = problema.sentido;
    resultado.mejor_solucion = mejor_solucion;
    resultado.mejor_valor = signo * mejor_costo;
    resultado.iteraciones = t;
    resultado.motivo_termino = motivo;
    resultado.evaluaciones = evaluaciones;
    resultado.tiempo = toc(t_inicio);
    resultado.historial.mejor_valor = hist_valor(1:n);
    resultado.historial.mejor_solucion = hist_solucion(1:n, :);
    resultado.historial.poblacion = hist_poblacion(1:n);
end
```
`sin_mejora` se reinicia a 0 cuando mejora `mejor_costo` y aumenta en 1 cuando no.

### 5. Código que ya existe y se puede usar
- `funcion_prueba(nombre, dim)`: esfera, rosenbrock, rastrigin, ackley, griewank,
  schwefel, zakharov (min), lineal y exponencial (max).
- `limitar_a_rango(x, lb, ub)`: recorta a los límites.
- `graficar_convergencia(curvas, etiquetas, titulo=, sentido=, f_optimo=, etiqueta_y=, ax=)`:
  una o varias curvas; con `ax` dibuja en unos ejes existentes (para la interfaz).
- `malla_funcion(problema, n)` y `graficar_funcion(resultado)`: superficie y contorno de una función 2D.
- **PSO completo y conforme al contrato** (`src/algoritmos/pso/`): `pso.m`, `info_pso.m`,
  `parametros_pso.m` y sus pasos en archivos aparte. Soporta continuo, binario (BPSO) y
  permutación (random keys). **Es el ejemplo a imitar**: `pso.m`,
  `info_pso.m` y `parametros_pso.m` muestran un algoritmo real con este formato.
  Uso: `r = pso(funcion_prueba('rastrigin', 2), valores_por_defecto(parametros_pso('continuo')))`.

---

## Bloques de trabajo

### Bloque A: Interfaz
**Carpetas:** `src/ui/`, archivo principal de la app.
**Archivos de referencia:** `graficar_convergencia.m`, `crear_parametro.m`,
`parametros_comunes.m`, `crear_problema.m`, `funcion_prueba.m`, `pso.m`, `info_pso.m`,
`parametros_pso.m`, y los `info_*.m` y `parametros_*.m` de los demás algoritmos que ya existan.

Mientras los demás algoritmos no estén listos, prueba la interfaz con el PSO, que ya
funciona con las tres representaciones.

Entregar:
- La app. Se recomienda hacerla como clase de texto `MetaheuristicasApp.m`
  (`classdef MetaheuristicasApp < matlab.apps.AppBase`, componentes `uifigure`) para
  que git la pueda versionar y revisar en los Pull Requests. Un `.mlapp` de App Designer
  también vale, pero solo una persona lo edita.
- Flujo: tipo de problema, luego problema y sus datos, luego algoritmo y parámetros,
  luego ejecución y por último resultados. Botones Ejecutar, Detener, Reiniciar y Regresar.
- Controles de parámetros **generados a partir de `parametros_<alg>(representacion)`**:
  etiqueta, tooltip con `descripcion` y validación de `min`, `max` y `tipo`. No se puede
  ejecutar con datos inválidos y debe mostrar un mensaje claro.
- Las combinaciones no soportadas (según `info_<alg>().representaciones`) se deshabilitan o se explican.
- Selector min/max solo si `problema.sentido_fijo` es `false`.
- Durante la ejecución, mediante `al_cada_iteracion`: iteración actual de total, mejor
  valor, convergencia en vivo y la solución (contorno 2D en continuo, ruta en TSP,
  barras en binario). Usar `drawnow limitrate`.
- En resultados: resumen completo, configuración usada, slider para recorrer el
  historial con marcas en 0, 1/3, 2/3 y final, y exportar a JSON y CSV.
- Estilo: paneles `uihtml` con HTML/CSS locales (sin CDN) en `src/ui/web/` para el
  encabezado, las tarjetas y el resumen.

### Bloque B: GA y DE
**Carpetas:** `src/algoritmos/ga/`, `src/algoritmos/de/`.
**Archivos de referencia:** `pso.m`, `info_pso.m`, `parametros_pso.m` (ejemplo),
`funcion_prueba.m`, `crear_problema.m`, `crear_parametro.m`, `parametros_comunes.m`,
`limitar_a_rango.m`, `decodificar_llaves.m`.

Entregar por cada algoritmo: `ga.m`, `info_ga.m`, `parametros_ga.m` (y lo mismo para `de`)
y sus operadores en archivos aparte (`seleccion_torneo.m`, `cruza_ox.m`, ...).
- GA: selección (torneo y ruleta), cruza, mutación y elitismo. Por representación:
  - continuo: cruza BLX-alfa o aritmética, mutación gaussiana;
  - binario: cruza de un punto o uniforme, mutación bit-flip;
  - permutación: cruza OX, mutación swap o inversión.
- DE: estrategias `rand/1/bin` y `best/1/bin`, con parámetros `F` y `CR`. Binario por
  umbral y permutación por random keys (documentarlo en `variante`).

### Bloque C: ACO, AIS y TSP
**Carpetas:** `src/algoritmos/aco/`, `src/algoritmos/ais/`, `src/problemas/permutacion/`, `datos/`.
**Archivos de referencia:** `pso.m`, `info_pso.m`, `parametros_pso.m` (ejemplo),
`crear_problema.m`, `crear_parametro.m`, `parametros_comunes.m`.

Entregar:
- `tsp.m`: recibe coordenadas (n x 2) y regresa un problema `permutacion`, `sentido='min'`,
  `sentido_fijo=true`. `f` es la longitud de la ruta cerrada. `datos.coordenadas`
  y `datos.distancias` se usan para dibujar la ruta y como heurística del ACO.
  Más `cargar_ciudades.m` (lee un CSV) y un CSV de ejemplo en `datos/`.
- ACO: Ant System para permutación (feromona, evaporación, `alfa`, `beta`, `Q`). Para
  binario, feromona por bit. Para continuo, ACOR o declarar que no lo soporta y explicar por qué.
- AIS: CLONALG (selección, clonación proporcional, mutación inversa a la afinidad,
  reemplazo de los peores) con mutación adecuada a cada representación.

### Bloque D: problemas binarios, experimentos y pruebas
**Carpetas:** `src/problemas/binario/`, `experimentos/`, `tests/`.
**Archivos de referencia:** `pso.m`, `info_pso.m`, `parametros_pso.m`,
`crear_problema.m`, `crear_parametro.m`, `parametros_comunes.m`.

El PSO ya está terminado; este bloque lo usa para probar sus problemas mientras los
demás terminan sus algoritmos.

Entregar:
- `onemax.m` y `mochila.m` (pesos, valores y capacidad; penalización en `f`) en
  `src/problemas/binario/`, con un CSV de ejemplo en `datos/`.
- `tests/`: pruebas `matlab.unittest` que, para cada algoritmo y cada representación
  soportada, revisen que el resultado cumple la sección 4.3, que la solución es válida y
  que el mejor valor final es igual o mejor que el de la iteración 0.
- `experimentos/correr_experimentos.m`: las 5 ejecuciones documentadas (una por
  algoritmo, al menos 2 tipos de problema y 3 combinaciones), mismo `n_iteraciones` y
  semilla fija. Guarda tabla CSV y gráficas.

### Todos: problema real (bonus)
En `src/problemas/real/`. Explicar la situación real, las variables de decisión, la
función objetivo, las restricciones y el origen de los datos (CSV en `datos/`). Debe
usar `crear_problema` como cualquier otro.

---

## Antes de subir tu parte
- [ ] Corre en MATLAB sin errores, con `addpath(genpath('src'))` desde la carpeta `Proyecto/`.
- [ ] Cumple la sección 4 (nombres de campos exactos).
- [ ] snake_case, sin emojis, comentarios solo donde hacen falta.
- [ ] Solo tocaste tus carpetas. Si necesitas cambiar algo común (sección 4 o `comunes/`),
      avisa al equipo primero.
- [ ] Rama propia y Pull Request; otra persona lo revisa.
