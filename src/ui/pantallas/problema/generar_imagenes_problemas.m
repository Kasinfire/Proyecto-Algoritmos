function generar_imagenes_problemas(opciones)
% GENERAR_IMAGENES_PROBLEMAS  Guarda las graficas de las funciones continuas como PNG.
%   generar_imagenes_problemas()             solo crea las que faltan
%   generar_imagenes_problemas(forzar=true)  las vuelve a crear todas
%
%   Se guardan en src/ui/web/problema/imagenes/: <id>.png (grande, con ejes) y
%   <id>_mini.png (miniatura de la lista). Las funciones que se plantean en 1D se
%   dibujan como curva y el resto como superficie en 2D. Se generan una vez y se suben al repo,
%   asi la pantalla 2 abre al instante.

    arguments
        opciones.forzar (1,1) logical = false
    end

    puntos_por_eje = 150;
    carpeta = ruta_proyecto('src', 'ui', 'web', 'problema', 'imagenes');
    if ~isfolder(carpeta), mkdir(carpeta); end

    for id = funcion_prueba('lista')
        grande = fullfile(carpeta, [id{1} '.png']);
        mini = fullfile(carpeta, [id{1} '_mini.png']);
        if ~opciones.forzar && isfile(grande) && isfile(mini), continue; end

        dim = limites_problema(id{1}).dim_defecto;
        problema = funcion_prueba(id{1}, dim);
        if dim == 1
            dibujar = @(ax) dibujar_curva(ax, problema, 10 * puntos_por_eje);
        else
            [X1, X2, Z] = malla_funcion(problema, puntos_por_eje);
            dibujar = @(ax) dibujar_superficie(ax, X1, X2, Z);
        end
        guardar(dibujar, grande, [0 0 900 640], true);
        guardar(dibujar, mini, [0 0 160 120], false);
    end
end

function dibujar_curva(ax, problema, n)
    x = linspace(problema.lb, problema.ub, n);
    y = arrayfun(problema.f, x);
    plot(ax, x, y, 'LineWidth', 2, 'Color', [0 0.447 0.741]);
    axis(ax, 'tight');
    xlabel(ax, 'x');
    ylabel(ax, 'f(x)');
end

function dibujar_superficie(ax, X1, X2, Z)
    surf(ax, X1, X2, Z, 'EdgeColor', 'none');
    colormap(ax, parula);
    view(ax, -37.5, 30);
    axis(ax, 'tight');
    xlabel(ax, 'x_1');
    ylabel(ax, 'x_2');
    zlabel(ax, 'f(x)');
end

function guardar(dibujar, archivo, posicion, con_ejes)
    fig = figure('Visible', 'off', 'Position', posicion, 'Color', 'w');
    limpiar = onCleanup(@() close(fig));
    if ~isMATLABReleaseOlderThan('R2025a'), theme(fig, 'light'); end

    ax = axes(fig);
    dibujar(ax);

    if con_ejes
        set(ax, 'FontName', 'Helvetica', 'FontSize', 11, 'Color', 'w');
        grid(ax, 'on');
        exportgraphics(fig, archivo, 'Resolution', 144, 'BackgroundColor', 'white');
    else
        axis(ax, 'off');
        exportgraphics(fig, archivo, 'Resolution', 96, 'BackgroundColor', 'white');
    end
end
