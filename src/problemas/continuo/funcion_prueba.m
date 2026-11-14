function problema = funcion_prueba(nombre, dim)
% FUNCION_PRUEBA  Devuelve una funcion de prueba continua lista para optimizar.
%
%   problema = funcion_prueba(nombre, dim)
%   nombres  = funcion_prueba('lista')
%
%   Nombre        Sentido  Dim   Rango            Optimo
%   ----------    -------  ----  --------------   ---------------------------------
%   'parabolica'  max      nD    [-3, 3]          f = 4 en x = (0,...,0)
%   'seno'        max      nD    [0, 1]           f = 2D en x = (0.05,...,0.05)
%   'lineal'      max      nD    [0, 3]           f = 5D en x = (0,...,0)
%   'exponencial' max      nD    [-3, 3]          f = 1 en x = (0,...,0)
%   'coseno'      max      nD    [-3, 3]          f = 3D en x = (0,...,0)
%   'esfera'      min      nD    [-100, 100]      f = 0 en x = (0,...,0)
%   'rastrigin'   min      nD    [-5.12, 5.12]    f = 0 en x = (0,...,0)
%   'himmelblau'  min      2     [-6, 6]          f = 0 en x = (3, 2) y otros tres
%   'ackley'      min      nD    [-5, 5]          f = 0 en x = (0,...,0)
%   'schwefel'    min      nD    [-500, 500]      f = 0 en x = (420.9687,...)
%   'eggholder'   min      2     [-512, 512]      f = -959.6407 en x = (512, 404.2319)
%   'griewank'    min      nD    [-600, 600]      f = 0 en x = (0,...,0)
%   'rosenbrock'  min      nD    [-2, 2]          f = 0 en x = (1,...,1)
%   'michalewicz' min      nD    [0, pi]          f = -1.8013 en x = (2.2029, 1.5708) si D = 2
%   'levy'        min      nD    [-10, 10]        f = 0 en x = (1,...,1)
%   'zakharov'    min      nD    [-5, 10]         f = 0 en x = (0,...,0)
%
%   Formulas (D = numel(x)):
%   parabolica:  4 - sum x_j^2
%   seno:        sum sin(10 pi x_j) + 1
%   lineal:      sum -2 x_j + 5
%   exponencial: exp(-sum x_j^2)
%   coseno:      sum cos(5 x_j) + 2
%   esfera:      sum x_j^2
%   rastrigin:   10D + sum x_j^2 - 10cos(2 pi x_j)
%   himmelblau:  (x1^2 + x2 - 11)^2 + (x1 + x2^2 - 7)^2
%   ackley:      -20 exp(-0.2 sqrt(mean x_j^2)) - exp(mean cos(2 pi x_j)) + 20 + e
%   schwefel:    418.9829 D - sum x_j sin(sqrt|x_j|)
%   eggholder:   -(x2 + 47) sin(sqrt|x1/2 + x2 + 47|) - x1 sin(sqrt|x1 - (x2 + 47)|)
%   griewank:    sum x_j^2 / 4000 - prod cos(x_j / sqrt(j)) + 1
%   rosenbrock:  sum 100(x_{j+1} - x_j^2)^2 + (x_j - 1)^2
%   michalewicz: -sum sin(x_j) sin(j x_j^2 / pi)^(2m), con m = 10
%   levy:        sin^2(pi w_1) + sum (w_j - 1)^2 (1 + 10 sin^2(pi w_j + 1))
%                + (w_D - 1)^2 (1 + sin^2(2 pi w_D)), con w_j = 1 + (x_j - 1)/4
%   zakharov:    sum x_j^2 + (sum 0.5 x_j)^2 + (sum 0.5 x_j)^4

    if nargin < 2
        dim = 2;
    end

    if strcmpi(nombre, 'lista')
        problema = {'parabolica', 'seno', 'lineal', 'exponencial', 'coseno', ...
                    'esfera', 'rastrigin', 'himmelblau', 'ackley', 'schwefel', ...
                    'eggholder', 'griewank', 'rosenbrock', 'michalewicz', 'levy', ...
                    'zakharov'};
        return;
    end

    switch lower(nombre)
        case 'parabolica'
            f = @(x) 4 - sum(x.^2);
            problema = crear_problema('Parabólica', f, -3, 3, dim, ...
                                      sentido='max', f_optimo=4, x_optimo=0);

        case 'seno'
            f = @(x) sum(sin(10 * pi * x) + 1);
            problema = crear_problema('Seno oscilante', f, 0, 1, dim, ...
                                      sentido='max', f_optimo=2 * dim, x_optimo=0.05);

        case 'lineal'
            f = @(x) sum(-2 * x + 5);
            problema = crear_problema('Lineal', f, 0, 3, dim, ...
                                      sentido='max', f_optimo=5 * dim, x_optimo=0);

        case 'exponencial'
            f = @(x) exp(-sum(x.^2));
            problema = crear_problema('Exponencial', f, -3, 3, dim, ...
                                      sentido='max', f_optimo=1, x_optimo=0);

        case 'coseno'
            f = @(x) sum(cos(5 * x) + 2);
            problema = crear_problema('Coseno desplazado', f, -3, 3, dim, ...
                                      sentido='max', f_optimo=3 * dim, x_optimo=0);

        case 'esfera'
            f = @(x) sum(x.^2);
            problema = crear_problema('Esfera', f, -100, 100, dim, f_optimo=0, x_optimo=0);

        case 'rastrigin'
            f = @(x) 10 * numel(x) + sum(x.^2 - 10 * cos(2 * pi * x));
            problema = crear_problema('Rastrigin', f, -5.12, 5.12, dim, f_optimo=0, x_optimo=0);

        case 'himmelblau'
            exigir_dim(nombre, dim, 2);
            f = @(x) (x(1)^2 + x(2) - 11)^2 + (x(1) + x(2)^2 - 7)^2;
            problema = crear_problema('Himmelblau', f, -6, 6, dim, f_optimo=0, x_optimo=[3 2]);

        case 'ackley'
            f = @(x) -20 * exp(-0.2 * sqrt(mean(x.^2))) ...
                     - exp(mean(cos(2 * pi * x))) + 20 + exp(1);
            problema = crear_problema('Ackley', f, -5, 5, dim, f_optimo=0, x_optimo=0);

        case 'schwefel'
            f = @(x) 418.9829 * numel(x) - sum(x .* sin(sqrt(abs(x))));
            problema = crear_problema('Schwefel', f, -500, 500, dim, f_optimo=0, x_optimo=420.9687);

        case 'eggholder'
            exigir_dim(nombre, dim, 2);
            f = @(x) -(x(2) + 47) * sin(sqrt(abs(x(1) / 2 + x(2) + 47))) ...
                     - x(1) * sin(sqrt(abs(x(1) - (x(2) + 47))));
            problema = crear_problema('Eggholder', f, -512, 512, dim, ...
                                      f_optimo=-959.6407, x_optimo=[512 404.2319]);

        case 'griewank'
            f = @(x) sum(x.^2) / 4000 ...
                     - prod(cos(x ./ sqrt(1:numel(x)))) + 1;
            problema = crear_problema('Griewank', f, -600, 600, dim, f_optimo=0, x_optimo=0);

        case 'rosenbrock'
            f = @(x) sum(100 * (x(2:end) - x(1:end-1).^2).^2 ...
                         + (x(1:end-1) - 1).^2);
            problema = crear_problema('Rosenbrock', f, -2, 2, dim, f_optimo=0, x_optimo=1);

        case 'michalewicz'
            m = 10;
            f = @(x) -sum(sin(x) .* sin((1:numel(x)) .* x.^2 / pi).^(2 * m));
            % El optimo solo se conoce con precision para D = 2.
            if dim == 2
                optimo = {-1.8013, [2.2029 1.5708]};
            else
                optimo = {NaN, []};
            end
            problema = crear_problema('Michalewicz', f, 0, pi, dim, ...
                                      f_optimo=optimo{1}, x_optimo=optimo{2});

        case 'levy'
            f = @levy;
            problema = crear_problema('Lévy', f, -10, 10, dim, f_optimo=0, x_optimo=1);

        case 'zakharov'
            f = @(x) sum(x.^2) + sum(0.5 * x)^2 + sum(0.5 * x)^4;
            problema = crear_problema('Zakharov', f, -5, 10, dim, f_optimo=0, x_optimo=0);

        otherwise
            error('funcion_prueba:nombre', ...
                  'No conozco la funcion "%s". Usa funcion_prueba(''lista'').', ...
                  nombre);
    end
end

function exigir_dim(nombre, dim, esperada)
    if dim ~= esperada
        error('funcion_prueba:dim', 'La funcion "%s" solo existe con dim = %d.', ...
              nombre, esperada);
    end
end

function y = levy(x)
    w = 1 + (x - 1) / 4;
    y = sin(pi * w(1))^2 ...
        + sum((w(1:end-1) - 1).^2 .* (1 + 10 * sin(pi * w(1:end-1) + 1).^2)) ...
        + (w(end) - 1)^2 * (1 + sin(2 * pi * w(end))^2);
end
