function R = radio_horizonte(fitness, idx_bh)
% Radio del horizonte de eventos:
%
%            |f_BH|
%       R = ---------
%           sum |f_i|
%
% f_BH = fitness(idx_bh),  sum |f_i| = total
% Si total = 0 se regresa R = 0 para no dividir entre cero.

    total = sum(abs(fitness));
    if total == 0
        R = 0;
    else
        R = abs(fitness(idx_bh)) / total;
    end
end
