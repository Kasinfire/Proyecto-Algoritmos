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
%   seleccion    : lo que se eligio antes, para restaurarlo (al volver del paso 3):
%                  continuo -> id, dim, lb, ub y sentido
%                  binario  -> id y dim (OneMax) o pesos, valores y capacidad (mochila)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)
%
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.
%
%   Los problemas binarios usan su propia pagina (problema_binario.html): en vez de
%   rango y superficie se editan los objetos de la mochila o los bits de OneMax.

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
    if strcmp(tipo, 'binario')
        pagina = 'problema_binario.html';
    else
        pagina = 'problema.html';
    end
    h = uihtml(padre, 'HTMLSource', fullfile(carpeta_web, pagina));
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
                if strcmp(tipo, 'binario')
                    problema = armar_problema_binario(datos);
                else
                    problema = armar_problema(datos);
                end
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
        case 'cargar_csv'
            cargar_csv(h);
    end
end

% Los objetos de la mochila desde un CSV; la capacidad se queda como estaba.
function cargar_csv(h)
    carpeta_datos = fullfile(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))), 'datos');
    [archivo, carpeta] = uigetfile({'*.csv', 'CSV (*.csv)'}, 'Objetos de la mochila', ...
                                   [carpeta_datos filesep]);
    figure(ancestor(h, 'figure'));
    if isequal(archivo, 0), return; end
    try
        [pesos, valores] = leer_objetos_csv(fullfile(carpeta, archivo));
    catch err
        sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
        return;
    end
    sendEventToHTMLSource(h, 'objetos', struct('pesos', pesos, 'valores', valores));
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
