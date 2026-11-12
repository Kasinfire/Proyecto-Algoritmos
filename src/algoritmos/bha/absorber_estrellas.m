function [estrellas, fitness, n_absorbidas] = absorber_estrellas( ...
    estrellas, fitness, idx_bh, R, problema)
% Distancia de cada estrella al agujero negro:
%
%   d_i = sqrt( sum_j (x_ij - x_BH,j)^2 )
%
% Si d_i < R la estrella se absorbe y se crea otra aleatoria en su lugar.
%
% d_i = distancias(i),  x_BH = x_bh

x_bh = estrellas(idx_bh, :);
distancias = sqrt(sum((estrellas - x_bh).^2, 2));

absorbidas = distancias < R;
absorbidas(idx_bh) = false;

n_absorbidas = sum(absorbidas);

if n_absorbidas > 0
    nuevas = inicializar_estrellas(n_absorbidas, problema.lb, problema.ub);
    estrellas(absorbidas, :) = nuevas;
    fitness(absorbidas) = evaluar_estrellas(problema.f, nuevas);
end
end
