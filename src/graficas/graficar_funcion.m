function fig = graficar_funcion(resultado)
% Muestra la forma de la funcion (solo dim 2) y el camino que siguio
% el agujero negro.
%
% Izquierda: superficie z = f(x1, x2)
% Derecha:   curvas de nivel, estrellas finales y trayectoria de x_BH

    problema = resultado.problema;
    if problema.dim ~= 2
        warning('graficar_funcion:dim', 'Solo se puede graficar con dim = 2.');
        fig = [];
        return;
    end

    [X1, X2, Z] = malla_funcion(problema, 150);

    fig = figure('Name', ['Funcion ' problema.nombre], 'Position', [100 100 1100 450]);
    t = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact');
    title(t, sprintf('%s  (mejor f = %.3e)', problema.nombre, resultado.mejor_fitness));

    % Superficie
    ax1 = nexttile(t);
    surf(ax1, X1, X2, Z, 'EdgeColor', 'none');
    hold(ax1, 'on');
    x_bh = resultado.mejor_posicion;
    plot3(ax1, x_bh(1), x_bh(2), resultado.mejor_fitness, 'rp', ...
          'MarkerSize', 16, 'MarkerFaceColor', 'r');
    hold(ax1, 'off');
    colormap(ax1, parula);
    xlabel(ax1, 'x_1'); ylabel(ax1, 'x_2'); zlabel(ax1, 'f(x)');
    title(ax1, 'Superficie');
    view(ax1, -35, 40);
    axis(ax1, 'tight');

    % Curvas de nivel con la trayectoria
    ax2 = nexttile(t);
    contourf(ax2, X1, X2, Z, 25, 'LineStyle', 'none');
    hold(ax2, 'on');
    camino = resultado.historial_bh;
    est = resultado.historial_estrellas(:, :, end);
    plot(ax2, est(:, 1), est(:, 2), 'wo', 'MarkerSize', 5);
    plot(ax2, camino(:, 1), camino(:, 2), 'r.-', 'LineWidth', 1.5);
    plot(ax2, camino(1, 1), camino(1, 2), 'ks', 'MarkerSize', 9, 'MarkerFaceColor', 'w');
    plot(ax2, x_bh(1), x_bh(2), 'rp', 'MarkerSize', 16, 'MarkerFaceColor', 'r');
    hold(ax2, 'off');
    colormap(ax2, parula);
    colorbar(ax2);
    axis(ax2, 'equal', 'tight');
    xlabel(ax2, 'x_1'); ylabel(ax2, 'x_2');
    title(ax2, 'Camino del agujero negro');
    legend(ax2, {'', 'estrellas (final)', 'x_{BH}(t)', 'inicio', 'mejor'}, ...
           'Location', 'southoutside', 'Orientation', 'horizontal');
end
