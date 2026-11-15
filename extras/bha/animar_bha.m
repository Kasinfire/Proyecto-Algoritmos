function animar_bha(resultado, pausa)
% Animacion de las estrellas moviendose sobre las curvas de nivel (dim 2).
% Cada cuadro es una iteracion. El circulo rojo es el horizonte de eventos R.
%
%   animar_bha(resultado)
%   animar_bha(resultado, 0.05)    % segundos entre cuadros

    if nargin < 2
        pausa = 0.05;
    end

    problema = resultado.problema;
    if problema.dim ~= 2
        warning('animar_bha:dim', 'Solo se puede animar con dim = 2.');
        return;
    end

    [X1, X2, Z] = malla_funcion(problema, 150);

    fig = figure('Name', 'Animacion BHA');
    ax = axes(fig);
    contourf(ax, X1, X2, Z, 25, 'LineStyle', 'none');
    colormap(ax, parula);
    axis(ax, 'equal', 'tight');
    xlabel(ax, 'x_1'); ylabel(ax, 'x_2');
    hold(ax, 'on');

    h_est = plot(ax, NaN, NaN, 'wo', 'MarkerFaceColor', 'w', 'MarkerSize', 5);
    h_bh  = plot(ax, NaN, NaN, 'kp', 'MarkerFaceColor', 'k', 'MarkerSize', 14);
    h_r   = plot(ax, NaN, NaN, 'r-', 'LineWidth', 1.5);
    ang  = linspace(0, 2 * pi, 60);

    n_cuadros = size(resultado.historial_estrellas, 3);
    for k = 1:n_cuadros
        if ~isvalid(fig), return; end

        est = resultado.historial_estrellas(:, :, k);
        x_bh = resultado.historial_bh(k, :);
        R   = resultado.historial_radio(k);

        set(h_est, 'XData', est(:, 1), 'YData', est(:, 2));
        set(h_bh,  'XData', x_bh(1),    'YData', x_bh(2));
        set(h_r,   'XData', x_bh(1) + R * cos(ang), 'YData', x_bh(2) + R * sin(ang));
        title(ax, sprintf('Iteracion %d   f_{BH} = %.3e', k - 1, resultado.curva(k)));

        drawnow;
        pause(pausa);
    end
end
