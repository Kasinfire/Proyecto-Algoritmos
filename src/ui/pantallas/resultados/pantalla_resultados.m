function h = pantalla_resultados(padre, resultado, opciones)
% PANTALLA_RESULTADOS  Pantalla 5 del flujo: resumen de una ejecucion terminada (HTML en uihtml).
%   h = pantalla_resultados(padre, resultado)
%   h = pantalla_resultados(padre, resultado, numero=6, al_comparar=@() ...)
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   resultado    : struct que regresa el algoritmo (lo que entrega la pantalla de ejecucion)
%   numero       : numero con el que se guardo la ejecucion para comparar (0 = sin guardar)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar del riel)
%   al_nueva_ejecucion : se llama sin argumentos al presionar Nueva ejecucion (el Reiniciar
%                        del enunciado): la app regresa al paso 3 con la misma configuracion
%   al_comparar  : se llama sin argumentos al presionar Comparar ejecuciones
%   al_ir_a_paso : se llama con 0..3 al presionar un paso del riel
%   tipo, config : lo elegido en los pasos 1 y 2. Con 'real' (el horario) la pantalla
%                  muestra el horario final, sus bits y los NRC para inscribirse
%
%   Los botones CSV y JSON abren un dialogo para guardar con exportar_resultado.
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        resultado struct
        opciones.numero (1,1) double = 0
        opciones.n_guardadas (1,1) double = 0
        opciones.al_nueva_ejecucion function_handle = @() []
        opciones.al_comparar function_handle = @() []
        opciones.al_ir_a_paso function_handle = @(paso) []
        opciones.tipo char = ''
        opciones.config struct = struct()
    end

    carpeta_web = ruta_proyecto('src', 'ui', 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'resultados.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, resultado, opciones);
end

function atender(h, evento, resultado, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            datos = datos_resultados(resultado, opciones);
            if strcmp(opciones.tipo, 'real') && isfield(opciones.config, 'secciones')
                datos.horario = horario_para_ui(opciones.config, resultado.mejor_solucion);
            end
            sendEventToHTMLSource(h, 'datos', datos);
        case 'copiar'
            clipboard('copy', datos.texto);
            sendEventToHTMLSource(h, 'exportado', struct('texto', ...
                sprintf('NRC copiados: %s', datos.texto), 'ok', true));
        case 'exportar'
            exportar(h, resultado, opciones.numero, datos.formato);
        case 'nueva_ejecucion'
            opciones.al_nueva_ejecucion();
        case 'comparar'
            opciones.al_comparar();
        case 'ir_a_paso'
            opciones.al_ir_a_paso(datos.paso);
    end
end

function exportar(h, resultado, numero, formato)
    extension = ['.' lower(char(formato))];
    [archivo, carpeta] = uiputfile(['*' extension], 'Guardar ejecución', ...
        [nombre_archivo(resultado, numero) extension]);
    figure(ancestor(h, 'figure'));
    if isequal(archivo, 0)
        return;
    end
    ruta = fullfile(carpeta, archivo);
    try
        exportar_resultado(resultado, ruta);
        aviso = struct('texto', sprintf('Guardado en %s', ruta), 'ok', true);
    catch err
        aviso = struct('texto', err.message, 'ok', false);
    end
    sendEventToHTMLSource(h, 'exportado', aviso);
end

% ejecucion_06_pso_rastrigin
function nombre = nombre_archivo(resultado, numero)
    problema = lower(regexprep(resultado.problema.nombre, '[^A-Za-z0-9]+', '_'));
    nombre = sprintf('%s_%s', lower(resultado.algoritmo), strip(problema, '_'));
    if numero > 0
        nombre = sprintf('ejecucion_%02d_%s', numero, nombre);
    end
end

function datos = datos_resultados(resultado, opciones)
    problema = resultado.problema;
    hist = resultado.historial;
    id = lower(resultado.algoritmo);
    n_ejes = min(2, problema.dim);

    if strcmp(problema.representacion, 'continuo')
        mapa = mapa_de_busqueda(problema, resultado.mejor_solucion);
    else
        mapa = struct('tipo', 'ninguno');
    end

    datos = struct( ...
        'algoritmo', algoritmo_para_ui(id), ...
        'problema', struct('nombre', problema.nombre, 'dim', problema.dim, ...
            'sentido', problema.sentido, 'representacion', problema.representacion, ...
            'f_optimo', problema.f_optimo, 'x_optimo', problema.x_optimo), ...
        'parametros', parametros_resumen(id, problema.representacion, resultado.params), ...
        'mejor_valor', {numeros_para_js(resultado.mejor_valor)}, ...
        'mejor_solucion', round(resultado.mejor_solucion(1:min(3, end)), 6, 'significant'), ...
        'iteraciones', resultado.iteraciones, ...
        'motivo', resultado.motivo_termino, ...
        'evaluaciones', resultado.evaluaciones, ...
        'tiempo', resultado.tiempo, ...
        'convergencia', {numeros_para_js(hist.mejor_valor)}, ...
        'mejoras', mejoras(hist), ...
        'inicio', muestra(hist.poblacion{1}(:, 1:n_ejes)), ...
        'ruta', ruta_del_mejor(hist.mejor_solucion(:, 1:n_ejes)), ...
        'mapa', mapa, ...
        'numero', opciones.numero, ...
        'n_guardadas', opciones.n_guardadas);
end

% Iteraciones donde mejoro el mejor valor, para la pestana Historial. Con miles de
% mejoras se manda una muestra pareja (siempre con la primera y la ultima).
function m = mejoras(hist)
    MAX_FILAS = 300;
    v = hist.mejor_valor(:);
    filas = find([true; v(2:end) ~= v(1:end - 1)]);
    total = numel(filas);
    if total > MAX_FILAS
        filas = filas(unique(round(linspace(1, total, MAX_FILAS))));
    end
    m = struct('iteracion', filas - 1, ...
        'valor', {numeros_para_js(v(filas))}, ...
        'solucion', {num2cell(round(hist.mejor_solucion(filas, 1:min(3, end)), 6, 'significant'), 2)}, ...
        'total', total);
end

% Posiciones por donde paso la mejor solucion (solo cuando cambio de lugar).
function ruta = ruta_del_mejor(X)
    cambia = [true; any(diff(X, 1, 1) ~= 0, 2)];
    ruta = round(X(cambia, :), 6, 'significant');
end

% La poblacion inicial, a lo mas 500 soluciones (con mas no se distinguen en el mapa).
function P = muestra(P)
    MAX_PUNTOS = 500;
    filas = unique(round(linspace(1, size(P, 1), min(size(P, 1), MAX_PUNTOS))));
    P = round(P(filas, :), 6, 'significant');
end
