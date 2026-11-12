function graficar_espacio_busqueda(problema, pruebas, resultados_prueba, config)
%GRAFICAR_ESPACIO_BUSQUEDA  Muestra dónde terminó el enjambre en cada prueba.
%
%   GRAFICAR_ESPACIO_BUSQUEDA(problema, pruebas, resultados_prueba, config)
%   crea una figura con un panel por prueba. Cada panel dibuja la función
%   y encima la posición final de las partículas (primera repetición), la
%   mejor solución encontrada y el óptimo conocido.
%
%   Permite ver visualmente si el enjambre se concentró en el óptimo
%   (convergió), quedó disperso (exploración) o se atoró en un óptimo local.
%
%   Entradas:
%       problema          - Función evaluada.
%       pruebas          - Arreglo de pruebas (títulos de los paneles).
%       resultados_prueba - Celda; cada elemento contiene las ejecuciones
%                          de una prueba.
%       config           - Configuración (carpeta de resultados).

    n_pruebas = numel(pruebas);
    n_columnas = 3;
    n_filas = ceil(n_pruebas / n_columnas);

    fig = figure('Name', ['Espacio de búsqueda - ' problema.nombre], ...
                 'Color', 'w', 'Position', [100 100 1200 350 * n_filas]);

    for i_p = 1:n_pruebas
        subplot(n_filas, n_columnas, i_p);
        resultado = resultados_prueba{i_p}(1);

        if problema.dim == 1
            dibujar_panel_1d(problema, resultado);
        else
            dibujar_panel_2d(problema, resultado);
        end

        p = pruebas(i_p);
        title(sprintf('%s: w=%.2f, c_1=%.2f, c_2=%.2f', p.nombre, p.w, p.c1, p.c2));
    end

    sgtitle({['Posición final del enjambre - ' problema.nombre], ...
             'o = partículas,  estrella roja = mejor encontrado,  x negra = óptimo conocido'});
    guardar_figura(fig, ['espacio_' problema.nombre], config);
end

% -------------------------------------------------------------------------
function dibujar_panel_1d(problema, resultado)
%DIBUJAR_PANEL_1D  Curva f(x) con las partículas finales sobre ella.
    x = linspace(problema.lb, problema.ub, 500);
    y = arrayfun(problema.f, x);

    hold on; grid on; box on;
    plot(x, y, 'k-', 'LineWidth', 1.2);

    xp = resultado.historial.poblacion{end};
    plot(xp, arrayfun(problema.f, xp), 'o', 'MarkerSize', 5, ...
         'MarkerFaceColor', [0.3 0.6 1], 'MarkerEdgeColor', 'none');
    plot(problema.x_optimo, problema.f_optimo, 'kx', 'MarkerSize', 14, 'LineWidth', 2);
    plot(resultado.mejor_solucion, resultado.mejor_valor, 'p', ...
         'MarkerSize', 14, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');

    xlabel('x'); ylabel('f(x)');
    hold off;
end

% -------------------------------------------------------------------------
function dibujar_panel_2d(problema, resultado)
%DIBUJAR_PANEL_2D  Curvas de nivel de f(x,y) con las partículas finales.
    n = 200;
    xv = linspace(problema.lb(1), problema.ub(1), n);
    yv = linspace(problema.lb(2), problema.ub(2), n);
    [XX, YY] = meshgrid(xv, yv);

    ZZ = zeros(size(XX));
    for k = 1:numel(XX)
        ZZ(k) = problema.f([XX(k), YY(k)]);
    end

    hold on; box on;
    contourf(XX, YY, ZZ, 30, 'LineColor', 'none');
    colormap(parula); colorbar;

    P = resultado.historial.poblacion{end};
    plot(P(:, 1), P(:, 2), 'wo', 'MarkerSize', 5, 'MarkerFaceColor', 'w');
    plot(problema.x_optimo(1), problema.x_optimo(2), 'kx', ...
         'MarkerSize', 14, 'LineWidth', 2);
    plot(resultado.mejor_solucion(1), resultado.mejor_solucion(2), 'p', ...
         'MarkerSize', 14, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k');

    xlabel('x'); ylabel('y');
    axis([problema.lb(1) problema.ub(1) problema.lb(2) problema.ub(2)]);
    hold off;
end
