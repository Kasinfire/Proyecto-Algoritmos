function guardar_figura(fig, nombre_base, config)
%GUARDAR_FIGURA  Guarda una figura como PNG en la carpeta de resultados.
%
%   GUARDAR_FIGURA(fig, nombre_base, config) reemplaza los espacios del nombre
%   por guiones bajos para obtener un nombre de archivo válido.
%
%   Entradas:
%       fig        - Handle de la figura.
%       nombre_base - Nombre del archivo sin extensión.
%       config     - Configuración (usa carpeta_resultados).

    nombre_archivo = [strrep(nombre_base, ' ', '_') '.png'];
    saveas(fig, fullfile(config.carpeta_resultados, nombre_archivo));
end
