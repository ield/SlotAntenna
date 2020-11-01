%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	M-file de entrada en el programa ANALISIS v.2000
%			
%				Noviembre 2000
%
%	La funci�n principal del programa es invocada desde
%   aqu�, despu�s de declarar como globales las variables que
%   deben serlo para que MATLAB las reconozca.		  
%
%  Versi�n con ranuras, sondas y cortocircuitos.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

clear all

%===============        Variables globales.      ================

%       Variables de escritorio:
global col_wnd    		% Color de la ventana del programa
global col_bkg    		% Color de fondo del texto
global col_frg    		% Color del texto
global col_eje    		% Color de los ejes
global col_one    		% Color prioritario en las gr�ficas
global col_two    		% Color secundario en las gr�ficas
global mifig      	   % Ventana principal del programa
global Escala3				% Escala de colores para gr�ficos

%	Manejadores de los objetos gr�ficos del programa:
global Hndl_mnus    	% �tems del men� principal del programa
global Hndl_user    	% Manejadores de los objetos de la ventana usuario
global Hndl_graf    	% Manejadores de ejes y gr�ficas

%       Variables de control del flujo:
global Flags        	% Controla la existencia de ciertas variables
global Status       	% Entero que indica la situaci�n actual
global Analisis			% Indica los calculos a  realizar

%       Variables que identifican la antena:
global Nome_Ant  		% Identificador para el usuario
global Fecha     	 	% Fecha de creaci�n del dise�o
global Nome_fich  	% Nombre del fichero
global Camin      	% Camino al fichero

%	Variables que describen la antena:
global datos	   	% Matriz (5,4) con los datos de estructura y frecuencias
global ranuras	    % Matriz (nran,5) de datos de las ranuras
global cortos      	% Matriz (nscc,3) de posiciones del corto
global sondas		% Matriz (nsonda,7) datos de sonda
global puntos		% Matriz (npuntos,2) con datos de puntos de medida
global Frec_obj		% Todas las frecuencias de an�lisis

% 	Variables de salida de la funci�n Analiza
global Vs Is Ic Vr Ir E Hx Hy

%       Variables para almacenar los resultados:
global yvsx			% Par�metros y vs x
global Campo_cop   	% Componente copolar del campo (N_Phi,N_Theta)
global Campo_cros  	% Componente contrapolar
global Tensiones	% Campo en las ranuras
global Parametros	% Par�metros a la frecuencia central

%===============        Fin de variables globales   ============%
	
warning off
proba;			% Programa principal de control de acciones


