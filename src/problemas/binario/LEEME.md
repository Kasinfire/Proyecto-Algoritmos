# Problemas binarios: por implementar
Responsable: bloque D. OneMax y/o mochila (pesos, valores y capacidad configurables). Datos en datos/.

## Lo que espera la interfaz
La pantalla 2 (`src/ui/pantallas/problema/armar_problema_binario.m`) llama a estas dos funciones con
los datos que escribió el usuario, ya validados. Las dos regresan el struct de `crear_problema`:

```matlab
problema = onemax(n)                             % n bits
problema = mochila(pesos, valores, capacidad)    % vectores fila 1 x n y un escalar
```

- `representacion='binario'`, `sentido='max'` y `sentido_fijo=true`.
- OneMax: `f_optimo=n` y `x_optimo=ones(1, n)`.
- Mochila: `datos=struct('pesos', pesos, 'valores', valores, 'capacidad', capacidad)`. La
  forma de tratar las soluciones que se pasan de la capacidad (penalización o reparación)
  la decide este bloque; conviene explicarla en `descripcion`.

Mientras los archivos no existan, la pantalla deja editar los datos pero no deja continuar.

