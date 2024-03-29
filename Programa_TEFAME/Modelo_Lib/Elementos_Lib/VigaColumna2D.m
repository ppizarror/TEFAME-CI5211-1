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
%| Clase VigaColumna2D                                                  |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase VigaColumna 2D       |
%| ColumnaViga2D es una  subclase de la clase Elemento y  corresponde a |
%| la representacion del elemento viga-columna que transmite esfuerzos  |
%| axiales y de corte.                                                  |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 10/06/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       nodosObj
%       gdlID
%       Eo
%       Ao
%       Io
%       dx
%       dy
%       L
%       Feq
%
%  Methods:
%       vigaColumna2DObj = VigaColumna2D(etiquetaViga,nodo1Obj,nodo2Obj,Imaterial,Ematerial)
%       numeroNodos = obtenerNumeroNodos(vigaColumna2DObj)
%       nodosBiela = obtenerNodos(vigaColumna2DObj)
%       numeroGDL = obtenerNumeroGDL(vigaColumna2DObj)
%       gdlIDBiela = obtenerGDLID(vigaColumna2DObj)
%       k_global = obtenerMatrizRigidezCoordGlobal(vigaColumna2DObj)
%       k_local = obtenerMatrizRigidezCoordLocal(vigaColumna2DObj)
%       fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumna2DObj)
%       fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumna2DObj)
%       l = obtenerLargo(vigaColumna2DObj)
%       T = obtenerMatrizTransformacion(vigaColumna2DObj)
%       theta = obtenerAngulo(vigaColumna2DObj)
%       definirGDLID(vigaColumna2DObj)
%       agregarFuerzaResistenteAReacciones(vigaColumna2DObj)
%       guardarPropiedades(vigaColumna2DObj,archivoSalidaHandle)
%       guardarEsfuerzosInternos(vigaColumna2DObj,archivoSalidaHandle)
%       disp(vigaColumna2DObj)
%
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef VigaColumna2D < Elemento
    
    properties(Access = private)
        nodosObj
        gdlID
        Ao
        Eo
        Io
        dx
        dy
        L
        theta
        Feq
        T
        Klp
    end % properties VigaColumna2D
    
    methods
        
        function vigaColumna2DObj = VigaColumna2D(etiquetaViga, nodo1Obj, nodo2Obj, Imaterial, Ematerial, Amaterial)
            
            % Completa con ceros si no hay argumentos
            if nargin == 0
                etiquetaViga = '';
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Elemento
            vigaColumna2DObj = vigaColumna2DObj@Elemento(etiquetaViga);
            
            % Guarda material
            vigaColumna2DObj.nodosObj = {nodo1Obj; nodo2Obj};
            vigaColumna2DObj.Ao = Amaterial;
            vigaColumna2DObj.Eo = Ematerial;
            vigaColumna2DObj.Io = Imaterial;
            vigaColumna2DObj.gdlID = [];
            
            % Calcula componentes geometricas
            coordNodo1 = nodo1Obj.obtenerCoordenadas();
            coordNodo2 = nodo2Obj.obtenerCoordenadas();
            vigaColumna2DObj.dx = (coordNodo2(1) - coordNodo1(1));
            vigaColumna2DObj.dy = (coordNodo2(2) - coordNodo1(2));
            vigaColumna2DObj.L = sqrt(vigaColumna2DObj.dx^2+vigaColumna2DObj.dy^2);
            theta = atan(vigaColumna2DObj.dy/vigaColumna2DObj.dx);
            vigaColumna2DObj.theta = theta;
            
            % Calcula matriz de transformacion dado el angulo
            T = [cos(theta), sin(theta), 0, 0, 0, 0; ...
                -sin(theta), cos(theta), 0, 0, 0, 0; ...
                0, 0, 1, 0, 0, 0; ...
                0, 0, 0, cos(theta), sin(theta), 0; ...
                0, 0, 0, -sin(theta), cos(theta), 0; ...
                0, 0, 0, 0, 0, 1];
            vigaColumna2DObj.T = T;
            
            % Calcula matriz de rigidez local
            A = Amaterial;
            E = Ematerial;
            I = Imaterial;
            L = vigaColumna2DObj.L;
            Klp = [A * E / L, 0, 0, -A * E / L, 0, 0; ...
                0, 12 * E * I / (L^3), 6 * E * I / (L^2), 0, - 12 * E * I / (L^3), 6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 4 * E * I / L, 0, - 6 * E * I / (L^2), 2 * E * I / L; ...
                -A * E / L, 0, 0, A * E / L, 0, 0; ...
                0, -12 * E * I / (L^3), - 6 * E * I / (L^2), 0, 12 * E * I / (L^3), -6 * E * I / (L^2); ...
                0, 6 * E * I / (L^2), 2 * E * I / L, 0, - 6 * E * I / (L^2), 4 * E * I / L];
            vigaColumna2DObj.Klp = Klp;
            
            % Fuerza equivalente de la viga
            vigaColumna2DObj.Feq = [0, 0, 0, 0, 0, 0]';
            
        end % Viga2D constructor
        
        function l = obtenerLargo(vigaColumna2DObj)
            
            l = vigaColumna2DObj.L;
            
        end % obtenerLargo function
        
        function numeroNodos = obtenerNumeroNodos(vigaColumna2DObj) %#ok<MANU>
            
            numeroNodos = 2;
            
        end % obtenerNumeroNodos function
        
        function nodosViga = obtenerNodos(vigaColumna2DObj)
            
            nodosViga = vigaColumna2DObj.nodosObj;
            
        end % obtenerNodos function
        
        function numeroGDL = obtenerNumeroGDL(vigaColumna2DObj) %#ok<MANU>
            
            numeroGDL = 6;
            
        end % obtenerNumeroGDL function
        
        function gdlIDViga = obtenerGDLID(vigaColumna2DObj)
            
            gdlIDViga = vigaColumna2DObj.gdlID;
            
        end % obtenerNumeroGDL function
        
        function T = obtenerMatrizTransformacion(vigaColumna2DObj)
            
            T = vigaColumna2DObj.T;
            
        end % obtenerNumeroGDL function
        
        function theta = obtenerAngulo(vigaColumna2DObj)
            
            theta = vigaColumna2DObj.theta;
            
        end % obtenerAngulo function
        
        function k_global = obtenerMatrizRigidezCoordGlobal(vigaColumna2DObj)
            
            % Multiplica por la matriz de transformacion
            k_local = vigaColumna2DObj.obtenerMatrizRigidezCoordLocal();
            t_theta = vigaColumna2DObj.T;
            k_global = t_theta' * k_local * t_theta;
            
        end % obtenerMatrizRigidezGlobal function
        
        function k_local = obtenerMatrizRigidezCoordLocal(vigaColumna2DObj)
            
            % Retorna la matriz calculada en el consturctor
            k_local = vigaColumna2DObj.Klp;
            
        end % obtenerMatrizRigidezLocal function
        
        function fr_global = obtenerFuerzaResistenteCoordGlobal(vigaColumna2DObj)
            
            % Obtiene fr local
            fr_local = vigaColumna2DObj.obtenerFuerzaResistenteCoordLocal();
            
            % Resta a fuerza equivalente para obtener la fuerza global
            fr_local_c = fr_local - vigaColumna2DObj.Feq;
            
            % Calcula fuerza resistente global
            T_theta = vigaColumna2DObj.T;
            fr_global = T_theta' * fr_local_c;
            
        end % obtenerFuerzaResistenteCoordGlobal function
        
        function fr_local = obtenerFuerzaResistenteCoordLocal(vigaColumna2DObj)
            
            % Obtiene los nodos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
            % Obtiene los desplazamientos
            u1 = nodo1.obtenerDesplazamientos();
            u2 = nodo2.obtenerDesplazamientos();
            
            % Vector desplazamientos u'
            u = [u1(1), u1(2), u1(3), u2(1), u2(2), u2(3)]';
            
            % Obtiene K local
            k_local = vigaColumna2DObj.obtenerMatrizRigidezCoordLocal();
            
            % Obtiene u''
            u = vigaColumna2DObj.obtenerMatrizTransformacion() * u;
            
            % Calcula F
            fr_local = k_local * u;
            
        end % obtenerFuerzaResistenteCoordLocal function
        
        function definirGDLID(vigaColumna2DObj)
            
            % Se obtienen los nodos extremos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
            % Se obtienen los gdl de los nodos
            gdlnodo1 = nodo1.obtenerGDLID();
            gdlnodo2 = nodo2.obtenerGDLID();
            
            % Se establecen gdl
            gdl = [0, 0, 0, 0, 0, 0];
            gdl(1) = gdlnodo1(1);
            gdl(2) = gdlnodo1(2);
            gdl(3) = gdlnodo1(3);
            gdl(4) = gdlnodo2(1);
            gdl(5) = gdlnodo2(2);
            gdl(6) = gdlnodo2(3);
            vigaColumna2DObj.gdlID = gdl;
            
        end % definirGDLID function
        
        function sumarFuerzaEquivalente(vigaColumna2DObj, f)
            
            for i = 1:length(f)
                vigaColumna2DObj.Feq(i) = vigaColumna2DObj.Feq(i) + f(i);
            end
            
        end % guardarFuerzaEquivalente function
        
        function agregarFuerzaResistenteAReacciones(vigaColumna2DObj)
            
            % Se calcula la fuerza resistente global
            fr_global = vigaColumna2DObj.obtenerFuerzaResistenteCoordGlobal();
            
            % Carga los nodos
            nodo1 = vigaColumna2DObj.nodosObj{1};
            nodo2 = vigaColumna2DObj.nodosObj{2};
            
            % Transforma la carga equivalente como carga puntual
            F_eq = vigaColumna2DObj.T' * vigaColumna2DObj.Feq;
            
            % Agrega fuerzas equivalentes como cargas
            nodo1.agregarCarga([-F_eq(1), -F_eq(2), -F_eq(3)]')
            nodo2.agregarCarga([-F_eq(4), -F_eq(5), -F_eq(6)]')
            
            % Agrega fuerzas resistentes como cargas
            nodo1.agregarEsfuerzosElementoAReaccion([fr_global(1), fr_global(2), fr_global(3)]');
            nodo2.agregarEsfuerzosElementoAReaccion([fr_global(4), fr_global(5), fr_global(6)]');
            
        end % agregarFuerzaResistenteAReacciones function
        
        function guardarPropiedades(vigaColumna2DObj, archivoSalidaHandle)
            
            fprintf(archivoSalidaHandle, '\tViga-Columna 2D %s:\n\t\tLargo:\t\t%s\n\t\tInercia:\t%s\n\t\tEo:\t\t\t%s\n\t\tEI:\t\t\t%s\n', ...
                vigaColumna2DObj.obtenerEtiqueta(), num2str(vigaColumna2DObj.L), ...
                num2str(vigaColumna2DObj.Io), num2str(vigaColumna2DObj.Eo), num2str(vigaColumna2DObj.Eo*vigaColumna2DObj.Io));
            
        end % guardarPropiedades function
        
        function guardarEsfuerzosInternos(vigaColumna2DObj, archivoSalidaHandle)
            
            fr = vigaColumna2DObj.obtenerFuerzaResistenteCoordGlobal();
            n1 = pad(num2str(fr(1), '%.04f'), 10);
            n2 = pad(num2str(fr(4), '%.04f'), 10);
            v1 = pad(num2str(fr(2), '%.04f'), 10);
            v2 = pad(num2str(fr(5), '%.04f'), 10);
            m1 = pad(num2str(fr(3), '%.04f'), 10);
            m2 = pad(num2str(fr(6), '%.04f'), 10);
            
            fprintf(archivoSalidaHandle, '\n\tViga-Columna 2D %s:\n\t\tAxial:\t\t%s %s\n\t\tCorte:\t\t%s %s\n\t\tMomento:\t%s %s', ...
                vigaColumna2DObj.obtenerEtiqueta(), n1, n2, v1, v2, m1, m2);
            
        end % guardarEsfuerzosInternos function
        
        function disp(vigaColumna2DObj)
            
            % Imprime propiedades de la Viga-Columna 2D
            fprintf('Propiedades Viga-Columna 2D:\n\t');
            disp@ComponenteModelo(vigaColumna2DObj);
            fprintf('\t\tLargo: %s\tArea: %s\tI: %s\tE: %s\n', pad(num2str(vigaColumna2DObj.L), 12), ...
                pad(num2str(vigaColumna2DObj.Ao), 10), pad(num2str(vigaColumna2DObj.Io), 10), ...
                pad(num2str(vigaColumna2DObj.Eo), 10));
            
            % Se imprime matriz de rigidez local
            fprintf('\tMatriz de rigidez coordenadas locales:\n');
            disp(vigaColumna2DObj.obtenerMatrizRigidezCoordLocal());
            
            % Se imprime matriz de rigidez global
            fprintf('\tMatriz de rigidez coordenadas globales:\n');
            disp(vigaColumna2DObj.obtenerMatrizRigidezCoordGlobal());
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods VigaColumna2D
    
end % class VigaColumna2D