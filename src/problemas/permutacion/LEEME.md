# Problemas de permutación: por implementar
Responsable: bloque C. TSP: la solución es una permutación de ciudades; costo = longitud del recorrido cerrado. Coordenadas en datos/.

## Lo que espera la interfaz
La pantalla 2 (`src/ui/pantallas/armar_problema_permutacion.m`) llama a esta función con las
ciudades que generó la semilla o que vinieron de un CSV, ya validadas (de 4 a 100 ciudades).
Regresa el struct de `crear_problema`:

```matlab
problema = tsp(coordenadas)      % coordenadas: n x 2, una fila (x, y) por ciudad
```

- `representacion='permutacion'`, `sentido='min'`, `sentido_fijo=true` y `lb = ub = []`.
- `f(ruta)` recibe una permutación 1 x n de 1..n y regresa la longitud del recorrido
  cerrado (de la última ciudad se regresa a la primera).
- `datos=struct('coordenadas', coordenadas)`; conviene guardar también la matriz de
  distancias para no recalcularla en cada evaluación.

Mientras el archivo no exista, la pantalla deja elegir las ciudades pero no deja continuar.
