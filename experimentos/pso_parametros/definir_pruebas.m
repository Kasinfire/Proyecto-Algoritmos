function pruebas = definir_pruebas()
%DEFINIR_PRUEBAS  Define las combinaciones de parámetros a comparar.
%
%   pruebas = DEFINIR_PRUEBAS() devuelve un arreglo de estructuras; cada
%   elemento es una prueba con su propia inercia y coeficientes.
%
%   Campos de cada prueba:
%       nombre - Identificador corto de la prueba (P1, P2, ...).
%       desc   - Qué se quiere observar con esa prueba.
%       w      - Inercia: cuánto conserva la partícula su velocidad previa.
%                Alta -> más exploración; baja -> más explotación.
%       c1     - Coeficiente cognitivo: atracción hacia la mejor posición
%                personal de cada partícula (pbest).
%       c2     - Coeficiente social: atracción hacia la mejor posición
%                encontrada por todo el enjambre (gbest).
%
%   Diseño: P1 es la configuración base; P2 y P3 solo cambian w; P4 y P5
%   solo cambian el balance c1/c2. P6 es la configuración clásica de la
%   literatura (Clerc y Kennedy, 2002) como referencia.

    pruebas = struct( ...
        'nombre', {'P1', 'P2', 'P3', 'P4', 'P5', 'P6'}, ...
        'desc',   {'Base', 'Inercia alta', 'Inercia baja', ...
                   'Cognitivo dominante', 'Social dominante', ...
                   'Clásica (constricción)'}, ...
        'w',      {0.70, 0.90, 0.40, 0.70, 0.70, 0.729}, ...
        'c1',     {1.50, 1.50, 1.50, 2.50, 0.50, 1.49445}, ...
        'c2',     {1.50, 1.50, 1.50, 0.50, 2.50, 1.49445});
end
