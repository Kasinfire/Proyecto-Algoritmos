function ruta = ruta_proyecto(varargin)
% RUTA_PROYECTO  Ruta absoluta dentro de la carpeta Proyecto/.
%   ruta_proyecto('src', 'ui', 'web', 'tipo.html')
%   ruta_proyecto('datos')
%
%   Las pantallas la usan para encontrar sus HTML y la carpeta datos/ sin depender
%   de en que subcarpeta esta cada .m.

    raiz = fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
    ruta = fullfile(raiz, varargin{:});
end
