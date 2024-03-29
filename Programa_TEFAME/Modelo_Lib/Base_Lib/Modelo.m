% ______________________________________________________________________
%|                                                                      |
%|           TEFAME - Toolbox para Elemento Finitos y Analisis          |
%|                  Matricial de Estructuras en MATLAB                  |
%|                                                                      |
%|                   Area  de Estructuras y Geotecnia                   |
%|                   Departamento de Ingenieria Civil                   |
%|              Facultad de Ciencias Fisicas y Matematicas              |
%|                         Universidad de Chile                         |
%|                                                                      |
%| TEFAME es una  plataforma en base a objetos para modelar, analizar y |
%| visualizar  la respuesta de sistemas  estructurales usando el metodo |
%| de elementos finitos y analisis matricial de estructuras en MATLAB.  |
%| La plataforma es desarrollada en  propagacion orientada a objetos en |
%| MATLAB.                                                              |
%|                                                                      |
%| Desarrollado por:                                                    |
%|       Fabian Rojas, PhD (frojas@ing.uchile.cl)                       |
%|       Prof. Asistente, Departamento de Ingenieria Civil              |
%|       Universidad de Chile                                           |
%|______________________________________________________________________|
% ______________________________________________________________________
%|                                                                      |
%| Clase Modelo                                                         |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase Modelo               |
%| Modelo es  una clase  contenedor  que se usa  para guardar y proveer |
%| acceso a los diferentes componentes (Nodos, Elementos, Restricciones |
%| y Patrones de Carga) en el modelo.                                   |
%|                                                                      |
%| Programado: FR                                                       |
%| Fecha: 05/08/2015                                                    |
%|                                                                      |
%| Modificado por: FR - 24/10/2016                                      |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nDimensiones
%       nGDL
%       nodos
%       elementos
%       restricciones
%       patronesDeCargas
%
%  Methods:
%       modeloObj = Modelo(numeroDimensiones,numerosGDL)
%       agregarNodos(modeloObj,arregloNodos)
%       agregarElementos(modeloObj,arregloElementos)
%       agregarRestricciones(modeloObj,arregloRestricciones)
%       agregarPatronesDeCargas(modeloObj,arregloPatronesDeCargas)
%       nodosModelo = obtenerNodos(modeloObj)
%       elementosModelo = obtenerElementos(modeloObj)
%       restriccionesModelo = obtenerRestricciones(modeloObj)
%       patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
%       inicializar(modeloObj)
%       aplicarRestricciones(modeloObj)
%       aplicarPatronesDeCargas(modeloObj)
%       actualizar(modeloObj,u)
%       guardarResultados(modeloObj,nombreArchivo)
%       disp(modeloObj)

classdef Modelo < handle
    
    properties(Access = private)
        nDimensiones % Variable que guarda las dimensiones del sistema de coordenadas del modelo
        nGDL % Variable que guarda el numero de grados de libertad de cada nodo (GDL)
        nodos % Variable que guarda en un arreiglo de celdas todos los nodos del modelo
        elementos % Variable que guarda en un arreiglo de celdas todos los elementos del modelo
        restricciones % Variable que guarda en un arreiglo de celdas todos las restricciones del modelo
        patronesDeCargas % Variable que guarda en un arreiglo de celdas todos los patrones de cargas aplicadas sobre el modelo
    end % properties Modelo
    
    methods
        
        function modeloObj = Modelo(numeroDimensiones, numerosGDL)
            % Modelo: es el constructor de la clase Modelo
            %
            % modeloObj = Modelo(numeroDimensiones,numerosGDL)
            % Crea un objeto de la clase Modelo, con el numero de dimensiones
            % que tiene el sistema de coordenadas del modelo (nDimensiones) y
            % el numero de grados de libertad por nodo
            
            % Definimos las propiedades de entrada si, no se ingresa ningun valor
            if nargin == 0
                numeroDimensiones = 0;
                numerosGDL = 0;
            end % if
            
            % Definimos las propiedades en el modelo
            modeloObj.nDimensiones = numeroDimensiones;
            modeloObj.nGDL = numerosGDL;
            
            % Generamos el modelo con todos las variables que guardan las
            % componentes del modelo vacio
            modeloObj.nodos = [];
            modeloObj.elementos = [];
            modeloObj.restricciones = [];
            modeloObj.patronesDeCargas = [];
            
        end % Modelo constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para agregar componentes del Modelo
        
        function agregarNodos(modeloObj, arreigloNodos)
            % agregarNodos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreiglo con los nodos al Modelo
            %
            % agregarNodos(modeloObj,arreigloNodos)
            % Agrega el arreiglo con los nodos (arreigloNodos) al Modelo (modeloObj)
            % para que esto lo guarde y tenga acceso a los nodos
            
            modeloObj.nodos = arreigloNodos;
            
        end % agregarNodos function
        
        function agregarElementos(modeloObj, arreigloElementos)
            % agregarElementos: es un metodo de la clase Modelo que se usa para
            % entregarle el arreiglo con los elementos al Modelo
            %
            % agregarElementos(modeloObj,arreigloElementos)
            % Agrega el arreiglo con los elementos (arreigloElementos) al Modelo
            % (modeloObj) para que esto lo guarde y tenga acceso a los elementos
            
            modeloObj.elementos = arreigloElementos;
            
        end % agregarElementos function
        
        function agregarRestricciones(modeloObj, arreigloRestricciones)
            % agregarRestricciones: es un metodo de la clase Modelo que se usa
            % para entregarle el arreiglo con los restricciones al Modelo
            %
            % agregarRestricciones(modeloObj,arreigloRestricciones)
            % Agrega el arreiglo con los restricciones (arreigloRestricciones)
            % al Modelo (modeloObj) para que esto lo guarde y tenga acceso a
            % los restricciones.
            
            modeloObj.restricciones = arreigloRestricciones;
            
        end % agregarRestricciones function
        
        function agregarPatronesDeCargas(modeloObj, arreigloPatronDeCargas)
            % agregarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para entregarle el arreiglo con los patrones de carga al Modelo
            %
            % agregarPatronesDeCargas(modeloObj,arreigloPatronDeCargas)
            % Agrega el arreiglo con los patrones de carga (arreigloPatronDeCargas)
            % al Modelo (modeloObj) para que esto lo guarde y tenga acceso a los
            % patrones de carga.
            % Los patrones de cargas contienen las cargas que se aplican en los
            % nodos y elementos.
            
            modeloObj.patronesDeCargas = arreigloPatronDeCargas;
            
        end % agregarPatronesDeCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para obtener los componentes del Modelo
        
        function nodosModelo = obtenerNodos(modeloObj)
            % obtenerNodos: es un metodo de la clase Modelo que se usa para
            % obtener el arreiglo con los nodos guardados en el Modelo
            %
            % nodosModelo = obtenerNodos(modeloObj)
            % Obtiene el arreiglo con los nodos (nodosModelo) que esta guardado
            % en el Modelo (modeloObj)
            
            nodosModelo = modeloObj.nodos;
            
        end % obtenerNodos function
        
        function elementosModelo = obtenerElementos(modeloObj)
            % obtenerElementos: es un metodo de la clase Modelo que se usa para
            % obtener el arreiglo con los elementos guardados en el Modelo
            %
            % elementosModelo = obtenerElementos(modeloObj)
            % Obtiene el arreiglo con los elementos (elementosModelo) que esta
            % guardado en el Modelo (modeloObj)
            
            elementosModelo = modeloObj.elementos;
            
        end % obtenerElementos function
        
        function restriccionesModelo = obtenerRestricciones(modeloObj)
            % obtenerPatronDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreiglo con los patrones de carga guardados en el Modelo
            %
            % patronDeCargasModelo = obtenerPatronDeCargas(modeloObj)
            % Obtiene el arreiglo con los patrones de carga (patronDeCargasModelo)
            % que esta guardado en el Modelo (modeloObj)
            
            restriccionesModelo = modeloObj.restricciones;
            
        end % obtenerRestricciones function
        
        function patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
            % obtenerPatronesDeCargas: es un metodo de la clase Modelo que se usa para
            % obtener el arreiglo con los patrones de carga guardados en el Modelo
            %
            % patronesDeCargasModelo = obtenerPatronesDeCargas(modeloObj)
            % Obtiene el arreiglo con los patrones de carga (patronesDeCargasModelo)
            % que esta guardado en el Modelo (modeloObj)
            
            patronesDeCargasModelo = modeloObj.patronesDeCargas;
            
        end % obtenerPatronesDeCargas function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para inicializar y actualizar las componentes del Modelo
        
        function inicializar(modeloObj)
            % inicializar: es un metodo de la clase Modelo que se usa para
            % inicializar las diferentes componentes en el Modelo
            %
            % inicializar(modeloObj)
            % Inicializa los diferentes componentes del modelo que estan guardados
            % en el Modelo (modeloObj), para poder preparar estos para realizar
            % el analisis
            
            for i = 1:length(modeloObj.nodos)
                modeloObj.nodos{i}.inicializar()
            end
            
            for i = 1:length(modeloObj.elementos)
                modeloObj.elementos{i}.inicializar()
            end
            
        end % inicializar function
        
        function aplicarRestricciones(modeloObj)
            % aplicarRestricciones: es un metodo de la clase Modelo que se usa para
            % aplicar las restricciones en el Modelo
            %
            % aplicarRestricciones(modeloObj)
            % Aplica las restricciones que estan guardadas en el Modelo (modeloObj)
            
            for i = 1:length(modeloObj.restricciones)
                modeloObj.restricciones{i}.aplicarRestriccion()
            end
            
        end % aplicarRestricciones function
        
        function aplicarPatronesDeCargas(modeloObj)
            % aplicarPatronesDeCargas: es un metodo de la clase Modelo que se usa
            % para aplicar las patrones de cargas en el Modelo
            %
            % aplicarPatronesDeCargas(modeloObj)
            % Aplica los patrones de cargas que estan guardados en el Modelo
            % (modeloObj), es decir, aplica las cargas sobre los nodos y
            % elementos.
            
            for i = 1:length(modeloObj.patronesDeCargas)
                modeloObj.patronesDeCargas{i}.aplicarCargas()
            end
            
        end % aplicarPatronesDeCargas function
        
        function actualizar(modeloObj, u)
            % actualizar: es un metodo de la clase Modelo que se usa para actualizar
            % las componentes en el Modelo
            %
            % actualizar(modeloObj,u)
            % Actualiza o informa de los desplazamientos (u), entregados por el
            % analisis al resolver el sistema de ecuaciones, a las componentes
            % guardadas en el Modelo (modeloObj)
            
            % Se procede a actualizar los desplazamientos guardados
            
            % Se definen e informan los desplazmientos a cada nodo
            numeroNodos = length(modeloObj.nodos);
            for i = 1:numeroNodos
                
                % Nodo
                nodo = modeloObj.nodos{i};
                gdlnodo = nodo.obtenerGDLID();
                
                % Se buscan desplazamientos en el vector u
                ngrados = nodo.obtenerNumeroGDL();
                d = zeros(ngrados, 1);
                for j = 1:ngrados
                    if (gdlnodo(j) ~= 0)
                        d(j) = u(gdlnodo(j));
                    end
                end
                
                % Guarda los desplazamientos
                modeloObj.nodos{i}.definirDesplazamientos(d');
                
            end % for i
            
            % Agregamos las fuerzas resistentes a las reacciones
            numeroElementos = length(modeloObj.elementos);
            for i = 1:numeroElementos
                modeloObj.elementos{i}.agregarFuerzaResistenteAReacciones();
            end % for i
            
        end % actualizar function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para guardar la informacion del Modelo y resultados del
        % analisis en un archivo de salida
        
        function guardarResultados(modeloObj, nombreArchivo)
            % guardarResultados: es un metodo de la clase Modelo que se usa para
            % guardar o imprimir en un archivo las propiedades de las componentes
            % del Modelo y los resultados del analisis
            %
            % guardarResultados(modeloObj,nombreArchivo)
            % Guarda las propiedades de las componentes del Modelo (modeloObj) y
            % los resultados del analisis que tienen guardados los diferentes
            % componentes en un archivo (nombreArchivo)
            
            % Abre el archivo donde se guardara la informacion
            archivoSalida = fopen(nombreArchivo, 'w');
            fprintf(archivoSalida, 'TEFAME - Toolbox para Elemento Finitos y Analisis\n');
            fprintf(archivoSalida, '         Matricial de Estructuras en MATLAB\n');
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Propiedades de entrada modelo\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las propiedades de los nodos
            fprintf(archivoSalida, 'Nodos:\n');
            nNodos = length(modeloObj.nodos);
            fprintf(archivoSalida, '\tNumero de nodos: %d\n', nNodos);
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarPropiedades(archivoSalida);
            end
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las propiedades de los elementos
            fprintf(archivoSalida, 'Elementos:\n');
            nElementos = length(modeloObj.elementos);
            fprintf(archivoSalida, '\tNumero de elementos: %d\n', nElementos);
            for iElem = 1:nElementos
                modeloObj.elementos{iElem}.guardarPropiedades(archivoSalida);
            end % for iElem
            
            fprintf(archivoSalida, '\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, 'Resultados del analisis\n');
            fprintf(archivoSalida, '-------------------------------------------------------------------------------\n');
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los desplazamientos en cada nodo
            fprintf(archivoSalida, 'Desplazamientos nodos:\n');
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarDesplazamientos(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar las reacciones
            fprintf(archivoSalida, 'Reacciones:\n');
            for iNodo = 1:nNodos
                modeloObj.nodos{iNodo}.guardarReacciones(archivoSalida);
            end % for iNodo
            fprintf(archivoSalida, '\n');
            
            % Se procede a guardar los esfuerzos en los elementos
            fprintf(archivoSalida, 'Esfuerzos Elementos:');
            for i = 1:length(modeloObj.elementos)
                modeloObj.elementos{i}.guardarEsfuerzosInternos(archivoSalida);
            end % for i
            fclose(archivoSalida);
            
        end % guardarResultados function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion del Modelo en pantalla
        
        function disp(modeloObj)
            % disp: es un metodo de la clase Modelo que se usa para imprimir en
            % command Window la informacion del Modelo
            %
            % disp(modeloObj)
            % Imprime la informacion guardada en el Modelo (modeloObj) en
            % pantalla
            
            fprintf('Propiedades Modelo:\n');
            fprintf('\tDimensiones Modelo: %iD\n', modeloObj.nDimensiones);
            fprintf('\tNumero de GDL del Modelo: %i\n', modeloObj.nGDL);
            
        end % disp function
        
    end % methods Modelo
    
end % class Modelo