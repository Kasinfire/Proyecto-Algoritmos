function h = pantalla_algoritmo(padre, problema, opciones)
% PANTALLA_ALGORITMO  Pantalla 3 del flujo: elegir el algoritmo y sus parametros (HTML en uihtml).
%   h = pantalla_algoritmo(padre, problema)
%   h = pantalla_algoritmo(padre, problema, al_ejecutar=@(id, params) ..., al_regresar=@() ...)
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   problema     : struct de crear_problema (lo armado en el paso 2)
%   al_ejecutar  : se llama con el id del algoritmo ('pso', ...) y el struct params ya
%                  validado al presionar Ejecutar
%   al_regresar  : se llama sin argumentos al presionar Regresar o el paso 2 del riel
%   al_ir_a_tipo : se llama sin argumentos al presionar el paso 1 del riel
%   al_comparar  : se llama sin argumentos al presionar el boton de comparar
%   seleccion    : struct con id y valores (struct de parametros) para restaurar
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)
%
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        problema struct
        opciones.al_ejecutar function_handle = @(id, params) []
        opciones.al_regresar function_handle = @() []
        opciones.al_ir_a_tipo function_handle = @() []
        opciones.al_comparar function_handle = @() []
        opciones.seleccion struct = struct()
        opciones.n_guardadas (1,1) double = 0
    end

    carpeta_web = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'algoritmo.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, problema, opciones);
end

function atender(h, evento, problema, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            sendEventToHTMLSource(h, 'datos', datos_iniciales(problema, opciones));
        case 'ejecutar'
            try
                params = armar_parametros(datos.id, problema.representacion, datos.valores);
            catch err
                sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
                return;
            end
            opciones.al_ejecutar(datos.id, params);
        case 'regresar'
            opciones.al_regresar();
        case 'ir_a_paso'
            switch datos.paso
                case 0, opciones.al_ir_a_tipo();
                case 1, opciones.al_regresar();
            end
        case 'comparar'
            opciones.al_comparar();
    end
end

function datos = datos_iniciales(problema, opciones)
    datos = struct( ...
        'problema', struct('nombre', problema.nombre, ...
                           'representacion', problema.representacion, ...
                           'dim', problema.dim), ...
        'algoritmos', algoritmos_de_tipo(problema.representacion), ...
        'seleccion', opciones.seleccion, ...
        'n_guardadas', opciones.n_guardadas);
end
