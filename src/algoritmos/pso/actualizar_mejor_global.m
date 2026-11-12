function [gbest, gbest_costo] = actualizar_mejor_global(pbest, pbest_costo, gbest, gbest_costo)
%ACTUALIZAR_MEJOR_GLOBAL  Actualiza la mejor posición conocida por el enjambre.
%
%   [gbest, gbest_costo] = ACTUALIZAR_MEJOR_GLOBAL(pbest, pbest_costo, gbest, gbest_costo)
%
%   Busca la mejor de todas las posiciones personales; si es mejor que la
%   gbest actual, la reemplaza. Esta es la información que se "comparte"
%   con todo el enjambre a través del coeficiente social c2.
%
%   Entradas:
%       pbest, pbest_costo - Mejores posiciones personales y su costo.
%       gbest, gbest_costo - Mejor posición global actual y su costo.
%
%   Salidas:
%       gbest, gbest_costo - Valores actualizados.

    [mejor_costo, idx] = min(pbest_costo);
    if mejor_costo < gbest_costo
        gbest_costo = mejor_costo;
        gbest      = pbest(idx, :);
    end
end
