function estrellas = mover_estrellas(estrellas, idx_bh)
% Mueve cada estrella hacia el agujero negro:
%
%   x_i(t+1) = x_i(t) + r * (x_BH - x_i(t)),   r ~ U(0,1)
%
% x_i = estrellas(i,:),  x_BH = x_bh,  r = r(i)
% El agujero negro no se mueve (r = 0).

n = size(estrellas, 1);
x_bh = estrellas(idx_bh, :);

r = rand(n, 1);
r(idx_bh) = 0;

estrellas = estrellas + r .* (x_bh - estrellas);
end
