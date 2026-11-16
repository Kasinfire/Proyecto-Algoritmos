function fig = MetaheuristicasApp()
% METAHEURISTICASAPP  Abre la aplicacion completa en una sola ventana.
%   Desde la carpeta Proyecto/:
%       MetaheuristicasApp
%
%   La ventana tiene una rejilla de 1x1 y en ella vive una sola pantalla a la vez. Cada
%   pantalla_*.m avisa por callbacks lo que eligio el usuario; aqui se guarda y se cambia
%   a la pantalla que sigue:
%
%       1 Tipo -> 2 Problema -> 3 Algoritmo -> 4 Ejecucion -> 5 Resultados
%                                    ^                            |
%                                    +------ Nueva ejecucion -----+
%
%   Cada vez que se llega a Resultados la ejecucion se guarda para Comparar, que se
%   abre desde el riel de cualquier pantalla y al volver regresa a donde se estaba.
%   Requiere MATLAB R2023a o mas reciente.

    addpath(genpath(fullfile(fileparts(mfilename('fullpath')), 'src')));

    fig = uifigure('Name', 'Metaheurísticas', 'Position', [80 60 1440 900]);
    movegui(fig, 'center');
    rejilla = uigridlayout(fig, [1 1], 'Padding', 0);

    % Lo elegido en cada paso. Al cambiar un paso se borra lo que dependia de el.
    tipo = '';
    config_problema = struct();
    problema = struct();
    algoritmo = struct();
    resultado = struct();
    numero = 0;

    ejecuciones = struct('numero', {}, 'resultado', {});
    pantalla_actual = @mostrar_tipo;

    mostrar_tipo();

    % ----- Pantallas -----

    function mostrar_tipo()
        abrir(@mostrar_tipo);
        pantalla_tipo(rejilla, ...
            al_continuar=@elegir_tipo, ...
            al_comparar=@mostrar_comparar, ...
            seleccionado=tipo, ...
            n_guardadas=numel(ejecuciones));
    end

    function mostrar_problema()
        abrir(@mostrar_problema);
        pantalla_problema(rejilla, tipo, ...
            al_continuar=@elegir_problema, ...
            al_regresar=@mostrar_tipo, ...
            al_comparar=@mostrar_comparar, ...
            seleccion=config_problema, ...
            n_guardadas=numel(ejecuciones));
    end

    function mostrar_algoritmo()
        abrir(@mostrar_algoritmo);
        if isempty(fieldnames(algoritmo))
            seleccion = struct();
        else
            seleccion = struct('id', algoritmo.id, 'valores', algoritmo.params);
        end
        pantalla_algoritmo(rejilla, problema, ...
            al_ejecutar=@elegir_algoritmo, ...
            al_regresar=@mostrar_problema, ...
            al_ir_a_tipo=@mostrar_tipo, ...
            al_comparar=@mostrar_comparar, ...
            seleccion=seleccion, ...
            n_guardadas=numel(ejecuciones), ...
            tipo=tipo, ...
            config=config_problema);
    end

    function mostrar_ejecucion()
        abrir(@mostrar_ejecucion);
        pantalla_ejecucion(rejilla, problema, algoritmo.id, algoritmo.params, ...
            al_ver_resultados=@guardar_resultado, ...
            al_regresar=@mostrar_algoritmo, ...
            al_ir_a_paso=@ir_a_paso, ...
            al_comparar=@mostrar_comparar, ...
            n_guardadas=numel(ejecuciones), ...
            tipo=tipo, ...
            config=config_problema);
    end

    function mostrar_resultados()
        abrir(@mostrar_resultados);
        pantalla_resultados(rejilla, resultado, ...
            numero=numero, ...
            n_guardadas=numel(ejecuciones), ...
            al_nueva_ejecucion=@mostrar_algoritmo, ...
            al_comparar=@mostrar_comparar, ...
            al_ir_a_paso=@ir_a_paso, ...
            tipo=tipo, ...
            config=config_problema);
    end

    % Comparar no cuenta como pantalla actual: Volver regresa a la que estaba abierta.
    function mostrar_comparar()
        volver = pantalla_actual;
        delete(rejilla.Children);
        pantalla_comparar(rejilla, ejecuciones, ...
            elegida=numero, ...
            al_volver=volver, ...
            al_ir_a_paso=@ir_a_paso);
    end

    function abrir(pantalla)
        pantalla_actual = pantalla;
        delete(rejilla.Children);
    end

    % ----- Lo que elige el usuario -----

    function elegir_tipo(nuevo)
        if ~strcmp(nuevo, tipo)
            tipo = char(nuevo);
            config_problema = struct();
            problema = struct();
            algoritmo = struct();
            olvidar_resultado();
        end
        mostrar_problema();
    end

    % El algoritmo elegido se conserva: sus parametros sirven para cualquier problema
    % del mismo tipo.
    function elegir_problema(nuevo, config)
        problema = nuevo;
        config_problema = config;
        olvidar_resultado();
        mostrar_algoritmo();
    end

    function elegir_algoritmo(id, params)
        algoritmo = struct('id', id, 'params', params);
        olvidar_resultado();
        mostrar_ejecucion();
    end

    % Si se vuelve a la ejecucion desde el riel y se llega al mismo resultado (misma
    % semilla, mismo corte), no se guarda dos veces.
    function guardar_resultado(nuevo)
        if numero == 0 || ~mismo_resultado(resultado, nuevo)
            numero = siguiente_numero(ejecuciones);
            ejecuciones(end + 1) = struct('numero', numero, 'resultado', nuevo);
        end
        resultado = nuevo;
        mostrar_resultados();
    end

    function olvidar_resultado()
        resultado = struct();
        numero = 0;
    end

    % ----- Riel -----

    % Pasos 0..4. Si un paso ya no tiene sus datos (por ejemplo, desde Comparar despues
    % de cambiar de problema) se abre el ultimo paso que si los tiene.
    function ir_a_paso(paso)
        pantallas = {@mostrar_tipo, @mostrar_problema, @mostrar_algoritmo, ...
                     @mostrar_ejecucion, @mostrar_resultados};
        listos = [true, ~isempty(tipo), ~isempty(fieldnames(problema)), ...
                  ~isempty(fieldnames(algoritmo)), numero > 0];
        pantallas{min(paso + 1, find(listos, 1, 'last'))}();
    end
end

function n = siguiente_numero(ejecuciones)
    if isempty(ejecuciones)
        n = 1;
    else
        n = max([ejecuciones.numero]) + 1;
    end
end

function si = mismo_resultado(a, b)
    si = strcmp(a.algoritmo, b.algoritmo) && isequaln(a.params, b.params) ...
        && a.iteraciones == b.iteraciones && isequaln(a.historial.mejor_valor, b.historial.mejor_valor);
end
