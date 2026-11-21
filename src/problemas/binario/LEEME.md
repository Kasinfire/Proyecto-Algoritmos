# Problemas binarios: OneMax y mochila

La pantalla del problema (`src/ui/pantallas/problema/armar_problema_binario.m`) valida los datos
que escribió el usuario y llama a estas funciones. Las dos regresan el struct de `crear_problema`
con `representacion='binario'`, `sentido='max'` y `sentido_fijo=true`.

```matlab
problema = onemax(n)                             % n bits
problema = mochila(pesos, valores, capacidad)    % vectores fila 1 x n y un escalar
```

## OneMax
f(x) es el número de unos de x. El óptimo es la cadena con todos los bits en 1:
`f_optimo = n` y `x_optimo = ones(1, n)`.

## Mochila 0/1
El bit j en 1 mete el objeto j en la mochila. Se maximiza el valor total sin pasar la capacidad.
Las soluciones que se pasan se penalizan:

- si `peso <= capacidad`, f(x) es la suma de los valores elegidos (f >= 0);
- si no, f(x) = -(peso - capacidad) (f < 0).

Así cualquier solución factible vale más que cualquiera que se pase, y entre las que se pasan
gana la que menos exceso tiene. `datos` guarda `pesos`, `valores` y `capacidad`.

El óptimo se calcula al crear el problema: por programación dinámica si los pesos y la capacidad
son enteros, o por fuerza bruta si no y n <= 18. Si no se puede, queda en `NaN` y `[]`.

`datos/mochila_ejemplo.csv` trae 15 objetos de ejemplo con columnas `peso,valor`.
