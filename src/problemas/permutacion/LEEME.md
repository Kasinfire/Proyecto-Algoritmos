# Problema de permutacion: TSP

La pantalla del problema (`src/ui/pantallas/problema/armar_problema_permutacion.m`) entrega a `tsp(coordenadas)` coordenadas generadas o cargadas desde un CSV.

`tsp(coordenadas)` recibe una matriz n x 2, con una ciudad por fila, y crea un problema compatible con `crear_problema`:

- Representacion `permutacion`, sentido fijo `min` y limites vacios.
- La solucion es un orden de las ciudades, cada una exactamente una vez.
- La funcion objetivo suma las distancias euclidianas entre ciudades consecutivas y agrega el regreso desde la ultima ciudad a la primera.
- `datos.coordenadas` conserva los puntos y `datos.distancias` guarda la matriz que pueden reutilizar ACO y la interfaz.

Para leer un CSV desde un script: `coordenadas = cargar_ciudades(archivo)`. El ejemplo del repositorio esta en `datos/ciudades_tsp.csv`. La interfaz tambien permite generar ciudades con semilla o cargar coordenadas desde un CSV.
