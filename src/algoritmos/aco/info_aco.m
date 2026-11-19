function info = info_aco()
% INFO_ACO  Datos del algoritmo para la interfaz y el reporte.

    info.id = 'aco';
    info.nombre = 'Optimizacion por Colonia de Hormigas (ACO)';
    info.variante = ['Ant System elitista: feromona por bit en binario y por ' ...
                     'arista dirigida en permutaciones'];
    info.representaciones = {'binario', 'permutacion'};
end
