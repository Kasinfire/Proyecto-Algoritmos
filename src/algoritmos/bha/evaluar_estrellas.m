function fitness = evaluar_estrellas(f, estrellas)
% Calcula el fitness de cada estrella:  f_i = f(x_i)
% x_i = estrellas(i,:),  f_i = fitness(i)

n = size(estrellas, 1);
fitness = zeros(n, 1);

for i = 1:n
    fitness(i) = f(estrellas(i, :));
end
end
