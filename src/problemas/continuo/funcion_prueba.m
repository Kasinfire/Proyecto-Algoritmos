function problema = funcion_prueba(nombre, dim)
% FUNCION_PRUEBA  Devuelve una funcion de prueba continua lista para optimizar.
%
%   problema = funcion_prueba(nombre, dim)
%   nombres  = funcion_prueba('lista')
%
%   Nombre        Sentido  Tipo         Rango            Optimo
%   ----------    -------  ----------   --------------   ------------------------
%   'esfera'      min      unimodal     [-100, 100]      f = 0 en x = (0,...,0)
%   'rosenbrock'  min      unimodal*    [-30, 30]        f = 0 en x = (1,...,1)
%   'rastrigin'   min      multimodal   [-5.12, 5.12]    f = 0 en x = (0,...,0)
%   'ackley'      min      multimodal   [-32, 32]        f = 0 en x = (0,...,0)
%   'griewank'    min      multimodal   [-600, 600]      f = 0 en x = (0,...,0)
%   'schwefel'    min      multimodal   [-500, 500]      f = 0 en x = (420.9687,...)
%   'zakharov'    min      unimodal     [-5, 10]         f = 0 en x = (0,...,0)
%   'lineal'      max      monotona     [0, 3]           f = 5D en x = (0,...,0)
%   'exponencial' max      unimodal     [-3, 3]          f = 1 en x = (0,...,0)
%
%   Formulas (D = numel(x)):
%   esfera:      sum x_j^2
%   rosenbrock:  sum 100(x_{j+1} - x_j^2)^2 + (x_j - 1)^2
%   rastrigin:   10D + sum x_j^2 - 10cos(2 pi x_j)
%   ackley:      -20 exp(-0.2 sqrt(mean x_j^2)) - exp(mean cos(2 pi x_j)) + 20 + e
%   griewank:    sum x_j^2 / 4000 - prod cos(x_j / sqrt(j)) + 1
%   schwefel:    418.9829 D - sum x_j sin(sqrt|x_j|)
%   zakharov:    sum x_j^2 + (sum 0.5 x_j)^2 + (sum 0.5 x_j)^4
%   lineal:      sum (-2 x_j + 5)
%   exponencial: exp(-sum x_j^2)

    if nargin < 2
        dim = 2;
    end

    if strcmpi(nombre, 'lista')
        problema = {'esfera', 'rosenbrock', 'rastrigin', 'ackley', 'griewank', ...
                    'schwefel', 'zakharov', 'lineal', 'exponencial'};
        return;
    end

    switch lower(nombre)
        case 'esfera'
            f = @(x) sum(x.^2);
            problema = crear_problema('Esfera', f, -100, 100, dim, f_optimo=0, x_optimo=0);

        case 'rosenbrock'
            f = @(x) sum(100 * (x(2:end) - x(1:end-1).^2).^2 ...
                         + (x(1:end-1) - 1).^2);
            problema = crear_problema('Rosenbrock', f, -30, 30, dim, f_optimo=0, x_optimo=1);

        case 'rastrigin'
            f = @(x) 10 * numel(x) + sum(x.^2 - 10 * cos(2 * pi * x));
            problema = crear_problema('Rastrigin', f, -5.12, 5.12, dim, f_optimo=0, x_optimo=0);

        case 'ackley'
            f = @(x) -20 * exp(-0.2 * sqrt(mean(x.^2))) ...
                     - exp(mean(cos(2 * pi * x))) + 20 + exp(1);
            problema = crear_problema('Ackley', f, -32, 32, dim, f_optimo=0, x_optimo=0);

        case 'griewank'
            f = @(x) sum(x.^2) / 4000 ...
                     - prod(cos(x ./ sqrt(1:numel(x)))) + 1;
            problema = crear_problema('Griewank', f, -600, 600, dim, f_optimo=0, x_optimo=0);

        case 'schwefel'
            f = @(x) 418.9829 * numel(x) - sum(x .* sin(sqrt(abs(x))));
            problema = crear_problema('Schwefel', f, -500, 500, dim, f_optimo=0, x_optimo=420.9687);

        case 'zakharov'
            f = @(x) sum(x.^2) + sum(0.5 * x)^2 + sum(0.5 * x)^4;
            problema = crear_problema('Zakharov', f, -5, 10, dim, f_optimo=0, x_optimo=0);

        case 'lineal'
            f = @(x) sum(-2 * x + 5);
            problema = crear_problema('Lineal', f, 0, 3, dim, ...
                                      sentido='max', f_optimo=5 * dim, x_optimo=0);

        case 'exponencial'
            f = @(x) exp(-sum(x.^2));
            problema = crear_problema('Exponencial', f, -3, 3, dim, ...
                                      sentido='max', f_optimo=1, x_optimo=0);

        otherwise
            error('funcion_prueba:nombre', ...
                  'No conozco la funcion "%s". Usa funcion_prueba(''lista'').', ...
                  nombre);
    end
end
