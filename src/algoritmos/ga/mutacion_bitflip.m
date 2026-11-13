function hijos = mutacion_bitflip(hijos, tasa)
% MUTACION_BITFLIP  Invierte cada bit con probabilidad tasa (binario).
%
%   hijos = mutacion_bitflip(hijos, tasa)

    mascara = rand(size(hijos)) < tasa;
    hijos(mascara) = 1 - hijos(mascara);
end
