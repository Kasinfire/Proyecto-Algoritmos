function mapa = mapa_de_busqueda(problema, centro, n)
% MAPA_DE_BUSQUEDA  Paisaje de f para dibujar la poblacion encima (pantallas de ejecucion y resultados).
%   mapa = mapa_de_busqueda(problema, centro)
%   mapa = mapa_de_busqueda(problema, centro, n)
%
%   problema : struct continuo de crear_problema
%   centro   : solucion 1 x dim; con dim > 2 el mapa es un corte por x1, x2 que deja
%              x3..xn fijos en sus valores
%   n        : puntos por eje (200 por defecto)
%   mapa     : struct con
%       tipo    : 'superficie' (dim >= 2) o 'curva' (dim = 1)
%       x, y    : [min max] de cada eje (en 'curva', y es el rango de f)
%       z       : [min max] de f en la imagen                      (superficie)
%       imagen  : PNG en data URI con f pintada en parula; la fila de arriba es x2 maximo
%       colores : parula en hex, de f minimo a f maximo, para la barra de color
%       corte   : true si dim > 2
%       curva   : struct con x y f muestreados                     (curva)

    if nargin < 3, n = 200; end

    if problema.dim == 1
        x = linspace(problema.lb, problema.ub, 4 * n);
        [f, y] = recortar(arrayfun(@(v) problema.f(v), x));
        mapa = struct('tipo', 'curva', 'x', [x(1) x(end)], 'y', y, ...
            'curva', struct('x', round(x, 6, 'significant'), 'f', round(f, 6, 'significant')));
        return;
    end

    x1 = linspace(problema.lb(1), problema.ub(1), n);
    x2 = linspace(problema.lb(2), problema.ub(2), n);
    punto = reshape(centro, 1, []);
    Z = zeros(n);
    for a = 1:n
        for b = 1:n
            punto(1:2) = [x1(b), x2(a)];
            Z(a, b) = problema.f(punto);
        end
    end

    [Z, z] = recortar(Z);
    paleta = parula(256);
    indice = 1 + round((Z - z(1)) / max(z(2) - z(1), eps) * 255);
    rgb = ind2rgb(flipud(indice), paleta);

    mapa = struct('tipo', 'superficie', 'x', x1([1 end]), 'y', x2([1 end]), 'z', z, ...
        'imagen', png_en_texto(rgb), 'colores', {hex(parula(9))}, 'corte', problema.dim > 2);
end

% Con rangos enormes f se desborda a Inf en parte del mapa; la escala se toma de los
% valores finitos y lo demas se pinta en la orilla de la escala.
function [v, rango] = recortar(v)
    finitos = v(isfinite(v));
    if isempty(finitos)
        rango = [0 1];
    else
        rango = [min(finitos) max(finitos)];
    end
    v(isnan(v)) = rango(2);
    v = min(max(v, rango(1)), rango(2));
end

function texto = png_en_texto(rgb)
    archivo = [tempname '.png'];
    limpiar = onCleanup(@() delete(archivo));
    imwrite(rgb, archivo);
    id = fopen(archivo, 'r');
    bytes = fread(id, Inf, '*uint8');
    fclose(id);
    texto = ['data:image/png;base64,' matlab.net.base64encode(bytes)];
end

function c = hex(colores)
    c = cellstr(compose('#%02X%02X%02X', round(colores * 255)))';
end
