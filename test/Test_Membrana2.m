clear all; %#ok<CLALL>
fprintf('>\tTEST_MEMBRANA2\n');

% Test Membrana muro largo con carga distribuida encima, simplemente
% apoyado en sus dos extremos
%
N = 11; % Numero de bloques
b = 100; % Ancho de cada bloque
h = 100; % Alto de cada bloque
%
%    N = 2
%       4 ------ 5 ------ 6
%       |        |        |
%     h |   (1)  |   (2)  |  ......
%       |        |        |
%       1 ------ 2 ------ 3 .....
%       ^    b        b   ^
%
%    N = 3
%       4 ------ 5 ------ 6 ------- 8
%       |        |        |         |
%     h |   (1)  |   (2)  |   (3)   |
%       |        |        |         |
%       1 ------ 2 ------ 3 ------- 4
%       ^    b                      ^
% ==========================

t = 15; % cm
E = 300000; % Modulo de Elasticidad [kgf/cm^2]
nu = 0.15; % Modulo de Poisson

% Numero de grados de libertad
gdl = N * 2 + 2;

% Creamos el modelo
modeloObj = Modelo(2, gdl);

% Creamos los Nodos
nodos = cell(gdl, 1);
for i = 1:(N + 1)
    j = N + 1 + i; % Nodo superior a <i>
    nodos{i} = Nodo(sprintf('N%d', i), 2, [b * (i - 1), 0]');
    nodos{j} = Nodo(sprintf('N%d', j), 2, [b * (i - 1), h]');
end

% Agregamos los nodos al modelo
modeloObj.agregarNodos(nodos);

% Creamos los elementos
elementos = cell(N, 1);
for i = 1:N
    % n4 ------------ n3     Esta es la notacion que se usa para crear los
    %  |              |      elementos.
    %  |      (i)     |
    %  |              |
    % n1 ------------ n2
    n1 = i;
    n2 = i + 1;
    n3 = N + i + 2;
    n4 = N + i + 1;
    elementos{i} = Membrana(sprintf('MEM%d', i), nodos{n1}, nodos{n2}, nodos{n3}, nodos{n4}, E, nu, t);
end

% Agregamos los elementos al modelo
modeloObj.agregarElementos(elementos);

% Creamos las restricciones
restricciones = cell(2, 1);
restricciones{1} = RestriccionNodo('R1', nodos{1}, [1, 2]'); % Apoyo simple en ambos
restricciones{2} = RestriccionNodo('R2', nodos{N+1}, [1, 2]');

% Agregamos las restricciones al modelo
modeloObj.agregarRestricciones(restricciones);

% Creamos la carga
cargas = cell(N, 1);
for i = 1:N
    cargas{i} = CargaMembranaDistribuida(sprintf('DV100KN V @%d', i), elementos{i}, 4, 3, -100, 0, -100, 1);
end

% Creamos el Patron de Cargas
PatronesDeCargas = cell(1, 1);
PatronesDeCargas{1} = PatronDeCargasConstante('CargaConstante', cargas);

% Agregamos las cargas al modelo
modeloObj.agregarPatronesDeCargas(PatronesDeCargas);

% Creamos el analisis
analisisObj = AnalisisEstatico(modeloObj);
analisisObj.analizar();
modeloObj.guardarResultados('test/out/Test_Membrana2.txt');