function h = pantalla_problema(padre, tipo, opciones)
% PANTALLA_PROBLEMA  Pantalla 2 del flujo: elegir el problema y sus datos (HTML en uihtml).
%   h = pantalla_problema(padre, tipo)
%   h = pantalla_problema(padre, 'continuo', al_continuar=@(problema) ..., al_regresar=@() ...)
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   tipo         : 'continuo', 'binario' o 'permutacion' (lo elegido en el paso 1)
%   al_continuar : se llama con el struct problema (crear_problema) al presionar Siguiente
%   al_regresar  : se llama sin argumentos al presionar Regresar o el paso 1 del riel
%   al_comparar  : se llama sin argumentos al presionar el boton de comparar
%   seleccion    : struct con id, dim, lb, ub y sentido para restaurar (al volver del paso 3)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)
%
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        tipo {mustBeMember(tipo, {'continuo', 'binario', 'permutacion'})}
        opciones.al_continuar function_handle = @(problema) []
        opciones.al_regresar function_handle = @() []
        opciones.al_comparar function_handle = @() []
        opciones.seleccion struct = struct()
        opciones.n_guardadas (1,1) double = 0
    end

    carpeta_web = fullfile(fileparts(fileparts(mfilename('fullpath'))), 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'problema.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, char(tipo), opciones);
end

function atender(h, evento, tipo, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            sendEventToHTMLSource(h, 'datos', datos_iniciales(tipo, opciones));
        case 'siguiente'
            try
                problema = armar_problema(datos);
            catch err
                sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
                return;
            end
            opciones.al_continuar(problema);
        case 'regresar'
            opciones.al_regresar();
        case 'ir_a_paso'
            if datos.paso == 0, opciones.al_regresar(); end
        case 'comparar'
            opciones.al_comparar();
    end
end

function datos = datos_iniciales(tipo, opciones)
    tipos = tipos_de_problema();
    elegido = tipos(strcmp({tipos.id}, tipo));
    datos = struct( ...
        'tipo', struct('id', elegido.id, 'nombre', elegido.nombre, 'notacion', elegido.notacion), ...
        'problemas', problemas_de_tipo(tipo), ...
        'seleccion', opciones.seleccion, ...
        'n_guardadas', opciones.n_guardadas);
end
