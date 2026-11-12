function fig = graficar_convergencia(curvas, etiquetas, opciones)
% GRAFICAR_CONVERGENCIA  Mejor valor encontrado contra iteracion.
%
%   graficar_convergencia(curva)
%   graficar_convergencia({curva1, curva2}, {'BHA', 'PSO'}, titulo="Rastrigin")
%   graficar_convergencia(curvas, etiquetas, sentido="max", f_optimo=1, ax=app.ejes)
%
%   curvas    : vector o celda de vectores; el elemento 1 es la iteracion 0
%   etiquetas : celda con el nombre de cada curva (opcional)
%   Opciones:
%     titulo     : titulo de la grafica
%     sentido    : 'min' o 'max'
%     f_optimo   : si se conoce, se dibuja como linea punteada
%     etiqueta_y : texto del eje y
%     ax         : ejes donde dibujar; si se omite se crea una figura nueva
%
%   En minimizacion con valores no negativos se usa escala log, porque las
%   curvas se acercan a 0 y en escala lineal no se distinguen al final.
%   Como log(0) no existe, la curva se corta donde llega a 0 y se marca ese punto.

    arguments
        curvas
        etiquetas = {}
        opciones.titulo = 'Convergencia'
        opciones.sentido {mustBeMember(opciones.sentido, {'min', 'max'})} = 'min'
        opciones.f_optimo (1,1) double = NaN
        opciones.etiqueta_y = 'Mejor valor encontrado'
        opciones.ax = []
    end

    if ~iscell(curvas)
        curvas = {curvas};
    end
    if isempty(etiquetas)
        etiquetas = arrayfun(@(k) sprintf('Curva %d', k), 1:numel(curvas), ...
                             'UniformOutput', false);
    end

    if isempty(opciones.ax)
        fig = figure('Name', opciones.titulo, 'Color', 'w');
        ax = axes(fig);
    else
        ax = opciones.ax;
        fig = ancestor(ax, 'figure');
        cla(ax);
    end
    hold(ax, 'on');

    todos = vertcat(curvas{:});
    usar_log = strcmp(opciones.sentido, 'min') && all(todos(isfinite(todos)) >= 0);

    lineas = gobjects(numel(curvas), 1);
    for k = 1:numel(curvas)
        c = curvas{k}(:);
        iters = (0:numel(c) - 1)';

        ceros = [];
        if usar_log
            ceros = find(c <= 0, 1);
            if ~isempty(ceros)
                c(ceros:end) = NaN;
            end
        end

        lineas(k) = plot(ax, iters, c, 'LineWidth', 1.8);

        if ~isempty(ceros) && ceros > 1
            plot(ax, iters(ceros - 1), c(ceros - 1), 'o', ...
                 'Color', lineas(k).Color, 'MarkerFaceColor', lineas(k).Color);
            text(ax, iters(ceros - 1), c(ceros - 1), ...
                 sprintf('  f = 0 en iter %d', iters(ceros)), ...
                 'VerticalAlignment', 'bottom');
        end
    end

    if ~isnan(opciones.f_optimo) && ~(usar_log && opciones.f_optimo <= 0)
        yline(ax, opciones.f_optimo, '--k', 'Optimo');
    end
    hold(ax, 'off');

    if usar_log
        ax.YScale = 'log';
        ax.YMinorGrid = 'off';
        ax.YMinorTick = 'off';
    else
        ax.YScale = 'linear';
    end
    grid(ax, 'on');
    ax.GridAlpha = 0.2;
    box(ax, 'on');
    xlim(ax, [0, max(max(cellfun(@numel, curvas)) - 1, 1)]);
    xlabel(ax, 'Iteracion');
    ylabel(ax, opciones.etiqueta_y);
    title(ax, opciones.titulo);
    legend(ax, lineas, etiquetas, 'Location', 'best');
end
