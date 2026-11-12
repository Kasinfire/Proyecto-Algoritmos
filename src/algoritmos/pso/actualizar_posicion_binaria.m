function X = actualizar_posicion_binaria(V)
% ACTUALIZAR_POSICION_BINARIA  Regla de posicion del PSO binario (BPSO).
%
%   X = actualizar_posicion_binaria(V)
%
%   x_ij = 1 si r < sigmoide(v_ij), con r ~ U(0,1); si no, x_ij = 0.
%   La velocidad no se suma a la posicion: es la probabilidad de que el bit valga 1.
%
%   Entradas:  V - velocidades (N x D)
%   Salidas:   X - posiciones binarias (N x D)

    probabilidad = 1 ./ (1 + exp(-V));
    X = double(rand(size(V)) < probabilidad);
end
