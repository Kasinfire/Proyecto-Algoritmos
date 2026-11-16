function h = pantalla_horario(padre, opciones)
% PANTALLA_HORARIO  Pantalla 2 para el problema real: armar el horario del semestre.
%   h = pantalla_horario(padre, al_regresar=@() ..., n_guardadas=0)
%
%   Tiene tres subpasos en la misma pagina (horario.html): 1 Oferta, 2 Materias y
%   3 Preferencias. Oferta consulta SIIAU (consultar_siiau) o lee una pagina guardada
%   (leer_oferta_guardada); Materias elige que materias entran al problema y Preferencias
%   dice como se quiere el horario. La oferta, las claves y las preferencias se quedan aqui,
%   en MATLAB; al terminar se arma el problema con horario.m (src/problemas/real).
%
%   padre        : uifigure, uipanel o uigridlayout donde se dibuja
%   al_continuar : se llama con el problema armado y la configuracion al terminar:
%                  claves, preferencias, secciones (las que son bits, en el orden de x) y
%                  materias (clave, nombre y color con que se dibujan en las pantallas)
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

    raiz = ruta_proyecto();
    ejemplo = fullfile('datos', 'siiau', 'oferta_info_202620.html');
    catalogo = opciones_siiau();
    secciones = struct([]);
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
        avisar_pagina = @(k, n) enviar_y_dibujar('progreso', struct('pagina', k, 'secciones', n));
        try
            [secciones, info] = consultar_siiau(datos.ciclo, datos.centro, datos.carrera, ...
                solo_cupo=logical(datos.solo_cupo), al_leer_pagina=avisar_pagina);
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', mensaje_de_red(err)));
            return;
        end
        detalle = sprintf('%d %s de SIIAU (%d por página) · %s', info.paginas, ...
            plural(info.paginas, 'página', 'páginas'), info.por_pagina, ...
            char(datetime('now', 'Format', 'dd/MM/yyyy HH:mm')));
        enviar_oferta(info, detalle);
    end

    function leer_archivos(rutas)
        try
            [secciones, info] = leer_oferta_guardada(rutas);
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
            return;
        end
        [~, nombre, extension] = fileparts(rutas{1});
        archivo = [nombre extension];
        if numel(rutas) > 1, archivo = sprintf('%d archivos', numel(rutas)); end
        detalle = sprintf('%s · %d %s guardadas', archivo, info.paginas, ...
            plural(info.paginas, 'página', 'páginas'));
        enviar_oferta(info, detalle);
    end

    function enviar_oferta(info, detalle)
        sendEventToHTMLSource(h, 'oferta', struct( ...
            'secciones', secciones, ...
            'titulo', titulo_de(info, catalogo), ...
            'detalle', detalle, ...
            'paginas', info.paginas));
    end

    % Solo entran las secciones con horario de las materias elegidas: cada una es un bit.
    function continuar()
        if exist('horario', 'file') ~= 2
            sendEventToHTMLSource(h, 'aviso', struct('texto', ...
                'Falta horario.m en src/problemas/real para armar el problema.'));
            return;
        end
        con_horario = arrayfun(@(s) ~isempty(s.sesiones), secciones);
        elegidas = secciones(ismember(string({secciones.clave}), claves) & con_horario);
        try
            problema = horario(elegidas, preferencias);
        catch err
            sendEventToHTMLSource(h, 'aviso', struct('texto', err.message));
            return;
        end
        opciones.al_continuar(problema, struct('claves', claves, 'preferencias', preferencias, ...
            'secciones', elegidas, 'materias', materias_de(elegidas)));
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

function texto = plural(n, uno, varios)
    if n == 1, texto = uno; else, texto = varios; end
end

function texto = mensaje_de_red(err)
    if contains(err.identifier, 'MATLAB:webservices')
        texto = 'No se pudo conectar con SIIAU. Revisa tu internet o usa una página guardada.';
    else
        texto = err.message;
    end
end
