function V = actualizar_velocidad(V, X, pbest, gbest, params, vmax)
%ACTUALIZAR_VELOCIDAD  Aplica la ecuación de velocidad del PSO.
%
%   V = ACTUALIZAR_VELOCIDAD(V, X, pbest, gbest, params, vmax)
%
%   Ecuación:
%       v(t+1) = w*v(t) + c1*r1*(pbest - x) + c2*r2*(gbest - x)
%
%       w*v(t)              -> inercia: mantiene la dirección anterior.
%       c1*r1*(pbest - x)   -> componente cognitiva: "lo que yo aprendí".
%       c2*r2*(gbest - x)   -> componente social: "lo que aprendió el grupo".
%       r1, r2              -> números aleatorios uniformes en [0, 1],
%                              distintos por partícula y por dimensión.
%
%   Entradas:
%       V, X   - Velocidades y posiciones actuales (N x D).
%       pbest  - Mejores posiciones personales (N x D).
%       gbest  - Mejor posición global (1 x D).
%       params - Estructura con los campos w, c1 y c2.
%       vmax   - Velocidad máxima por dimensión (1 x D).
%
%   Salida:
%       V - Velocidades nuevas, limitadas a [-vmax, vmax] para evitar que
%           las partículas "exploten" fuera del dominio.

    r1 = rand(size(X));
    r2 = rand(size(X));

    inercia   = params.w  * V;
    cognitivo = params.c1 * r1 .* (pbest - X);
    social    = params.c2 * r2 .* (gbest - X);

    V = inercia + cognitivo + social;
    V = max(min(V, vmax), -vmax);
end
