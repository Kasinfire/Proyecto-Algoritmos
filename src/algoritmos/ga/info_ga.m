function info = info_ga()
% INFO_GA  Datos del algoritmo para la interfaz y el reporte.

    info.id = 'ga';
    info.nombre = 'Algoritmo Genetico (GA)';
    info.variante = ['GA generacional con elitismo; continuo: BLX-alfa o aritmetica y ' ...
                     'mutacion gaussiana; binario: un punto o uniforme y bit-flip; ' ...
                     'permutacion: OX y swap o inversion'];
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
