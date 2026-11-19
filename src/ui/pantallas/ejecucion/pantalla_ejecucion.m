function h = pantalla_ejecucion(padre, problema, id, params, opciones)
% PANTALLA_EJECUCION  Pantalla 4 del flujo: corre el algoritmo y reproduce la busqueda (HTML en uihtml).
%   h = pantalla_ejecucion(padre, problema, 'pso', params)
%   h = pantalla_ejecucion(padre, problema, 'pso', params, al_ver_resultados=@(resultado) ...)
%
%   padre             : uifigure, uipanel o uigridlayout donde se dibuja
%   problema          : struct de crear_problema (lo armado en el paso 2)
%   id, params        : algoritmo ('pso', ...) y parametros elegidos en el paso 3
%   al_ver_resultados : se llama con el struct resultado al presionar Ver resultados. Si se
%                       presiono Detener, el resultado termina en esa iteracion.
%   al_regresar       : se llama sin argumentos al presionar Regresar o el paso 3 del riel
%   al_ir_a_paso      : se llama con 0 (tipo) o 1 (problema) al presionar esos pasos del riel
%   al_comparar       : se llama sin argumentos al presionar el boton de comparar
%   n_guardadas       : ejecuciones guardadas (contador del boton de comparar)
%   tipo, config      : lo elegido en los pasos 1 y 2. Con 'real' (el horario) la pantalla
%                       dibuja el mejor horario de cada iteracion en vez del mapa
%
%   El algoritmo corre completo en MATLAB al abrir la pantalla y el HTML solo reproduce
%   resultado.historial; por eso se puede pausar, adelantar y regresar.
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        problema struct
        id {mustBeTextScalar}
        params struct
        opciones.al_ver_resultados function_handle = @(resultado) []
        opciones.al_regresar function_handle = @() []
        opciones.al_ir_a_paso function_handle = @(paso) []
        opciones.al_comparar function_handle = @() []
        opciones.n_guardadas (1,1) double = 0
        opciones.tipo char = ''
        opciones.config struct = struct()
    end

    carpeta_web = ruta_proyecto('src', 'ui', 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'ejecucion.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, problema, char(id), params, opciones);
end

function atender(h, evento, problema, id, params, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            try
                resultado = feval(id, problema, params);
            catch err
                sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
                return;
            end
            h.UserData = resultado;
            datos = datos_ejecucion(resultado, id, opciones.n_guardadas);
            if strcmp(opciones.tipo, 'real') && isfield(opciones.config, 'secciones')
                datos.horario = horario_para_ui(opciones.config, resultado.historial.mejor_solucion);
            end
            sendEventToHTMLSource(h, 'datos', datos);
        case 'resultados'
            resultado = h.UserData;
            if datos.iteracion < resultado.iteraciones
                % Misma semilla, misma busqueda: se repite cortando en la iteracion elegida.
                resultado = feval(id, problema, params, @(estado) estado.iteracion >= datos.iteracion);
            end
            opciones.al_ver_resultados(resultado);
        case 'regresar'
            opciones.al_regresar();
        case 'ir_a_paso'
            if datos.paso == 2
                opciones.al_regresar();
            else
                opciones.al_ir_a_paso(datos.paso);
            end
        case 'comparar'
            opciones.al_comparar();
    end
end

function datos = datos_ejecucion(resultado, id, n_guardadas)
    problema = resultado.problema;
    hist = resultado.historial;
    [cuadros, paso] = muestra_poblacion(hist.poblacion, min(2, problema.dim));

    if strcmp(problema.representacion, 'continuo')
        lb = problema.lb(1);
        ub = problema.ub(1);
    else
        lb = [];
        ub = [];
    end

    % Del mejor solo se muestran tres coordenadas; la distancia al optimo se calcula aqui
    % para no mandar las dim columnas de cada iteracion.
    if numel(problema.x_optimo) == problema.dim
        distancia = redondear(vecnorm(hist.mejor_solucion - problema.x_optimo, 2, 2));
    else
        distancia = [];
    end

    if strcmp(problema.representacion, 'continuo')
        mapa = mapa_de_busqueda(problema, resultado.mejor_solucion);
    else
        mapa = struct('tipo', 'ninguno');
    end

    datos = struct( ...
        'algoritmo', algoritmo_para_ui(id), ...
        'problema', struct('nombre', problema.nombre, 'dim', problema.dim, ...
            'lb', lb, 'ub', ub, 'sentido', problema.sentido, ...
            'representacion', problema.representacion, ...
            'f_optimo', problema.f_optimo, 'x_optimo', problema.x_optimo), ...
        'parametros', parametros_resumen(id, problema.representacion, resultado.params), ...
        'iteraciones', resultado.iteraciones, ...
        'motivo', resultado.motivo_termino, ...
        'historial', struct( ...
            'mejor_valor', {numeros_para_js(hist.mejor_valor)}, ...
            'mejor_solucion', {num2cell(redondear(hist.mejor_solucion(:, 1:min(3, end))), 2)}, ...
            'distancia', {distancia}, ...
            'poblacion', {cuadros}, ...
            'paso_poblacion', paso, ...
            'n_individuos', size(hist.poblacion{1}, 1)), ...
        'mapa', mapa, ...
        'n_guardadas', n_guardadas);
end

function [cuadros, paso] = muestra_poblacion(poblacion, n_ejes)
% Con 1000 individuos y 10000 iteraciones el historial completo pesa cientos de MB y
% uihtml no lo aguanta. Se manda a lo mas MAX_INDIVIDUOS por iteracion (siempre los
% mismos, para que la animacion siga a cada uno) y, si aun no cabe en MAX_PUNTOS, una
% iteracion cada `paso` mas la ultima. A esa velocidad de reproduccion no se nota.
    MAX_INDIVIDUOS = 500;
    MAX_PUNTOS = 3e5;
    n = numel(poblacion);
    por_cuadro = min(max(cellfun(@(P) size(P, 1), poblacion)), MAX_INDIVIDUOS);
    paso = max(1, ceil(n * por_cuadro / MAX_PUNTOS));
    indices = unique([1:paso:n, n]);
    cuadros = cell(numel(indices), 1);
    for k = 1:numel(indices)
        P = poblacion{indices(k)};
        filas = unique(round(linspace(1, size(P, 1), min(size(P, 1), MAX_INDIVIDUOS))));
        cuadros{k} = redondear(P(filas, 1:n_ejes));
    end
end

function v = redondear(v)
    v = round(v, 6, 'significant');
end
