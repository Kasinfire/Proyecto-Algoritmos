function sigma = calcular_sigma(problema, params, t)
% CALCULAR_SIGMA  Desviacion de la mutacion gaussiana en la generacion t.
%
%   sigma = calcular_sigma(problema, params, t)
%
%   Baja linealmente de sigma_ini a sigma_fin, ambos como fraccion del rango
%   de cada variable: mucha exploracion al inicio y ajuste fino al final.
%   Regresa [] si la representacion no es continua.

    if ~strcmp(problema.representacion, 'continuo')
        sigma = [];
        return;
    end
    fraccion = params.sigma_ini + (params.sigma_fin - params.sigma_ini) * t / params.n_iteraciones;
    sigma = fraccion * (problema.ub - problema.lb);
end
