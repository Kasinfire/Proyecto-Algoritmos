function info = info_pso()
% INFO_PSO  Datos del algoritmo para la interfaz y el reporte.

    info.id = 'pso';
    info.nombre = 'Enjambre de Particulas (PSO)';
    info.variante = ['PSO global (gbest) con inercia; binario con BPSO (sigmoide); ' ...
                     'permutacion con random keys'];
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
