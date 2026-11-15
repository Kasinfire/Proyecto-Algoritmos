function info = info_ga()
% INFO_GA  Datos del algoritmo para la interfaz y el reporte.

    info.id = 'ga';
    info.nombre = 'Algoritmo Genético (GA)';
    info.variante = ['GA generacional con elitismo; continuo: BLX-alfa o aritmética y ' ...
                     'mutación gaussiana; binario: un punto o uniforme y bit-flip; ' ...
                     'permutación: OX y swap o inversión'];
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
