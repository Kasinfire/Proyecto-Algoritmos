function h = pantalla_problema(padre, tipo, opciones)
% PANTALLA_PROBLEMA  Pantalla 2 del flujo: elegir el problema y sus datos (HTML en uihtml).
%   h = pantalla_problema(padre, tipo)
%   h = pantalla_problema(padre, 'continuo', al_continuar=@(problema) ..., al_regresar=@() ...)
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   tipo         : 'continuo', 'binario', 'permutacion' o 'real' (lo elegido en el
%                  paso 1). 'real' es el horario del semestre: lo atiende pantalla_horario.
%   al_continuar : se llama con el struct problema (crear_problema) y la configuracion
%                  que mando el HTML al presionar Siguiente. La configuracion sirve como
%                  seleccion para restaurar la pantalla despues.
%   al_regresar  : se llama sin argumentos al presionar Regresar o el paso 1 del riel
%   al_comparar  : se llama sin argumentos al presionar el boton de comparar
%   seleccion    : lo que se eligio antes, para restaurarlo (al volver del paso 3):
%                  continuo -> id, dim, lb, ub y sentido
%                  binario  -> id y dim (OneMax) o pesos, valores y capacidad (mochila)
%                  permutacion -> id, dim y semilla (al azar) o x e y (de un CSV)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)
%
%   h : el componente uihtml. Requiere MATLAB R2023a o mas reciente.
%
%   Los problemas binarios y de permutacion usan su propia pagina: en vez de rango y
%   superficie se editan los objetos de la mochila o los bits de OneMax
%   (problema_binario.html), o las ciudades del TSP (problema_tsp.html).

    arguments
        padre
        tipo {mustBeMember(tipo, {'continuo', 'binario', 'permutacion', 'real'})}
        opciones.al_continuar function_handle = @(problema, config) []
        opciones.al_regresar function_handle = @() []
        opciones.al_comparar function_handle = @() []
        opciones.seleccion struct = struct()
        opciones.n_guardadas (1,1) double = 0
    end

    if strcmp(tipo, 'real')
        argumentos = namedargs2cell(opciones);
        h = pantalla_horario(padre, argumentos{:});
        return;
    end

    carpeta_web = ruta_proyecto('src', 'ui', 'web');
    paginas = struct('continuo', 'problema.html', 'binario', 'problema_binario.html', ...
                     'permutacion', 'problema_tsp.html');
    pagina = paginas.(tipo);
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
                switch tipo
                    case 'binario'
                        problema = armar_problema_binario(datos);
                    case 'permutacion'
                        problema = armar_problema_permutacion(datos);
                    otherwise
                        problema = armar_problema(datos);
                end
            catch err
                sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
                return;
            end
            opciones.al_continuar(problema, datos);
        case 'regresar'
            opciones.al_regresar();
        case 'ir_a_paso'
            if datos.paso == 0, opciones.al_regresar(); end
        case 'comparar'
            opciones.al_comparar();
        case 'cargar_csv'
            if strcmp(tipo, 'permutacion')
                cargar_ciudades(h);
            else
                cargar_objetos(h);
            end
        case 'generar'
            [x, y] = ciudades_al_azar(datos.dim, datos.semilla);
            sendEventToHTMLSource(h, 'ciudades', struct('x', x, 'y', y, ...
                'dim', datos.dim, 'semilla', datos.semilla, 'archivo', ''));
    end
end

% Los objetos de la mochila desde un CSV; la capacidad se queda como estaba.
function cargar_objetos(h)
    ruta = elegir_csv(h, 'Objetos de la mochila');
    if isempty(ruta), return; end
    try
        [pesos, valores] = leer_objetos_csv(ruta);
    catch err
        sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
        return;
    end
    sendEventToHTMLSource(h, 'objetos', struct('pesos', pesos, 'valores', valores));
end

function cargar_ciudades(h)
    ruta = elegir_csv(h, 'Ciudades del TSP');
    if isempty(ruta), return; end
    try
        [x, y] = leer_ciudades_csv(ruta);
    catch err
        sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
        return;
    end
    [~, nombre, extension] = fileparts(ruta);
    sendEventToHTMLSource(h, 'ciudades', struct('x', x, 'y', y, ...
        'dim', numel(x), 'semilla', [], 'archivo', [nombre extension]));
end

% Ruta del CSV elegido, o '' si se cancelo.
function ruta = elegir_csv(h, titulo)
    carpeta_datos = ruta_proyecto('datos');
    [archivo, carpeta] = uigetfile({'*.csv', 'CSV (*.csv)'}, titulo, [carpeta_datos filesep]);
    figure(ancestor(h, 'figure'));
    if isequal(archivo, 0)
        ruta = '';
    else
        ruta = fullfile(carpeta, archivo);
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
