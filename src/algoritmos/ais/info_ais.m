function info = info_ais()
% INFO_AIS  Datos de CLONALG para la interfaz y el reporte.

    info.id = 'ais';
    info.nombre = 'Sistema Inmune Artificial (AIS)';
    info.variante = ['CLONALG: seleccion de los mejores, clonacion proporcional, ' ...
                     'hipermutacion inversa a la afinidad y reemplazo aleatorio'];
    info.representaciones = {'continuo', 'binario', 'permutacion'};
end
