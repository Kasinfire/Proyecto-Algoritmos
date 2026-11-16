function h = pantalla_horario(padre, opciones)
% PANTALLA_HORARIO  Pantalla 2 para el problema real: armar el horario del semestre.
%   h = pantalla_horario(padre, al_regresar=@() ..., n_guardadas=0)
%
%   Tiene tres subpasos en la misma pagina (horario.html): 1 Oferta, 2 Materias y
%   3 Preferencias. Oferta consulta SIIAU (consultar_oferta_siiau) o lee una pagina guardada
%   (leer_oferta_guardada); Materias elige que materias entran al problema y Preferencias
%   dice como se quiere el horario. La oferta, las claves y las preferencias se quedan aqui,
%   en MATLAB; al terminar se arma el problema con horario_materias (src/problemas/real).
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   al_continuar : se llama con el problema armado y la configuracion al terminar:
%                  claves, preferencias (como las manda la pantalla), secciones (las que
%                  son bits, en el orden de x, con sesiones de secciones_para_ui), materias
%                  (clave, nombre y color con que se dibujan) y datos (problema.datos)
%   al_regresar  : se llama sin argumentos al presionar Regresar o el paso 1 del riel
%   al_comparar  : se llama sin argumentos al presionar el boton de comparar
%   seleccion    : lo elegido antes (reservado para restaurar al volver del paso 3)
%   n_guardadas  : ejecuciones guardadas (contador del boton de comparar)

    arguments
        padre
        opciones.al_continuar function_handle = @(problema, config) []
        opciones.al_regresar function_handle = @() []
        opciones.al_comparar function_handle = @() []
        opciones.seleccion struct = struct()
        opciones.n_guardadas (1,1) double = 0
    end

    raiz = fileparts(fileparts(fileparts(fileparts(mfilename('fullpath')))));
    ejemplo = fullfile('datos', 'siiau', 'oferta_info_202620.html');
    catalogo = opciones_siiau();
    oferta = struct('secciones', struct([]), 'sin_horario', struct([]));
    claves = strings(1, 0);
    colores = strings(1, 0);
    preferencias = struct();

    h = uihtml(padre, 'HTMLSource', fullfile(raiz, 'src', 'ui', 'web', 'horario.html'));
    if isa(padre, 'matlab.ui.container.GridLayout')
        h.Layout.Row = 1;
        h.Layout.Column = 1;
    else
        h.Position = [0 0 padre.Position(3:4)];
    end
    h.HTMLEventReceivedFcn = @(~, evento) atender(evento);

    function atender(evento)
        datos = evento.HTMLEventData;
        switch evento.HTMLEventName
            case 'lista'
                sendEventToHTMLSource(h, 'datos', struct( ...
                    'ciclos', catalogo.ciclos, 'centros', catalogo.centros, ...
                    'carreras', catalogo.carreras, 'defecto', catalogo.defecto, ...
                    'ejemplo', strrep(ejemplo, filesep, '/'), ...
                    'seleccion', opciones.seleccion, 'n_guardadas', opciones.n_guardadas));
            case 'consultar'
                consultar(datos);
            case 'abrir_guardada'
                [archivos, carpeta] = uigetfile({'*.html;*.htm', 'Página de SIIAU (*.html)'}, ...
                    'Consulta de oferta guardada', [fullfile(raiz, 'datos') filesep], 'MultiSelect', 'on');
                figure(ancestor(h, 'figure'));
                if isequal(archivos, 0)
                    sendEventToHTMLSource(h, 'cancelado', struct());
                    return;
                end
                leer_archivos(fullfile(carpeta, cellstr(archivos)));
            case 'usar_ejemplo'
                leer_archivos({fullfile(raiz, ejemplo)});
            case 'materias'
                claves = string(datos.claves(:)');
                if isfield(datos, 'colores'), colores = string(datos.colores(:)'); end
            case 'preferencias'
                preferencias = datos;
                preferencias.dias_libres = logical(datos.dias_libres(:)');
            case 'siguiente'
                continuar();
            case 'regresar'
                opciones.al_regresar();
            case 'ir_a_paso'
                if datos.paso == 0, opciones.al_regresar(); end
            case 'comparar'
                opciones.al_comparar();
        end
    end

    function consultar(datos)
        n_secciones = 0;
        try
            paginas = consultar_oferta_siiau(datos.ciclo, datos.centro, datos.carrera, ...
                solo_disponibles=logical(datos.solo_cupo), al_leer_pagina=@avisar_pagina);
            oferta = leer_oferta_siiau(paginas);
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
            return;
        end
        info = struct('ciclo', datos.ciclo, 'centro', datos.centro, ...
            'carrera', upper(datos.carrera), 'paginas', numel(paginas));
        detalle = sprintf('%d %s de SIIAU · %s', info.paginas, ...
            plural(info.paginas, 'página', 'páginas'), ...
            char(datetime('now', 'Format', 'dd/MM/yyyy HH:mm')));
        enviar_oferta(info, detalle);

        function avisar_pagina(k, html)
            pagina = leer_oferta_siiau({html});
            n_secciones = n_secciones + numel(pagina.secciones) + numel(pagina.sin_horario);
            enviar_y_dibujar('progreso', struct('pagina', k, 'secciones', n_secciones));
        end
    end

    function leer_archivos(rutas)
        try
            oferta = leer_oferta_guardada(rutas);
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
            return;
        end
        [~, nombre, extension] = fileparts(rutas{1});
        archivo = [nombre extension];
        if numel(rutas) > 1, archivo = sprintf('%d archivos', numel(rutas)); end
        detalle = sprintf('%s · %d %s guardadas', archivo, oferta.paginas, ...
            plural(oferta.paginas, 'página', 'páginas'));
        enviar_oferta(oferta, detalle);
    end

    function enviar_oferta(info, detalle)
        sendEventToHTMLSource(h, 'oferta', struct( ...
            'secciones', [secciones_para_ui(oferta.secciones), oferta.sin_horario], ...
            'titulo', titulo_de(info, catalogo), ...
            'detalle', detalle, ...
            'paginas', info.paginas));
    end

    % Solo entran las secciones con horario de las materias elegidas: cada una es un bit.
    function continuar()
        try
            problema = horario_materias(oferta, cellstr(claves), preferencias_del_problema(preferencias));
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
            return;
        end
        elegidas = secciones_para_ui(problema.datos.secciones);
        opciones.al_continuar(problema, struct('claves', claves, 'preferencias', preferencias, ...
            'secciones', elegidas, 'materias', materias_de(elegidas), 'datos', problema.datos));
    end

    function materias = materias_de(elegidas)
        materias = struct('clave', {}, 'nombre', {}, 'color', {});
        for k = 1:numel(claves)
            s = elegidas(strcmp({elegidas.clave}, claves(k)));
            if isempty(s), continue; end
            color = '';
            if k <= numel(colores), color = char(colores(k)); end
            materias(end + 1) = struct('clave', char(claves(k)), 'nombre', s(1).materia, 'color', color); %#ok<AGROW>
        end
    end

    function enviar_y_dibujar(nombre, datos)
        sendEventToHTMLSource(h, nombre, datos);
        drawnow;
    end
end

function texto = titulo_de(info, catalogo)
    partes = {nombre_en(catalogo.centros, info.centro), info.carrera, nombre_ciclo(info.ciclo)};
    texto = strjoin(partes(~cellfun(@isempty, partes)), ' · ');
end

function nombre = nombre_en(lista, id)
    nombre = id;
    k = find(strcmp({lista.id}, id), 1);
    if ~isempty(k), nombre = lista(k).nombre; end
end

function nombre = nombre_ciclo(ciclo)
    nombre = ciclo;
    t = regexp(ciclo, '^\d{2}(\d{2})(10|20)$', 'tokens', 'once');
    if isempty(t), return; end
    letras = struct('x10', 'A', 'x20', 'B');
    nombre = sprintf('Calendario %s %s', t{1}, letras.(['x' t{2}]));
end

% La pantalla dice entrada, salida y solo_cupo; horario_materias, hora_min, hora_max y
% solo_disponibles. Los valores por defecto son los que muestra la pantalla al abrir.
function p = preferencias_del_problema(preferencias)
    p = struct('hora_min', 9, 'hora_max', 19, 'dias_libres', false(1, 6), 'peso_muertas', 1, ...
        'max_materias_dia', 3, 'max_horas_seguidas', 4, 'solo_disponibles', true);
    nombres = {'entrada', 'hora_min'; 'salida', 'hora_max'; 'dias_libres', 'dias_libres';
               'peso_muertas', 'peso_muertas'; 'max_materias_dia', 'max_materias_dia';
               'max_horas_seguidas', 'max_horas_seguidas'; 'solo_cupo', 'solo_disponibles'};
    for k = 1:size(nombres, 1)
        if isfield(preferencias, nombres{k, 1})
            p.(nombres{k, 2}) = double(preferencias.(nombres{k, 1}));
        end
    end
end

function texto = plural(n, uno, varios)
    if n == 1, texto = uno; else, texto = varios; end
end
