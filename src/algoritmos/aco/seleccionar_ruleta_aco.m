function indice = seleccionar_ruleta_aco(pesos)
% SELECCIONAR_RULETA_ACO  Elige una alternativa proporcional a sus pesos.
%   indice = seleccionar_ruleta_aco(pesos)

    pesos(~isfinite(pesos) | pesos < 0) = 0;
    total = sum(pesos);
    if total <= 0
        indice = randi(numel(pesos));
        return;
    end
    indice = find(rand * total < cumsum(pesos), 1, 'first');
    if isempty(indice), indice = numel(pesos); end
end
