function U = cruza_binomial(X, V, tasa_cr)
% CRUZA_BINOMIAL  Mezcla cada vector con su mutante (cruza binomial de DE).
%
%   U = cruza_binomial(X, V, tasa_cr)
%
%   u_ij = v_ij si rand < CR o j es el gen forzado de la fila; si no, x_ij.
%   El gen forzado (uno al azar por fila) asegura que U(i,:) difiere de X(i,:).
%
%   Entradas:  X - vectores objetivo (N x D);  V - mutantes (N x D);  tasa_cr - CR
%   Salida:    U - vectores de prueba (N x D)

    [N, D] = size(X);
    del_mutante = rand(N, D) < tasa_cr;
    del_mutante(sub2ind([N, D], (1:N)', randi(D, N, 1))) = true;
    U = X;
    U(del_mutante) = V(del_mutante);
end
