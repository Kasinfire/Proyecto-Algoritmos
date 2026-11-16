function h = pantalla_tipo(padre, opciones)
% PANTALLA_TIPO  Pantalla 1 del flujo: elegir el tipo de problema (HTML en uihtml).
%   h = pantalla_tipo(padre)
%   h = pantalla_tipo(padre, al_continuar=@(tipo) ..., seleccionado='continuo')
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   al_continuar : se llama con el id del tipo ('continuo', 'binario' o
%                  'permutacion') cuando el usuario presiona Siguiente
%   al_comparar  : se llama sin argumentos al presionar el boton de comparar
%   seleccionado : tipo marcado al abrir (por ejemplo al regresar del paso 2)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)
%
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.

    arguments
        padre
        opciones.al_continuar function_handle = @(tipo) []
        opciones.al_comparar function_handle = @() []
        opciones.seleccionado char = ''
        opciones.n_guardadas (1,1) double = 0
    end

    carpeta_web = ruta_proyecto('src', 'ui', 'web');
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, 'tipo.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(h, evento, opciones);
end

function atender(h, evento, opciones)
    datos = evento.HTMLEventData;
    switch evento.HTMLEventName
        case 'lista'
            sendEventToHTMLSource(h, 'datos', struct( ...
                'tipos', tipos_de_problema(), ...
                'seleccionado', opciones.seleccionado, ...
                'n_guardadas', opciones.n_guardadas));
        case 'siguiente'
            opciones.al_continuar(datos.tipo);
        case 'comparar'
            opciones.al_comparar();
    end
end
