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
%| Clase CargaMembranaDistribuida                                       |
%|                                                                      |
%| Este archivo contiene la definicion de la Clase CargaMembranaDistribuida |
%| CargaMembranaDistribuida es una subclase de la clase Carga y corresponde |
%| a la representacion de una carga distribuida en un elemento tipo     |
%| Membrana.                                                            |
%| La clase CargaMembranaDistribuida es una clase que contiene el       |
%| elemento al que se le va a aplicar la carga, los nodos al que se     |
%| aplica las cargas y las distancias de las dos cargas.                |
%|                                                                      |
%| Programado: PABLO PIZARRO @ppizarror.com                             |
%| Fecha: 28/08/2018                                                    |
%|______________________________________________________________________|
%
%  Properties (Access=private):
%       elemObj
%       nodo1
%       nodo2
%       carga1
%       dist1
%       carga2
%       dist2
%
%  Methods:
%       cargaMembranaDistribuidaObj = CargaMembranaDistribuida(etiquetaCarga,elemObjeto,nodo1,nodo2,carga1,distancia1,carga2,distancia2)
%       aplicarCarga(cargaVigaDistribuidaObj,factorDeCarga)
%       disp(cargaVigaDistribuidaObj)
%
%  Methods SuperClass (Carga):
%  Methods SuperClass (ComponenteModelo):
%       etiqueta = obtenerEtiqueta(componenteModeloObj)

classdef CargaMembranaDistribuida < Carga
    
    properties(Access = private)
        elemObj % Variable que guarda el elemento que se le va a aplicar la carga
        carga1 % Valor de la carga 1
        carga2 % Valor de la carga 2
        dist1 % Distancia de la carga 1 al primer nodo del elemento
        dist2 % Distancia de la carga 2 al primer nodo del elemento
        nodo1 % Nodo 1 de aplicacion
        nodo2 % Nodo 2 de aplicacion
    end % properties CargaVigaDistribuida
    
    methods
        
        function cargaMembranaDistribuidaObj = CargaMembranaDistribuida(etiquetaCarga, elemObjeto, nodo1, nodo2, carga1, distancia1, carga2, distancia2)
            % Elemento: es el constructor de la clase CargaMembranaDistribuida
            %
            % cargaMembranaDistribuidaObj=CargaMembranaDistribuida(etiquetaCarga,elemObjeto,nodo1,nodo2,carga1,distancia1,carga2,distancia2)
            % Crea un objeto de la clase Carga, en donde toma como atributo
            % el objeto a aplicar la carga, las cargas y las distancias de
            % aplicacion.
            % La enumeracion de los nodos de la membrana corresponde a
            %
            %       4 ------------- 3
            %       |               |
            %       |               |
            %       |               |
            %       1 ------------- 2
            %
            % No se pueden aplicar cargas cruzadas, ie solo se permiten las
            % combinaciones 1-2, 2-3, 3-4 o 1-4
            
            if nargin == 0
                etiquetaCarga = '';
                elemObjeto = [];
                carga1 = 0;
                distancia1 = 0;
                carga2 = 0;
                distancia2 = 0;
            end % if
            
            % Llamamos al constructor de la SuperClass que es la clase Carga
            cargaMembranaDistribuidaObj = cargaMembranaDistribuidaObj@Carga(etiquetaCarga);
            
            % Verifica que se cumplan los nodos
            if abs(nodo1-nodo2) > 1
                error('Nodo no puede ser cruzado @CargaMembranaDistribuida %s', etiquetaCarga);
            end
            
            % Guarda los valores
            cargaMembranaDistribuidaObj.elemObj = elemObjeto;
            cargaMembranaDistribuidaObj.carga1 = carga1;
            % cargaMembranaDistribuidaObj.dist1 = distancia1 * elemObjeto.obtenerLargo();
            cargaMembranaDistribuidaObj.carga2 = carga2;
            % cargaMembranaDistribuidaObj.dist2 = distancia2 * elemObjeto.obtenerLargo();
            cargaMembranaDistribuidaObj.nodo1 = nodo1;
            cargaMembranaDistribuidaObj.nodo2 = nodo2;
            
        end % CargaMembranaDistribuida constructor
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para aplicar la Carga Membrana Distribuida durante el analisis
        
        function aplicarCarga(cargaMembranaDistribuidaObj, factorDeCarga)
            % aplicarCarga: es un metodo de la clase cargaMembranaDistribuidaObj que se usa para aplicar
            % la carga sobre los dos nodos correspondientes del elemento.
            %
            % aplicarCarga(cargaMembranaDistribuidaObj, factorDeCarga)
            
            % Obtiene los nodos
            
            % Largo de la viga
            L = cargaMembranaDistribuidaObj.elemObj.obtenerLargo();
            
            % Limites de las cargas
            d1 = cargaMembranaDistribuidaObj.dist1;
            d2 = cargaMembranaDistribuidaObj.dist2;
            
            % Cargas
            P1 = cargaMembranaDistribuidaObj.carga1;
            P2 = cargaMembranaDistribuidaObj.carga2;
            
            % Crea funcion de carga distribuida
            rho = @(x) P1 + (x - d1) * ((P2 - P1) / d2);
            
            % Funciones de interpolacion
            N1 = @(x) 1 - 3 * (x / L).^2 + 2 * (x / L).^3;
            N2 = @(x) x .* (1 - x / L).^2;
            N3 = @(x) 3 * (x / L).^2 - 2 * (x / L).^3;
            N4 = @(x) ((x.^2) / L) .* (x / L - 1);
            
            % Calcula cada valor
            v1 = integral(@(x) rho(x).*N1(x), d1, d2);
            theta1 = integral(@(x) rho(x).*N2(x), d1, d2);
            v2 = integral(@(x) rho(x).*N3(x), d1, d2);
            theta2 = integral(@(x) rho(x).*N4(x), d1, d2);
            
            vectorCarga1 = [0, -v1, -theta1]';
            vectorCarga2 = [0, -v2, -theta2]';
            cargaMembranaDistribuidaObj.elemObj.sumarFuerzaEquivalente([-v1, -theta1, -v2, -theta2]');
            
            % Aplica vectores de carga
            nodos = cargaMembranaDistribuidaObj.elemObj.obtenerNodos();
            nodos{1}.agregarCarga(factorDeCarga*vectorCarga1);
            nodos{2}.agregarCarga(factorDeCarga*vectorCarga2);
            
        end % aplicarCarga function
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Metodos para mostar la informacion de la Carga Membrana Distribuida en pantalla
        
        function disp(cargaMembranaDistribuidaObj)
            % disp: es un metodo de la clase Carga que se usa para imprimir en
            % command Window la informacion de la carga aplicada sobre el
            % elemento
            %
            % disp(cargaMembranaDistribuidaObj)
            % Imprime la informacion guardada en la Carga Distribuida de la
            % Membrana (cargaMembranaDistribuidaObj) en pantalla
            
            fprintf('Propiedades Carga Membrana Distribuida:\n');
            disp@Carga(cargaMembranaDistribuidaObj);
            
            % Obtiene la etiqueta del elemento
            etiqueta = cargaMembranaDistribuidaObj.elemObj.obtenerEtiqueta();
            
            % Obtiene la etiqueta del primer nodo
            nodosetiqueta = cargaMembranaDistribuidaObj.elemObj.obtenerNodos();
            nodo1etiqueta = nodosetiqueta{1}.obtenerEtiqueta();
            nodo2etiqueta = nodosetiqueta{2}.obtenerEtiqueta();
            
            fprintf('\tCarga distribuida: %.3f en %.3f hasta %.3f en %.3f entre los Nodos: %s y %s del Elemento: %s', ...
                cargaMembranaDistribuidaObj.carga1, cargaMembranaDistribuidaObj.dist1, cargaMembranaDistribuidaObj.carga2, ...
                cargaMembranaDistribuidaObj.dist2, nodo1etiqueta, nodo2etiqueta, etiqueta);
            
            fprintf('-------------------------------------------------\n');
            fprintf('\n');
            
        end % disp function
        
    end % methods CargaMembranaDistribuida
    
end % class CargaMembranaDistribuida