function info = info_de()
% INFO_DE  Datos del algoritmo para la interfaz y el reporte.

    info.id = 'de';
    info.nombre = 'Evolución Diferencial (DE)';
    info.variante = ['DE rand/1/bin o best/1/bin; binario por umbral (x > 0.5) ' ...
                     'y permutación con random keys'];
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
