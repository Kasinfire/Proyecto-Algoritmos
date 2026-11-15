function h = pantalla_comparar(padre, ejecuciones, opciones)
% PANTALLA_COMPARAR  Compara las ejecuciones guardadas (HTML en uihtml).
%   h = pantalla_comparar(padre, ejecuciones)
%   h = pantalla_comparar(padre, ejecuciones, elegida=6, al_volver=@() ...)
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   ejecuciones  : struct array con numero (como se guardo) y resultado (lo que regresa
%                  el algoritmo)
%   elegida      : numero de la ejecucion que se ve primero (0 = la ultima)
%   al_volver    : se llama sin argumentos al presionar Volver
%   al_ir_a_paso : se llama con 0..4 al presionar un paso del riel
%
%   Solo se comparan ejecuciones en las mismas condiciones: mismo problema, dimension,
%   sentido, limites y datos. Las demas aparecen desactivadas con el motivo.
%   Exportar comparacion abre un dialogo para guardar con exportar_comparacion.
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        ejecuciones struct
        opciones.elegida (1,1) double = 0
        opciones.al_volver function_handle = @() []
        opciones.al_ir_a_paso function_handle = @(paso) []
    end

    carpeta_web = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'comparar.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, ejecuciones, opciones);
end

function atender(h, evento, ejecuciones, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            sendEventToHTMLSource(h, 'datos', datos_comparar(ejecuciones, opciones.elegida));
        case 'exportar'
            elegidas = ejecuciones(ismember([ejecuciones.numero], datos.numeros));
            exportar(h, elegidas);
        case 'volver'
            opciones.al_volver();
        case 'ir_a_paso'
            opciones.al_ir_a_paso(datos.paso);
    end
end

function exportar(h, elegidas)
    if isempty(elegidas)
        return;
    end
    nombre = lower(regexprep(elegidas(1).resultado.problema.nombre, '[^A-Za-z0-9]+', '_'));
    [archivo, carpeta] = uiputfile({'*.csv', 'CSV (*.csv)'; '*.json', 'JSON (*.json)'}, ...
        'Guardar comparación', ['comparacion_' strip(nombre, '_') '.csv']);
    figure(ancestor(h, 'figure'));
    if isequal(archivo, 0)
        return;
    end
    ruta = fullfile(carpeta, archivo);
    try
        exportar_comparacion(elegidas, ruta);
        aviso = struct('texto', sprintf('Guardado en %s', ruta), 'ok', true);
    catch err
        aviso = struct('texto', err.message, 'ok', false);
    end
    sendEventToHTMLSource(h, 'exportado', aviso);
end

function datos = datos_comparar(ejecuciones, elegida)
    numeros = [ejecuciones.numero];
    if ~ismember(elegida, numeros)
        elegida = numeros(end);
    end
    grupos = agrupar(ejecuciones);
    lista = cell(1, numel(ejecuciones));
    for k = 1:numel(ejecuciones)
        lista{k} = datos_ejecucion(ejecuciones(k).numero, ejecuciones(k).resultado, grupos(k));
    end
    datos = struct('ejecuciones', {[lista{:}]}, 'elegida', elegida, ...
        'n_guardadas', numel(ejecuciones));
end

% Ejecuciones con las mismas condiciones del problema quedan en el mismo grupo.
function grupos = agrupar(ejecuciones)
    grupos = zeros(1, numel(ejecuciones));
    condiciones = {};
    for k = 1:numel(ejecuciones)
        p = ejecuciones(k).resultado.problema;
        c = struct('nombre', p.nombre, 'representacion', p.representacion, 'dim', p.dim, ...
            'sentido', p.sentido, 'lb', p.lb, 'ub', p.ub, 'datos', p.datos);
        j = find(cellfun(@(otra) isequaln(otra, c), condiciones), 1);
        if isempty(j)
            condiciones{end + 1} = c; %#ok<AGROW>
            j = numel(condiciones);
        end
        grupos(k) = j;
    end
end

function e = datos_ejecucion(numero, resultado, grupo)
    p = resultado.problema;
    id = lower(resultado.algoritmo);
    e = struct( ...
        'numero', numero, ...
        'algoritmo', algoritmo_para_ui(id), ...
        'problema', struct('nombre', p.nombre, 'dim', p.dim, 'sentido', p.sentido, ...
            'representacion', p.representacion, 'f_optimo', {numeros_para_js(p.f_optimo)}), ...
        'grupo', grupo, ...
        'parametros', {parametros_resumen(id, p.representacion, resultado.params)}, ...
        'mejor_valor', {numeros_para_js(resultado.mejor_valor)}, ...
        'iteraciones', resultado.iteraciones, ...
        'n_iteraciones', resultado.params.n_iteraciones, ...
        'semilla', resultado.params.semilla, ...
        'evaluaciones', resultado.evaluaciones, ...
        'motivo', resultado.motivo_termino, ...
        'convergencia', {numeros_para_js(resultado.historial.mejor_valor)});
end
