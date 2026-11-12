# Reparto de trabajo

Propuesta inicial: ajusten nombres y número de personas. Cada bloque trabaja en **sus carpetas**
para que no haya conflictos en git.

| Bloque | Responsable | Carpetas | Qué entrega |
|---|---|---|---|
| **A. Interfaz** | _kelly_ | `MetaheuristicasApp.mlapp`, `src/ui/` | App Designer + paneles HTML/CSS, navegación, validación, gráficas en vivo, exportar |
| **B. GA + DE** | _Laura_ | `src/algoritmos/ga/`, `src/algoritmos/de/` | Los dos algoritmos para continuo, binario y permutación |
| **C. ACO + AIS + TSP** | _Dario_ | `src/algoritmos/aco/`, `src/algoritmos/ais/`, `src/problemas/permutacion/` | Los dos algoritmos + problema TSP con datos |
| **D. Binario + experimentos** | _Adolfo_ | `src/problemas/binario/`, `experimentos/`, `tests/` | OneMax/mochila, experimentos y pruebas (el PSO ya está listo) |
| **Todos** | | `docs/` | Reporte, video, problema real (bonus) |


## 1. Checklist contra el enunciado y la rúbrica

### Algoritmos (rúbrica: implementación 25 pts)
- [ ] GA · [ ] ACO · [x] PSO · [ ] AIS · [ ] DE: búsqueda real, código comentado
- [ ] Tabla de qué representación soporta cada algoritmo; la interfaz bloquea o explica las combinaciones no válidas
- [ ] Documentar las variantes/adaptaciones (p.ej. PSO binario, random keys para TSP)

### Problemas
- [x] Continuo: Esfera, Rastrigin, Rosenbrock, Ackley, Griewank, Schwefel (ya existen)
- [ ] Continuo: que dimensión y límites sean configurables desde la interfaz
- [ ] Binario: OneMax y/o mochila (pesos, valores, capacidad configurables)
- [ ] Permutación: TSP con coordenadas en `datos/`
- [ ] (Bonus +10) Problema real: situación, variables, función objetivo, restricciones, origen de los datos

### Interfaz (funcionalidad 30 pts)
- [ ] Pantallas: tipo de problema → problema y datos → algoritmo y parámetros → ejecución → resultados
- [ ] Solo se muestran los parámetros de la combinación elegida; cada uno con etiqueta, explicación y validación
- [ ] Botones Ejecutar, Detener, Reiniciar, Regresar; selector min/max cuando aplique
- [ ] Mensajes claros ante datos inválidos (no debe dejar ejecutar con parámetros inválidos)

### Visualización (20 pts)
- [ ] Durante la ejecución: iteración actual/total, mejor valor, gráfica de convergencia, solución (contorno 2D / ruta / vector binario)
- [ ] Momentos 0, ⅓, ⅔ y final; guardar el historial y poder recorrerlo con un slider
- [ ] Resumen final + configuración usada + exportar CSV/JSON

### Experimentos
- [ ] 5 ejecuciones documentadas (una por algoritmo), ≥2 tipos de problema, ≥3 combinaciones
- [ ] Mismo presupuesto de iteraciones/evaluaciones y semilla fija
- [ ] Interpretación + limitación de cada experimento (reutilizar el patrón de `experimentos/pso_parametros/`)

### Entregables (reporte 15 + video 10)
- [ ] README con instrucciones · [ ] Reporte PDF/LaTeX con referencias · [ ] Video · [ ] Datos de prueba en `datos/`
