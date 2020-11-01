%           		       proba.m

% Version 2000 correspondiente al analisis


%===============        Fin de variables globales   ============%
function [out] = proba(accion,in,in1)
if (nargin<1),
accion='empeza';
end

%===============        Variables globales.      ================

%       Variables de escritorio:
global col_wnd    		% Color de la ventana del programa
global col_bkg    		% Color de fondo del texto
global col_frg    		% Color del texto
global col_eje    		% Color de los ejes
global col_one    		% Color prioritario en las gráficas
global col_two    		% Color secundario en las gráficas
global mifig      	  	% Ventana principal del programa
global Escala3			   % Escala de colores para gráficos

%	Manejadores de los objetos gráficos del programa:
global Hndl_mnus    	% Ítems del menú principal del programa
global Hndl_user    	% Manejadores de los objetos de la ventana usuario
global Hndl_graf    	% Manejadores de ejes y gráficas

%       Variables de control del flujo:
global Flags        	% Controla la existencia de ciertas variables
global Status       	% Entero que indica la situación actual
global Analisis		% Indica los calculos a realizar

%       Variables que identifican la antena:
global Nome_Ant  		% Identificador para el usuario
global Fecha     	 	% Fecha de creación del diseño
global Nome_fich  	% Nombre del fichero
global Camin      	% Camino al fichero

%	Variables que describen la antena:
global datos	   	% Matriz (5,4) con los datos de estructura y frecuencias
global ranuras    	% Matriz (nran,5) de datos de las ranuras
global cortos      	% Matriz (nscc,3) de posiciones del corto
global sondas		   % Matriz (nsonda,7) datos de sonda
global puntos		   % Matriz (npuntos,2) con datos de puntos de medida
global Frec_obj		% Todas las frecuencias de análisis

% 	Variables de salida de la función Analiza
global Vs Is Ic Vr Ir E Hx Hy

%       Variables para almacenar los resultados:
global Campo_cop   	% Componente copolar del campo (N_Phi,N_Theta)
global Campo_cros  	% Componente contrapolar
global Parametros	   % Parametros a la frecuencia central

%===============================================================%
%       			'EMPIEZA' EL PROGRAMA.
%===============================================================%

if strcmp(accion,'empeza'),
out='Gracias por su visita';
load entorno.mat;		% Carga las variables por defecto

% Escala de colores
Escala3=[60 0 0;100 0 20; 100 0 100; 40 40 100; 0 70 80;...
0 100 50;0 50 0; 60 80 0;100 100 0; 100 50 0]/100;  

% 		Definición de manipuladores
Hndl_mnus=-ones(29,1);
Hndl_user=-ones(2,1);
Hndl_graf=-ones(6,1);

Status=0;               	%  La ventana está libre
marca=0;
igual=0;
nf=datos(3,3);
fc=datos(1,4);
bw=datos(3,2);
for i=1:nf,
	Frec_obj(i)=fc+bw/(nf-1)*(i-1)-bw/2;
	if (Frec_obj(i)==fc),
		igual=1;
	end
end
ya=0;
if (igual==0),
	for i=1:nf,
		if (Frec_obj(i)>fc),
			if (ya==0),
				num=i;
			end
			ya=1;
            Frec_obj(i+1)=fc+bw/(nf-1)*(i-1)-bw/2;
		end
	end
	Frec_obj(num)=fc;
end
clear nf bw fc igual ya
for i=1:4,
	for j=1:(length(Frec_obj)+1),
		Parametros(j,1)=-1;
	end
end
for i=1:5,
	Flags(1,i)=0;
end
for i=1:length(Frec_obj),
	Flags(2,i)=0;
end
Nome_Ant='Aplanar';
Nome_fich='*.txt';
Camin=upper([cd,'\']);        % Directorio actual

%	CREACIÓN DE LA VENTANA PRINCIPAL DEL PROGRAMA
mifig=figure('units','normalized',...
'position',[.02 .1 .96 .83],'visible','off',...
'nextplot','replace','backingstore','off',...
'resize','on');

%	CREACIÓN DE LOS OBJETOS GRÁFICOS DE LA VENTANA
Hndl_graf(2)=plot([0 1],[datos(4,5) 0],'-');
hold on
Hndl_graf(3)=plot([0 1],[datos(4,5) 0],'--');
set(Hndl_graf(2),'color',col_one,'visible','off');
set(Hndl_graf(3),'color',col_two,'visible','off');

Hndl_graf(1)=gca;
set(Hndl_graf(1),'visible','off','xcolor',col_eje,'ycolor',...
col_eje,'box','on','xgrid','on','ygrid','on','drawmode','fast');

Hndl_graf(4)=text('units','normalized','pos',[.5 1.02],'color',...
col_eje,'string','Título','horizontal','center','vertical','bottom',...
'visible','off');

Hndl_graf(5)=text('units','normalized','pos',[0 .98],'color',...
col_one,'string','id_one','horizontal','left','vertical','top',...
'visible','off');

Hndl_graf(6)=text('units','normalized','pos',[1 .98],'color',...
col_two,'string','id_two','horizontal','right','vertical','top',...
'visible','off');

set(mifig,'numbertitle','off','menubar','none','name','APLANAR v.2000');


%       CREACIÓN DE LOS MENÚS PRINCIPALES DEL PROGRAMA

%       MENÚ "ARCHIVO"

Hndl_mnus(1)=uimenu(mifig,'label','Archivo');

Hndl_mnus(2)=uimenu(Hndl_mnus(1),'label','Carga Fichero');

Hndl_mnus(21)=uimenu(Hndl_mnus(2),'label','Carga Fichero de diseño',...
'call',['proba(''limpia'');',...
'[Nome,camin]=uigetfile(''*.asc'',''Load design file'',12,12);',...
'if Nome~=0,','proba(''carga'',camin,Nome);',...
'end,','clear camin Nome,']);

Hndl_mnus(22)=uimenu(Hndl_mnus(2),'label','Carga fichero de análisis',...
'call',['proba(''limpia'');',...
'[Nome,camin]=uigetfile(''*.ana'',''Carga fichero de análisis'',12,12);',...
'if Nome~=0,','proba(''carga_ana'',camin,Nome);',...
'end,','clear camin Nome,']);

Hndl_mnus(3)=uimenu(Hndl_mnus(1),'label','Salvar fichero',...
'Enable','off','call',...
['[Nome,camin]=uiputfile(''*.ana'',''Salvar fichero '',10,10);',...
'if Nome~=0,','proba(''guarda'',camin,Nome);',...
'end,','clear camin Nome,']);

uimenu(Hndl_mnus(1),'label','Configurar Impresora',...
'separator','on','call',['proba(''limpia'');','print -dsetup']);

Hndl_mnus(4)=uimenu(Hndl_mnus(1),'enable','off','label','Imprimir',...
'call',['set(mifig,''paperposition'',[0 -4 6 4]);',...
'print -dwin -v']);

Hndl_mnus(5)=uimenu(Hndl_mnus(1),'enable','off','label','Exportar Figura');

uimenu(Hndl_mnus(5),'label','Metafile a Clipboard',...
'call','proba(''get_export'',1);');

uimenu(Hndl_mnus(5),'label','Bitmap a Clipboard',...
'call','proba(''get_export'',2);');

uimenu(Hndl_mnus(5),'label','Gif 8 bits a file',...
'call','proba(''get_export'',3);');

uimenu(Hndl_mnus(5),'label','Postcript a fichero',...
'call','proba(''get_export'',4);');

uimenu(Hndl_mnus(5),'label','E-Postcript a fichero',...
'call','proba(''get_export'',5);');

uimenu(Hndl_mnus(5),'label','DXF a fichero',...
'call','proba(''get_export'',6);');

uimenu(Hndl_mnus(1),'label','Salir','separator','on',...
'call',['proba(''acaba'');','close']);

%	  MENÚ "UTILITIES"

Hndl_mnus(6)=uimenu(mifig,'label','Utilidades');

Hndl_mnus(7)=uimenu(Hndl_mnus(6),'label','Análisis',...
'enable','off','call',['proba(''analize'');']);

Hndl_mnus(27)=uimenu(Hndl_mnus(6),'label','Opciones');

uimenu(Hndl_mnus(27),'label','Opciones de dibujo','call',['proba(''get_plt'');']);

uimenu(Hndl_mnus(27),'label','Opciones de análisis','call',['proba(''get_ana'');']);

Hndl_mnus(8)=uimenu(Hndl_mnus(6),'label','Colores',...
'separator','on');

uimenu(Hndl_mnus(8),'label','Color de la pantalla',...
'separator','off','call',...
['proba(''limpia'');','col_wnd=uisetcolor(gcf,''Color de la pantalla'');',...
'if (col_wnd*[.3;.54;.16]>.7),',...
'set(mifig,''inverthardcopy'',''off'');',...
'else,',...
'set(mifig,''inverthardcopy'',''on'');',...
'end,']);

uimenu(Hndl_mnus(8),'label','Color de los ejes en gráficas',...
'separator','on','call',...
['proba(''limpia'');',...
'col_eje=uisetcolor(Hndl_graf(4),''Color de los ejes en gráficas'');',...
'set(Hndl_graf(1),''xcolor'',col_eje,''ycolor'',col_eje);',...
'set(Hndl_graf(4),''color'',col_eje);',...
'if ((Status>=31) & (Status<=35)),',...
'set(Hndl_graf(7:length(Hndl_graf)),''color'',col_eje);','end,',...
'if (Status==22),','set(Hndl_graf(8),''color'',col_eje);','end']);

uimenu(Hndl_mnus(8),'label','Color principal en gráficas',...
'separator','off','call',...
['proba(''limpia'');',...
'col_one=uisetcolor(Hndl_graf(2),''Color principal en gráficas'');',...
'set(Hndl_graf(5),''color'',col_one);']);

uimenu(Hndl_mnus(8),'label','Segundo color en gráficas',...
'separator','off','call',...
['proba(''limpia'');',...
'col_two=uisetcolor(Hndl_graf(3),''Segundo color en gráficas'');',...
'set(Hndl_graf(6),''color'',col_two);','if (Status==22),',...
'set(Hndl_graf(7),''color'',col_two);','end']);

uimenu(Hndl_mnus(8),'label','Color del fondo del texto',...
'separator','on','call',...
['proba(''limpia'');',...
'col_bkg=uisetcolor(col_bkg,''Color del fondo de texto'');']);

uimenu(Hndl_mnus(8),'label','Color del texto',...
'separator','off','call',...
['proba(''limpia'');',...
'col_frg=uisetcolor(col_frg,''Color del texto'');']);

Hndl_mnus(9)=uimenu(Hndl_mnus(6),'label','Limpiar Pantalla',...
'enable','off','call','proba(''limpia'');');

%       MENÚ "PLOT"

Hndl_mnus(10)=uimenu(mifig,'label','Dibuja');

Hndl_mnus(11)=uimenu(Hndl_mnus(10),'label',...
'Estructura de antena','Enable','off','call',...
['set(mifig,''pointer'',''watch'');',...
'if Status,','proba(''limpia'');','end,',...
'Status=22;','proba(''dib_ant'');']);

Hndl_mnus(12)=uimenu(Hndl_mnus(10),'label','Campos en las aperturas','Enable','off') ;

Hndl_mnus(13)=uimenu(Hndl_mnus(12),'label','Amplitud','call',...
['set(mifig,''pointer'',''watch'');',...
'if Status,','proba(''limpia'');','end,',...
'Status=50;','proba(''dib_ant'');']);

Hndl_mnus(14)=uimenu(Hndl_mnus(12),'label','Fase','call',...
['set(mifig,''pointer'',''watch'');',...
'if Status,','proba(''limpia'');','end,',...
'Status=51;','proba(''dib_ant'');']);

Hndl_mnus(15)=uimenu(Hndl_mnus(10),'Enable','off','label',...
'Parámetros a la frecuencia central','call',...
['set(mifig,''pointer'',''watch'');',...
'if Status,','proba(''limpia'');','end,',...
'proba(''ver_par'');']);

Hndl_mnus(16)=uimenu(Hndl_mnus(10),'Enable','off',...
'label','Parámetros de Antena vs Frecuencia');

Hndl_mnus(17)=uimenu(Hndl_mnus(16),'label','Eficiencia de radiación','call',...
['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=31;','proba(''dib_res_2d'');']);

Hndl_mnus(18)=uimenu(Hndl_mnus(16),'label','Directividad','call',...
['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=32;','proba(''dib_res_2d'');']);

Hndl_mnus(19)=uimenu(Hndl_mnus(16),'label','Ganancia','call',...
['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=33;','proba(''dib_res_2d'');']);

Hndl_mnus(20)=uimenu(Hndl_mnus(16),'label','Coeficiente de Reflexión','call',...
['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=41;','proba(''dib_res_2d'');']);

Hndl_mnus(23)=uimenu(Hndl_mnus(10),'label','Diagrama de Radiación','Enable','off') ;

Hndl_mnus(24)=uimenu(Hndl_mnus(23),'label','Copolar/Contrapolar vs Theta',...
'call',['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=23;','StrFcn=''next_corte'';',...
'set(mifig,''buttondownfcn'',''proba(StrFcn)'');',...
'proba(''dib_cpo_2d'');']);

Hndl_mnus(25)=uimenu(Hndl_mnus(23),'label','Copolar/Contrapolar vs Phi',...
'call',['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=25;','StrFcn=''next_corte'';',...
'set(mifig,''buttondownfcn'',''proba(StrFcn)'');',...
'proba(''dib_cpo_2d'');']);

Hndl_mnus(26)=uimenu(Hndl_mnus(23),'label','Copolar 3D',...
'separator','on','call',...
['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=27;','proba(''dib_cpo_3d'');']);

Hndl_mnus(29)=uimenu(Hndl_mnus(10),'label',...
'Campo en los puntos de medida','Enable','off');

uimenu(Hndl_mnus(29),'label','Amplitud (dB)',...
'call',['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=44;','proba(''dib_res_2d'');']);

uimenu(Hndl_mnus(29),'label','Fase (deg)',...
'call',['set(mifig,''pointer'',''watch'');',...
'if (Status>0),','proba(''limpia'');','end,',...
'Status=45;','proba(''dib_res_2d'');']);


%       MENÚ "AYUDA"

Hndl_mnus(28)=uimenu(mifig,'label','Ayuda');

uimenu(Hndl_mnus(28),'label','Acerca',...
'call',['proba(''limpia'');','message;']);

uimenu(mifig,'label','','Enable','off');

%	CONTROL DE LOS MENÚS:

set(Hndl_mnus([1:2,6,8,28]),'enable','on');

%	CREACIÓN DE LOS BOTONES DE CONTROL

Hndl_user(1)=uicontrol(mifig,'style','push','units','normalized',...
'position',[.8 .1 .15 .35],'visible','off',...
'string','OK','call',',');

Hndl_user(2)=uicontrol(mifig,'style','push','units','normalized',...
'position',[.8 .55 .15 .35],'visible','off',...
'string','Cancel','call',',');

%	MOSTRAR VENTANA Y ESTABLECER SUS PROPIEDADES DE IMPRESIÓN

set(mifig,'visible','on','color',col_wnd,'paperorient','portrait',...
'paperunits','normalized','papertype','a4letter',...
'userdata',[1;1]);

%===============================================================%
%       IMPLEMENTACIÓN DE LAS FUNCIONES ESPECÍFICAS.
%===============================================================%

%---------------------------------------------------------------%
%	FUNCIÓN LIMPIA
%---------------------------------------------------------------%

%	Función que limpia la ventana: 'limpia'
elseif strcmp(accion,'limpia')

if (length(Hndl_user)>=3),  % Hay objetos de entrada/salida
	delete(Hndl_user(3:length(Hndl_user)));
	Hndl_user=Hndl_user(1:2);
	set(Hndl_user,'visible','off');
end

if (length(Hndl_graf)>=7),  % Hay objetos gráficos
	delete(Hndl_graf(7:length(Hndl_graf)));
	Hndl_graf=Hndl_graf(1:6);
end

set(Hndl_graf,'visible','off');
set(Hndl_graf(1),'drawmode','fast');
set(mifig,'buttondownfcn',' ','userdata',[1;1]);
xlabel('');
ylabel('');

% Inhibe los menús IMPRIMIR, EXPORTAR y LIMPIAR VENTANA:

set(Hndl_mnus([4,5,9]),'Enable','off');
if (Status~=0), set(Hndl_mnus([10,11]),'Enable','on'); end

%---------------------------------------------------------------%
%	Fin de 'limpia'
%---------------------------------------------------------------%
%  Bloque que salva el análisis en un fichero texto

elseif strcmp (accion,'guarda'),

Nome_fich=[in,in1];
Camin=upper(in);

fid=fopen(Nome_fich,'w');

fprintf(fid,'          APLANAR v.2000     %s\n');
fprintf(fid,'ANÁLISIS DE ANTENAS PLANAS DE RANURAS SOBRE GUÍA RADIAL.\n\n');
fprintf(fid,'Nombre de la antena:   \t%s\n',Nome_Ant);
fprintf(fid,'Fecha de diseño:       \t%s\n',mitime);
fprintf(fid,'Fichero:               \t%s\n\n',Nome_fich);


%  Primero guardamos la matriz de datos

fprintf(fid,'Datos para el análisis:	\t\n');
fprintf(fid,'Número de sondas:		 \t%5i\n',datos(2,1));
fprintf(fid,'Número de ranuras:      \t%5i\n',datos(2,2));
fprintf(fid,'Número de cortos:  	    \t%5i\n',datos(2,3));
fprintf(fid,'Número de sondas med:   \t%5i\n',datos(2,4));

fprintf(fid,'Frecuencia central:	    \t%7.3f\n',datos(1,4));
fprintf(fid,'Ancho de banda: 		    \t%7.3f\n',datos(3,2));
fprintf(fid,'Número de frecuencias:  \t%5i\n',datos(3,3));

fprintf(fid,'Mínimo ángulo theta:  	 \t%7.3f\n',datos(4,1));
fprintf(fid,'Máximo ángulo theta:    \t%7.3f\n',datos(4,2));
fprintf(fid,'Mínimo ángulo phi:  	 \t%7.3f\n',datos(4,3));
fprintf(fid,'Máximo ángulo phi:    	 \t%7.3f\n',datos(4,4));
fprintf(fid,'Mínimo valor del campo: \t%7.3f\n',datos(4,5));

fprintf(fid,'Resolución en theta:    \t%5i\n',datos(5,1));	
fprintf(fid,'Resolución en phi:      \t%5i\n',datos(5,2));
fprintf(fid,'Polarización:    		 \t%5i\n',datos(5,3));	
fprintf(fid,'Ángulo de Pol. linear:  \t%7.3f\n',datos(5,4));

fprintf(fid,'Calculados campos:	    \t%5i\n',Analisis(1));	
fprintf(fid,'Calculados diagramas:   \t%5i\n',Analisis(2));
fprintf(fid,'Calculados parám. fc: 	 \t%5i\n',Analisis(3));	
fprintf(fid,'Calculado par vs f:	    \t%5i\n\n',Analisis(4));

fprintf(fid,'Número de Frecuencias:	 \t%5i\n\n',length(Frec_obj));

if (Analisis(1)==1),
	fprintf(fid,'Tensiones en las ranuras de  (dB deg):	 \n');
	for i=1:datos(2,2),
		fprintf(fid,'%7.3f %7.3f \n',[20*log10(abs(Vr(i)));180/pi*angle(Vr(i))]);
	end
	fprintf(fid,'Campo en las sondas de prueba (Re(E) Im(E)):\n');
	for i=1:datos(2,4),
		fprintf(fid,'%7.3f %7.3f \n',[real(E(i));imag(E(i))]);
	end
end
if (Analisis(2)==1),
	fprintf(fid,'Diagrama de radiación:		\n');
	fprintf(fid,'Componente Copolar:	\n');
	for i=1:datos(5,2),
		for j=1:datos(5,1),
			fprintf(fid,'%7.3f\t',Campo_cop(i,j));
		end
		fprintf(fid,'\n');
	end
	fprintf(fid,'Componente Contrapolar:	\n');
	for i=1:datos(5,2),
		for j=1:datos(5,1),
			fprintf(fid,'%7.3f\t',Campo_cros(i,j));
		end
		fprintf(fid,'\n');
	end
end
if (Analisis(3)==1),
   fprintf(fid,'Parámetros a la frecuencia central: \n');
   fprintf(fid,'Coef Reflexión (dB):   %7.3f\n',Parametros(1,1));
   fprintf(fid,'Directividad (dBi):		%7.3f\n',Parametros(1,2));
   fprintf(fid,'Ganancia (dBi):			%7.3f\n',Parametros(1,3));
   fprintf(fid,'Ef. total:         %7.3f\n',Parametros(1,4));
end

if (Analisis(4)==1),
	P=Parametros;
	fprintf(fid,'Parámetros vs frecuencia: \n');
	fprintf(fid,'Frec.  Refl.	Dir.  Gan. Efic. \n');
	for i=1:length(Frec_obj),
		fprintf(fid,'%7.3f %7.3f %7.3f %7.3f %7.3f \n',...
				[Frec_obj(i) P(i+1,1) P(i+1,2) P(i+1,3) P(i+1,4)]);
	end
	clear P
end
fclose(fid);

% Bloque que carga los datos de análisis de un fichero texto.

elseif strcmp(accion,'carga_ana'),

proba('limpia');
Nome_fich=[in,in1];
Camin=upper(in);
Nome_Ant=upper(in1);
file=fopen(Nome_fich,'r+');

nada=fscanf(file,'%s',2);
nada=fscanf(file,'%s',9);
nada=fscanf(file,'%s',4);
Nome_Ant=fscanf(file,'%s',1);
nada=fscanf(file,'%s',5);
nada=fscanf(file,'%s',2);

nada=fscanf(file,'%s',4);
nada=fscanf(file,'%s',3);
ns=fscanf(file,'%5i');
nada=fscanf(file,'%s',3);
nrr=fscanf(file,'%5i');
nada=fscanf(file,'%s',3);
nc=fscanf(file,'%5i');
nada=fscanf(file,'%s',4);
np=fscanf(file,'%5i');

nada=fscanf(file,'%s',2);
datos(1,4)=fscanf(file,'%f');
nada=fscanf(file,'%s',3);
datos(3,2)=fscanf(file,'%f');
nada=fscanf(file,'%s',3);
datos(3,3)=fscanf(file,'%5i');

nada=fscanf(file,'%s',3);
datos(4,1)=fscanf(file,'%f');
nada=fscanf(file,'%s',3);
datos(4,2)=fscanf(file,'%f');
nada=fscanf(file,'%s',3);
datos(4,3)=fscanf(file,'%f');
nada=fscanf(file,'%s',3);
datos(4,4)=fscanf(file,'%f');
nada=fscanf(file,'%s',4);
datos(4,5)=fscanf(file,'%f');

nada=fscanf(file,'%s',3);
datos(5,1)=fscanf(file,'%i');
nada=fscanf(file,'%s',3);
datos(5,2)=fscanf(file,'%i');
nada=fscanf(file,'%s',1);
datos(5,3)=fscanf(file,'%i');
nada=fscanf(file,'%s',4);
datos(5,4)=fscanf(file,'%f');

nada=fscanf(file,'%s',2);
Analisis(1)=fscanf(file,'%i');
nada=fscanf(file,'%s',2);
Analisis(2)=fscanf(file,'%i');
nada=fscanf(file,'%s',3);
Analisis(3)=fscanf(file,'%i');
nada=fscanf(file,'%s',4);
Analisis(4)=fscanf(file,'%i');

nada=fscanf(file,'%s',3);
nf=fscanf(file,'%5i',1);

if (ns~=datos(2,1))|(nrr~=datos(2,2))|...
	(nc~=datos(2,3))|(np~=datos(2,4)),
	datos(2,1)=ns;
	datos(2,2)=nrr;
	datos(2,3)=nc;
	datos(2,4)=np;
	set(Hndl_mnus(11),'enable','off');
end

if (Analisis(1)==1), 
	Flags(1,1)=1; 
	if (datos(2,2)~=0), set(Hndl_mnus([12:14]),'enable','on'); end
	if (datos(2,4)~=0), set(Hndl_mnus(29),'enable','on'); end
	nada=fscanf(file,'%s',6);
	Vr=fscanf(file,'%f');
	nada=fscanf(file,'%s',8);
	for i=1:datos(2,4)
		reE=fscanf(file,'%f',1);
		imE=fscanf(file,'%f',1);
		E(i)=reE+sqrt(-1)*imE;
	end
	clear reE imE
else
	Flags(1,1)=0;
end

if (Analisis(2)==1),
	Flags(1,2)=1;
	set(Hndl_mnus([23:26]),'enable','on');
	nada=fscanf(file,'%s',3);
	nada=fscanf(file,'%s',2);
	for i=1:datos(5,2),
		for j=1:datos(5,1),
			Campo_cop(i,j)=fscanf(file,'%f',1);
		end
	end
	nada=fscanf(file,'%s',2);
	for i=1:datos(5,2),
		for j=1:datos(5,1),
			Campo_cros(i,j)=fscanf(file,'%f',1);
		end
	end
else
	Flags(1,2)=0;
end

if (Analisis(3)==1),
	Flags(1,3)=1;
	set(Hndl_mnus(15),'enable','on');
	nada=fscanf(file,'%s',5);
	nada=fscanf(file,'%s',3);
	Parametros(1,1)=fscanf(file,'%f');
	nada=fscanf(file,'%s',2);
	Parametros(1,2)=fscanf(file,'%f',1);
	nada=fscanf(file,'%s',2);
	Parametros(1,3)=fscanf(file,'%f');
	nada=fscanf(file,'%s',2);
   Parametros(1,4)=fscanf(file,'%f');
 else
	Flags(1,3)=0;
end

if (Analisis(4)==1),
	Flags(1,4)=1;
	set(Hndl_mnus([16:22]),'enable','on');
   nada=fscanf(file,'%s',3);
	nada=fscanf(file,'%s',5);
	for i=1:nf,
		Frec_obj(i)=fscanf(file,'%f',1);
		Parametros(1+i,1)=fscanf(file,'%f',1);
		Parametros(1+i,2)=fscanf(file,'%f',1);
		Parametros(1+i,3)=fscanf(file,'%f',1);
      Parametros(1+i,4)=fscanf(file,'%f',1);
      Flags(2,i)=1;
	end
else
	Flags(1,4)=0;
	for i=1:nf,
		Flags(2,i)=0;
	end
end

%  Bloque que carga los datos desde un fichero texto.

elseif strcmp(accion,'carga'),

proba('limpia');
Nome_fich=[in,in1];
Camin=upper(in);
Nome_Ant=upper(in1);

% Inicializamos datos de estructura
ranuras=[];
cortos=[];
sondas=[];
puntos=[];

file=fopen(Nome_fich,'r+');

nada=fscanf(file,'%s',1);
datos(1,1)=fscanf(file,'%5e');	  %Altura de la guía
nada=fscanf(file,'%s',1);
datos(1,2)=fscanf(file,'%5e');	  %Espesor de la placa superior
nada=fscanf(file,'%s',1);
datos(1,3)=fscanf(file,'%5e');	  %Constante dieléctrica
nada=fscanf(file,'%s',1);
datos(2,1)=fscanf(file,'%3d');	  %Número de sondas
nada=fscanf(file,'%s',1);
for i=1:datos(2,1),
    for j=1:7,
		sondas(i,j)=fscanf(file,'%8e',1);
    end
end 
nada=fscanf(file,'%s',1);
datos(2,2)=fscanf(file,'%6d');	  %Número de ranuras
nada=fscanf(file,'%s',1);
for i=1:datos(2,2),
    for j=1:5,
	ranuras(i,j)=fscanf(file,'%8e',1);
   end
end
nada=fscanf(file,'%s',1);
datos(2,3)=fscanf(file,'%3d');	  %Número de cortos
nada=fscanf(file,'%s',1);
for i=1:datos(2,3),
    for j=1:3,
	cortos(i,j)=fscanf(file,'%8e',1);
    end
end
nada=fscanf(file,'%s',1);
datos(2,4)=fscanf(file,'%3d');	  %Número de sondas de campo
nada=fscanf(file,'%s',1);
for i=1:datos(2,4),
    for j=1:2,
	puntos(i,j)=fscanf(file,'%8e',1);
    end
end

fclose(file);
% Conversión a radianes
if datos(2,1)~=0, sondas(:,6)=sondas(:,6)*pi/180;  end
if datos(2,2)~=0, ranuras(:,5)=ranuras(:,5)*pi/180;	 end
%
for i=1:5,
	Flags(1,i)=0;
end
for i=1:length(Frec_obj),
	Flags(2,i)=0;
end
Status=22;
proba('dib_ant');


%---------------------------------------------------------------%
%	GET EXPORT
%---------------------------------------------------------------%

%	Función que establece el formato elegido: 'get_export'

elseif strcmp(accion,'get_export')

if in==1, 
	valido=1;
	str=['print -dmeta'];
elseif in==2,
	valido=1;
	str=['print -dbitmap'];
elseif in==3,
	[nome,camin]=uiputfile('*.gif','Guardar gráfica',12,12);
	if nome~=0,
		valido=1;
		str=['print -dgif8 ',[camin,nome]];
    end
    clear camin nome
elseif in==4
	[nome,camin]=uiputfile('*.ps','Guardar gráfica',12,12);
	if nome~=0,
		valido=1;
		str=['print -dps ',[camin,nome]];
    end
    clear camin nome
elseif in==5
	[nome,camin]=uiputfile('*.eps','Guardar gráfica',12,12);
	if nome~=0,
		valido=1;
		str=['print -deps ',[camin,nome]];
    end
    clear camin nome
elseif in==6
	[nome,camin]=uiputfile('*.dxf','Guardar gráfica',12,12);
	if nome~=0,
		valido=0;
		Nome_fich=[camin,nome];
		fid=fopen(Nome_fich,'w');
		
		fprintf(fid,'  0\n');
		fprintf(fid,'SECTION\n');
		fprintf(fid,'  2\n');
		fprintf(fid,'HEADER\n');
		fprintf(fid,'  9\n');
		fprintf(fid,'$ACADVER\n');
		fprintf(fid,'  1\n');
		fprintf(fid,'AC1009\n');
		fprintf(fid,'  0\n');
		fprintf(fid,'ENDSEC\n');
		fprintf(fid,'  0\n');
		fprintf(fid,'SECTION\n');
		fprintf(fid,'  2\n');
		fprintf(fid,'ENTITIES\n');
		fprintf(fid,'  0\n');
        if datos(2,3)~=0,
         % pinta el cortocircuito
        fprintf(fid,'POLYLINE\n');
        fprintf(fid,'   5\n');
        fprintf(fid,'74\n');
		fprintf(fid,'  8\n');
		fprintf(fid,'0\n');
		fprintf(fid,' 66\n');
		fprintf(fid,'     2\n');
        fprintf(fid,' 10\n');
		fprintf(fid,'0.0\n');
		fprintf(fid,' 20\n');
		fprintf(fid,'0.0\n');
		fprintf(fid,' 30\n');
		fprintf(fid,'0.0\n');
        fprintf(fid,'   0\n');
        for ncor=1:datos(2,3),
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7C\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,' 10\n');
			fprintf(fid,'%7.5f\n',cortos(ncor,1));
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',cortos(ncor,2));
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
        end
        %  Cierra repitiendo el primer punto
        fprintf(fid,'VERTEX\n');
        fprintf(fid,'   5\n');
        fprintf(fid,'7C\n');
		fprintf(fid,'  8\n');
		fprintf(fid,'0\n');
		fprintf(fid,' 10\n');
		fprintf(fid,'%7.5f\n',cortos(1,1));
		fprintf(fid,' 20\n');
		fprintf(fid,'%7.5f\n',cortos(1,2));
		fprintf(fid,' 30\n');
		fprintf(fid,'0.0\n');
        fprintf(fid,'   0\n');
        fprintf(fid,'SEQEND\n');
        fprintf(fid,'   5\n');
        fprintf(fid,'7E\n');
		fprintf(fid,'  8\n');
		fprintf(fid,'0\n');
        fprintf(fid,'   0\n');
        end
        if datos(2,2)~=0,
        % pinta las ranuras
		for i=1:datos(2,2),
			x=ranuras(i,1);
			y=ranuras(i,2);
			l=ranuras(i,3);
			w=ranuras(i,4);
			alfa=ranuras(i,5);
			x4=x+l/2*cos(alfa)-w/2*sin(alfa);
			y4=y+l/2*sin(alfa)+w/2*cos(alfa);
			x1=x-l/2*cos(alfa)-w/2*sin(alfa);
			y1=y-l/2*sin(alfa)+w/2*cos(alfa);
			x2=x-l/2*cos(alfa)+w/2*sin(alfa);
			y2=y-l/2*sin(alfa)-w/2*cos(alfa);
			x3=x+l/2*cos(alfa)+w/2*sin(alfa);
			y3=y+l/2*sin(alfa)-w/2*cos(alfa);
			fprintf(fid,'POLYLINE\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'74\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'1\n');
			fprintf(fid,' 66\n');
			fprintf(fid,'     2\n');
            fprintf(fid,' 10\n');
			fprintf(fid,'0.0\n');
			fprintf(fid,' 20\n');
			fprintf(fid,'0.0\n');
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7C\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,' 10\n');
			fprintf(fid,'%7.5f\n',x1);
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',y1);
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7D\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,' 10\n');
			fprintf(fid,'%7.5f\n',x2);
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',y2);
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7E\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,'10\n');
			fprintf(fid,'%7.5f\n',x3);
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',y3);
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7F\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,' 10\n');
			fprintf(fid,'%7.5f\n',x4);
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',y4);
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
			fprintf(fid,'   0\n');
            fprintf(fid,'VERTEX\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7C\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
			fprintf(fid,' 10\n');
			fprintf(fid,'%7.5f\n',x1);
			fprintf(fid,' 20\n');
			fprintf(fid,'%7.5f\n',y1);
			fprintf(fid,' 30\n');
			fprintf(fid,'0.0\n');
            fprintf(fid,'   0\n');
            fprintf(fid,'SEQEND\n');
            fprintf(fid,'   5\n');
            fprintf(fid,'7E\n');
			fprintf(fid,'  8\n');
			fprintf(fid,'0\n');
            fprintf(fid,'   0\n');
        end
        end
        % Finaliza el dxf
        fprintf(fid,'ENDSEC\n');
		fprintf(fid,'   0\n');
		fprintf(fid,'EOF\n');
	end
	fclose(fid);
	clear camin nome x l w alfa y x1 y1 x2 y3 x3 y3 x4 y4 
end

if valido,
	eval(str);
end
clear str valido


%---------------------------------------------------------------%
%	VER PARÁMETROS A FRECUENCIA CENTRAL
%---------------------------------------------------------------%
%
elseif strcmp(accion,'ver_par')

Hndl_user=[Hndl_user;zeros(11,1)];

Hndl_user(3)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'PARAMETROS A LA FRECUENCIA CENTRAL:','foreg',col_frg,...
'units','normalized','position',[.1 .86 .6 .04]);

Hndl_user(4)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Frecuencia (GHz):  ','units',...
'normalized','position',[.2 .72 .5 .04],'horizontal','left');

Hndl_user(5)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Coeficiente de reflexión (dB):  ','units',...
'normalized','position',[.2 .64 .5 .04],'horizontal','left');

Hndl_user(6)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Directividad (dB):  ','units',...
'normalized','position',[.2 .56 .5 .04],'horizontal','left');

Hndl_user(7)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ganancia (dB): ','units',...
'normalized','position',[.2 .48 .5 .04],'horizontal','left');

Hndl_user(8)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Eficiencia total (%): ','units',...
'normalized','position',[.2 .40 .5 .04],'horizontal','left');

Hndl_user(9)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(1,4)),'units','normalized','position',...
[.55 .72 .05 .04],'visible','on');

Hndl_user(10)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(Parametros(1,1)),'units','normalized','position',...
[.55 .64 .05 .04],'visible','on');

Hndl_user(11)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(Parametros(1,2)),'units','normalized','position',...
[.55 .56 .05 .04],'visible','on');

Hndl_user(12)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(Parametros(1,3)),'units','normalized','position',...
[.55 .48 .05 .04],'visible','on');

Hndl_user(13)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(Parametros(1,4)),'units','normalized','position',...
[.55 .40 .05 .04],'visible','on');

set(Hndl_mnus([4,5,9]),'Enable','on');

%---------------------------------------------------------------%
%	DIAGRAMAS 2D
%---------------------------------------------------------------%
%       Funciones de representación de los diagramas:
elseif strcmp(accion,'dib_cpo_2d')

if (nargin==1),
	in=[1;1];
end
for i=1:datos(5,1),
	Theta_diag(i)=datos(4,1)+(i-1)*(datos(4,2)-datos(4,1))/(datos(5,1)-1);
end
for i=1:datos(5,2),
	Phi_diag(i)=(datos(4,3)+(i-1)*(datos(4,4)-datos(4,3))/(datos(5,2)-1));
end
if (Status==23),  % Copolar/Contrapolar vs Theta
	labelx='Theta (deg)';
	corte=['Phi= ',num2str(Phi_diag(in(2)))];
	x=Theta_diag;
	y1=Campo_cop(in(2),:);
   y2=Campo_cros(in(2),:);
elseif (Status==25),  % Copolar/Contrapolar vs Phi
	labelx='Phi (deg)';
	corte=['Theta= ',num2str(Theta_diag(in(1)))];
	x=Phi_diag;
	y1=Campo_cop(:,in(1));
   y2=Campo_cros(:,in(1));
end
tit='Copolar y Contrapolar.  ';
id1=' Copolar (-)';
id2=' Contrapolar (:) ';
y1=max(y1,datos(4,5));
y2=max(y2,datos(4,5));
marcax=[linspace(min(x),max(x),13)];
if (marcax(13)~=max(x))
	marcax=[marcax,max(x)];
end
marcax=round(10*marcax)/10;
tit=[tit,num2str(datos(1,4)),' GHz, para ',corte,'. ',Nome_Ant];
set(Hndl_graf(1),'visible','on','xlim',[min(x) max(x)],'ylim',[datos(4,5) 0],...
   'pos',[.13 .11 .775 .815],'view',[0 90],'PlotBoxAspectRatio',[3 2 1],...
   'xtickmode','auto','ytickmode','auto');
set(Hndl_graf(2),'visible','on','xdata',x,'ydata',y1);
set(Hndl_graf(3),'visible','on','xdata',x,'ydata',y2);
set(Hndl_graf(4),'visible','on','string',tit);
set(Hndl_graf(5),'visible','on','string',id1);
set(Hndl_graf(6),'visible','on','string',id2);
set(Hndl_mnus([4,5,9]),'Enable','on');
set(mifig,'pointer','arrow');
clear Theta_diag Phi_diag marcax tit y1 y2 id1 id2 corte labelx x

%---------------------------------------------------------------%
%	CAMBIO DE PLANO ANGULAR
%---------------------------------------------------------------%
%	Función llamada al pulsar un botón cuando se está repre-
%   sentando un corte en Phi del diagrama de radiación, para que
%   dibuje el siguiente corte: 'next_corte'
elseif strcmp(accion,'next_corte')

set(mifig,'units','normal');
n=get(mifig,'userdata');
punto=get(mifig,'CurrentPoint');
if (punto(2)<.5), % Pasar al corte anterior:
	increm=-1;
else
	increm=1;
end
for i=1:datos(5,1),
	Theta_diag(i)=datos(4,1)+(i-1)*(datos(4,2)-datos(4,1))/(datos(5,1)-1);
end
for i=1:datos(5,2),
	Phi_diag(i)=(datos(4,3)+(i-1)*(datos(4,4)-datos(4,3))/(datos(5,2)-1));
end
if (Status==23),     % Cambiar corte en Phi
	n(2)=n(2)+increm;
	if (n(2)>length(Phi_diag)),
		n(2)=1;
	end
	if (n(2)<1),
        	n(2)=length(Phi_diag);
	end
elseif (Status==25), % Cambiar corte en Theta
	n(1)=n(1)+increm;
	if (n(1)>length(Theta_diag)),
		n(1)=1;
	end
        if (n(1)<1),
		n(1)=length(Theta_diag);
	end
end

set(mifig,'userdata',n);
proba('dib_cpo_2d',n);
clear punto n increm Theta_diag Phi_diag

%	Fin de 'next_corte'.


%---------------------------------------------------------------%
%	DIAGRAMAS 3D
%---------------------------------------------------------------%
%       Funciones de representación de los diagramas:
elseif strcmp(accion,'dib_cpo_3d')

for i=1:datos(5,1),
	Theta_diag(i)=datos(4,1)+(i-1)*(datos(4,2)-datos(4,1))/(datos(5,1)-1);
end
for i=1:datos(5,2),
	Phi_diag(i)=(datos(4,3)+(i-1)*(datos(4,4)-datos(4,3))/(datos(5,2)-1));
end
x=cos(pi/180*Phi_diag')*sin(pi/180*Theta_diag);
y=sin(pi/180*Phi_diag')*sin(pi/180*Theta_diag);
if (Status==27),  % Copolar 3D
	tit='Copolar ';
	z=Campo_cop;
end
z=max(z,datos(4,5));
tit=[tit,num2str(datos(1,4)),' GHz. ',Nome_Ant];
set(Hndl_graf(1),'visible','off','xlim',[-1.2 1.2],'xtick',[],...
'ylim',[-1.2 1.2],'ytick',[],'zlim',[datos(4,5) 5],'ztick',[datos(4,5):10:0],...
'view',[130 20],'pos',[.15 .11 .65 .815],'PlotBoxAspectRatio',[1 1 1]);
Hndl_graf=[Hndl_graf;-ones(6,1)];
Hndl_graf(8)=plot3([0 1.2],[0 0],[datos(4,5) datos(4,5)]);
Hndl_graf(9)=plot3([0 0],[0 1.2],[datos(4,5) datos(4,5)]);
Hndl_graf(10)=plot3([0 0],[0 0],[datos(4,5) 10]);
Hndl_graf(11)=text('units','data','pos',[1.2 0 datos(4,5)],'string','X');
Hndl_graf(12)=text('units','data','pos',[0 1.2 datos(4,5)],'string','Y');
set(Hndl_graf(8:12),'color',col_eje);
Hndl_graf(7)=mesh(x,y,z);
set(Hndl_graf(4),'visible','on','string',tit);
set(Hndl_mnus([4,5,9]),'Enable','on');
StrFcnRotar='proba(''rota_3d'')';
set(mifig,'buttondownfcn',StrFcnRotar);
set(mifig,'pointer','arrow');

%       Fin de 'dib_cpo_3d'


%---------------------------------------------------------------%
%	ROTA DIAGRAMA 3D
%---------------------------------------------------------------%
elseif strcmp(accion,'rota_3d')

vista=get(Hndl_graf(1),'view');
set(Hndl_graf(1),'drawmode','normal','view',vista+[30,0]);


%---------------------------------------------------------------%
%	OPCIONES DE ANÁLISIS Y DIBUJO
%---------------------------------------------------------------%

%       Función que pide las opciones distintas: 'get_opt'

elseif strcmp(accion,'get_plt')

proba('limpia');
set(Hndl_user(1),'visible','on','call',...
['proba(''set_plt'');','return']);

set(Hndl_user(2),'visible','on','call',...
['proba(''limpia'');','return']);

Hndl_user=[Hndl_user;zeros(11,1)];

Hndl_user(3)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'OPCIONES DE DIBUJO','foreg',col_frg,...
'units','normalized','position',[.1 .86 .6 .04]);

Hndl_user(4)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ángulo mínimo Theta (deg):  ','units',...
'normalized','position',[.2 .72 .5 .04],'horizontal','left');

Hndl_user(5)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ángulo máximo Theta (deg):  ','units',...
'normalized','position',[.2 .66 .5 .04],'horizontal','left');

Hndl_user(6)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ángulo mínimo Phi (deg): ','units',...
'normalized','position',[.2 .60 .5 .04],'horizontal','left');

Hndl_user(7)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ángulo máximo Phi (deg): ','units',...
'normalized','position',[.2 .54 .5 .04],'horizontal','left');

Hndl_user(8)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Mínimo valor de Amplitud (dB): ','units',...
'normalized','position',[.2 .48 .5 .04],'horizontal','left');

Hndl_user(9)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(4,1)),'units','normalized','position',...
[.55 .72 .05 .04],'visible','on');

Hndl_user(10)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(4,2)),'units','normalized','position',...
[.55 .66 .05 .04],'visible','on');

Hndl_user(11)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(4,3)),'units','normalized','position',...
[.55 .60 .05 .04],'visible','on');

Hndl_user(12)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(4,4)),'units','normalized','position',...
[.55 .54 .05 .04],'visible','on');

Hndl_user(13)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(4,5)),'units','normalized','position',...
[.55 .48 .05 .04],'visible','on');


%       Función que pide las opciones distintas: 'get_ana'

elseif strcmp(accion,'get_ana')

proba('limpia');
set(Hndl_user(1),'visible','on','call',...
['proba(''set_ana'');','return']);

set(Hndl_user(2),'visible','on','call',...
['proba(''limpia'');','return']);

Hndl_user=[Hndl_user;zeros(12,1)];

Hndl_user(3)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'OPCIONES DE ANÁLISIS','foreg',col_frg,...
'units','normalized','position',[.1 .83 .6 .04]);

Hndl_user(4)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'RESOLUCIÓN EN ANÁLISIS: ','foreg',col_frg,...
'units','normalized','position',[.2 .62 .5 .04],'horizontal','left');

Hndl_user(5)=uicontrol(mifig,'style','text','string',...
'Número de posiciones en Theta: ','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .57 .5 .04],'horizontal','left');

Hndl_user(6)=uicontrol(mifig,'style','text','string',...
'Número de posiciones en Phi: ','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .52 .5 .04],'horizontal','left');

Hndl_user(7)=uicontrol(mifig,'style','text','string',...
'POLARIZACIÓN: ','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .44 .5 .04],'horizontal','left');

Hndl_user(8)=uicontrol(mifig,'style','checkbox','string',...
'Circular a izquierdas','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.25 .39 .2 .04],'horizontal','left');

Hndl_user(9)=uicontrol(mifig,'style','checkbox','string',...
'Circular a derechas','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.25 .34 .2 .04],'horizontal','left');

Hndl_user(10)=uicontrol(mifig,'style','checkbox','string',...
'Lineal','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.25 .29 .2 .04],'horizontal','left');

Hndl_user(11)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(5,1)),'units','normalized','position',...
[.55 .57 .05 .04],'visible','on');

Hndl_user(12)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(5,2)),'units','normalized','position',...
[.55 .52 .05 .04],'visible','on');

Hndl_user(13)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(5,4)),'units','normalized','position',[.55 .29 .03 .04],...
'visible','on');

Hndl_user(14)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','deg','units','normalized','position',[.6 .29 .05 .04],...
'visible','on');

%---------------------------------------------------------------%
%	Fin de get_opt                          	%
%---------------------------------------------------------------%
%
%---------------------------------------------------------------%
%	LEE LAS OPCIONES DE ANÁLISIS Y PLOT
%---------------------------------------------------------------%

%	Función que lee los márgenes para los diagramas y el
%    valor mínimo para la representación gráfica: 'set_diag'

elseif strcmp(accion,'set_plt')

new_min_th=str2num(get(Hndl_user(9),'string'));
new_max_th=str2num(get(Hndl_user(10),'string'));
new_min_ph=str2num(get(Hndl_user(11),'string'));
new_max_ph=str2num(get(Hndl_user(12),'string'));
new_min_eje=str2num(get(Hndl_user(13),'string'));
proba('limpia');

if (new_min_th>new_max_th),
	message(1);
	proba('get_plt');
else
	if (new_min_th~=datos(4,1)),
		datos(4,1)=new_min_th;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	end
	if (new_max_th~=datos(4,2)),
		datos(4,2)=new_max_th;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	end
end
if (new_min_ph>new_max_ph),
	message(1);
	proba('get_plt');
else
	if (new_min_ph~=datos(4,3)),
		datos(4,3)=new_min_ph;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	end
	if (new_max_ph~=datos(4,4)),
		datos(4,4)=new_max_ph;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	end
end
if (new_min_eje>0),
	message(2);
	proba('get_plt');
else
	datos(4,5)=new_min_eje;
end
clear new_min_th new_max_th new_min_ph new_max_ph new_min_eje 
%---------------------------------------------------------------------%
%	Fin de 'Set_plt'
%---------------------------------------------------------------------%

elseif strcmp(accion,'set_ana')

new_n_th=str2num(get(Hndl_user(11),'string'));
new_n_ph=str2num(get(Hndl_user(12),'string'));
izdas=get(Hndl_user(8),'value');
dchas=get(Hndl_user(9),'value');
linear=get(Hndl_user(10),'value');
pol_lin=str2num(get(Hndl_user(13),'string'));

proba('limpia');

if (new_n_th<=0),
	message(4);
	proba('get_ana');
else
	if (new_n_th~=datos(5,1)),
		datos(5,1)=new_n_th;
		Flags(1,2)=0;		% Necesario recalcular diagramas
      Flags(1,3)=0;		% Necesario recalcular parámetros
		Flags(1,4)=0;
		for i=1:length(Frec_obj), Flags(2,i)=0; end
		set(Hndl_mnus([15:19,23:26]),'Enable','off');
	end 
end
if (new_n_ph<=0),
	message(3);
	proba('get_ana');
else
	if (new_n_ph~=datos(5,2)),
		datos(5,2)=new_n_ph;
		Flags(1,2)=0;		% Necesario recalcular diagramas
      Flags(1,3)=0;		% Necesario recalcular parámetros
		Flags(1,4)=0;
		for i=1:length(Frec_obj), Flags(2,i)=0; end
		set(Hndl_mnus([15:19,23:26]),'Enable','off');
	end 
end
if (izdas+dchas+linear~=1),
	message(4);
	proba('get_ana');
else
	if ((izdas==1)&(datos(5,3)~=1)),
		datos(5,3)=1;
		datos(5,4)=0;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
    elseif ((dchas==1)&(datos(5,3)~=2)),
		datos(5,3)=2;
		datos(5,4)=0;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	elseif ((linear==1)&((datos(5,3)~=3)|(pol_lin~=datos(5,4)))),	
		datos(5,3)=3;
		datos(5,4)=pol_lin;
		Flags(1,2)=0;
		set(Hndl_mnus([23:26]),'Enable','off');
	end
end

clear new_min_x new_max_x new_n_th new_step_x new_n_ph
clear new_min_eje linear izdas dchas pol_lin

%---------------------------------------------------------------------%
%	Fin de 'Set_ana'
%---------------------------------------------------------------------%

%---------------------------------------------------------------------%
% 	DIBUJA PARÁMETROS VS FRECUENCIA
%---------------------------------------------------------------------%

elseif strcmp(accion,'dib_res_2d')

erro=0;
if (Status==31),      % Eficiencia vs Frecuencia
	tit='Eficiencia vs Frecuencia ';
	labely='Eficiencia (%)';
	labelx='Frequencia (GHz)';
	x=Frec_obj;
	marcax=Frec_obj;
	y1=Parametros(2:length(Frec_obj)+1,4);
	limitey=5*[floor(min(y1)/5) ceil(max(y1)/5)];
   marcay=min(limitey):2.5:max(limitey);

elseif (Status==32),      % Directividad vs Frecuencia
	tit='Directividad vs Frecuencia ';
	labely='Directividad (dB)';
	labelx='Frecuencia (GHz)';
	x=Frec_obj;
	marcax=Frec_obj;
	y1=Parametros(2:length(Frec_obj)+1,2);
	limitey=10*[floor(min(y1)/10) ceil(max(y1)/10)];
    marcay=min(limitey):2.5:max(limitey);

elseif (Status==33),  % Ganancia vs frecuencia
	tit='Ganancia vs Frecuencia ';
	tit=[tit,Nome_Ant];
	labelx='Frecuencia (GHz)';
	labely='Ganancia (dBi)';
	x=Frec_obj;
	marcax=Frec_obj;
   y1=Parametros(2:length(Frec_obj)+1,3);
	limitey=[10*floor(min(y1)/10) 10*ceil(max(y1)/10)];
	marcay=min(limitey):2.5:max(limitey);

elseif (Status==41),  % Módulo del Coef. de Reflexión vs frecuencia
	tit='Reflexión (dB) vs Frecuencia ';
	tit=[tit,Nome_Ant];
	labelx='Frecuencia (GHz)';
	labely='RO (dB)';
	x=Frec_obj;
	marcax=Frec_obj;
	y1=Parametros(2:length(Frec_obj)+1,1);
	limitey=[10*floor(min(y1)/10) 10*ceil(max(y1)/10)];
	marcay=min(limitey):2.5:max(limitey);

elseif (Status==44),  % Módulo Campo en las sondas de prueba
	tit='Campo (dB) en las sondas de prueba ';
	tit=[tit,Nome_Ant];
	labelx='Sonda';
	labely='Campo (dB)';
	x=1:datos(2,4);
	marcax=0:datos(2,4)/4:datos(2,4);
	y1=20*log10(abs(E));
	limitey=[10*floor(min(y1)/10) 10*ceil(max(y1)/10)];
	marcay=min(limitey):5:max(limitey);

elseif (Status==45),  % Fase Campo en las sondas de prueba
	tit='Campo (deg) en las sondas de prueba ';
	tit=[tit,Nome_Ant];
	labelx='Sonda';
	labely='Campo (deg)';
	x=1:datos(2,4);
	marcax=0:datos(2,4)/4:datos(2,4);
	y1=180/pi*angle(E);
	limitey=[10*floor(min(y1)/10) 10*ceil(max(y1)/10)];
	marcay=min(limitey):30:max(limitey);

end

if (min(limitey)==max(limitey)),
	limitey=limitey+[-5 5];
	marcay=limitey(1):2.5:limitey(2);
end

if (Status>22),
	set(Hndl_graf(1),'visible','on','xlim',[min(x) max(x)],'ylim',limitey,...
      'pos',[.13 .11 .775 .815],'view',[0 90],'PlotBoxAspectRatio',[3 2 1],...
      'xtickmode','auto','ytickmode','auto');
	xlabel(labelx);
end

set(Hndl_graf(2),'visible','on','xdata',x,'ydata',y1);

% Poner etiquetas
if (((Status>=31) && (Status<=35)) || (Status==41) || (Status==42)), 
	Hndl_graf=[Hndl_graf;-ones(length(x),1)];
	Hndl_graf(7)=text('units','data','pos',[x(1),y1(1)],...
	'string',num2str(y1(1)),'horizontalalignment','left',...
	'vertical','bottom','color',col_eje);
	for n=2:length(x)-1,
	Hndl_graf(6+n)=text('units','data','pos',[x(n),y1(n)],...
	'string',num2str(y1(n)),'horizontal','center',...
	'vertical','bottom','color',col_eje);
	end
	Hndl_graf(6+length(x))=text('units','data','pos',...
	[max(x),y1(length(x))],'string',num2str(y1(length(x))),...
	'horizontal','right','vertical','bottom','color',col_eje);
end
set(Hndl_graf(4),'visible','on','string',tit);
set(Hndl_mnus([4,5,9]),'Enable','on');
if erro>0,  % Se ha producido algún error
	message(erro);
end
clear erro x y1 tit marcax limitey
set(mifig,'pointer','arrow');

%       Fin de 'dib_res_2d'


%---------------------------------------------------------------%
%	TOMA DE DATOS PARA EL ANALISIS DE LA ESTRUCTURA
%---------------------------------------------------------------%

elseif strcmp(accion,'analize')

%       DECLARACIÓN DE LOS CONTROLES DEL CUADRO DE DIÁLOGO
%       DE LOS "ANÁLISIS DE LA ANTENA".

proba('limpia');
set(Hndl_user(1),'visible','on','call',...
['proba(''lee_data'');','return']);

set(Hndl_user(2),'visible','on','call',...
['proba(''limpia'');','return']);

Hndl_user=[Hndl_user;zeros(14,1)];

Hndl_user(3)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'ANALISIS DE LA ANTENA','foreg',col_frg,...
'units','normalized','position',[.1 .90 .6 .04]);

Hndl_user(4)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Frecuencia Central (GHz):  ','units',...
'normalized','position',[.15 .82 .5 .03],'horizontal','left');

Hndl_user(5)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Ancho de Banda (GHz): ','units',...
'normalized','position',[.15 .78 .5 .03],'horizontal','left');

Hndl_user(6)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','Número de Frecuencias: ','units',...
'normalized','position',[.15 .74 .5 .03],'horizontal','left');

Hndl_user(7)=uicontrol(mifig,'style','text','backg',col_bkg,'foreg',col_frg,...
'string','CALCULAR:  ','units',...
'normalized','position',[.1 .66 .6 .04]);

Hndl_user(8)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'A la Frecuencia Central: ','foreg',col_frg,...
'units','normalized','position',[.15 .60 .6 .04],'horizontal','left');

Hndl_user(9)=uicontrol(mifig,'style','checkbox','string',...
'Campos en Ranuras y puntos de prueba','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .56 .4 .03],'horizontal','left');

Hndl_user(10)=uicontrol(mifig,'style','checkbox','string',...
'Diagrama de Radiación','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .52 .4 .03],'horizontal','left');

Hndl_user(11)=uicontrol(mifig,'style','checkbox','string',...
'Parámetros de la antena','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .48 .4 .03],'horizontal','left');

Hndl_user(12)=uicontrol(mifig,'style','text','backg',col_bkg,'string',...
'Parámetros vs Frecuencia: ','foreg',col_frg,...
'units','normalized','position',[.15 .42 .6 .04],'horizontal','left');

Hndl_user(13)=uicontrol(mifig,'style','checkbox','string',...
'Directividad, Eficiencia, Ganancia ... ','backg',col_bkg,'foreg',col_frg,'units',...
'normal','position',[.2 .38 .4 .03],'horizontal','left');

Hndl_user(14)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(1,4)),'units','normalized','position',...
[.55 .82 .05 .03],'visible','on');

Hndl_user(15)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(3,2)),'units','normalized','position',...
[.55 .78 .05 .03],'visible','on');

Hndl_user(16)=uicontrol(mifig,'style','edit','backg',col_bkg,'foreg',col_frg,...
'string',num2str(datos(3,3)),'units','normalized','position',...
[.55 .74 .05 .03],'visible','on');


%---------------------------------------------------------------%
%	Fin de 'analize'.  (cuadro de diálogo para el análisis)
%---------------------------------------------------------------%

elseif strcmp(accion,'lee_data')

fc=str2num(get(Hndl_user(14),'string'));
bw=str2num(get(Hndl_user(15),'string'));
nf=str2num(get(Hndl_user(16),'string'));

if (fc~=datos(1,4)),
	Flags(1,1)=0;
	Flags(1,2)=0;
	Flags(1,3)=0;
end
Flags(1,4)=0;
Frec_obj=Frec_obj(1);
Parametros=Parametros(1,:);
igual=0;
for i=1:nf,
	Frec_obj(i)=fc+bw/(nf-1)*(i-1)-bw/2;
	if (Frec_obj(i)==fc),
		igual=1;
	end
end
ya=0;
if (igual==0),
	for i=1:nf,
		if (Frec_obj(i)>fc),
			if (ya==0),
				num=i;
			end
			ya=1;
            Frec_obj(i+1)=fc+bw/(nf-1)*(i-1)-bw/2;
		end
	end
	Frec_obj(num)=fc;
end
for i=1:length(Frec_obj),
	Flags(2,i)=0;
end

datos(1,4)=fc;
datos(3,3)=nf;
datos(3,2)=bw;
clear bw nf	fc igual ya

% Comprueba si la separación entre placas es menor que media
% longitud de onda de la guía a la frecuencia mayor.
lambdag=299.792/(max(Frec_obj)*sqrt(datos(1,3)));
if (lambdag<=2*datos(1,1)),	
		message(7); 
		proba('analize');
end
clear lambdag
Analisis(1)=get(Hndl_user(9),'value');
Analisis(2)=get(Hndl_user(10),'value');
Analisis(3)=get(Hndl_user(11),'value');
Analisis(4)=get(Hndl_user(13),'value');
if (sum(sum(Analisis))~=0), Analisis(1)=1; end
if (Analisis(4)==1), Analisis(3)=1; end
proba('limpia');
proba('proc_anal');

% Fin de lee_data

%===============================================================%
%       FUNCIONES DE ANALISIS
%===============================================================%

% Función base para realizar el análisis de la estructura

elseif strcmp(accion,'proc_anal'),
    
 % Añadido agosto 2012: introducimos cortos virtuales para poder
    % calcular la superficie de la antena.
    if (datos(2,3)==0),
        % En el caso en el que no haya cortos los ponemos para calcular el
        % área. Solo se hace en el caso en el que haya al menos 10 ranuras.
        if (datos(2,2)>9),
            ro=sqrt(ranuras(:,1).^2+ranuras(:,2).^2);
            fi=unwrap(atan2(ranuras(:,2),ranuras(:,1)));
            nran=datos(2,2);
            polariza=(-1)^(datos(5,3));
            fi=-fi*polariza;
            frec=datos(1,4);
            eps=datos(1,3);
            lambg=299.792/frec/sqrt(eps);
            fimod=abs(fi);		% Eliminamos errores en primer elemento
            cor=find(abs(fimod)+1.98*pi>abs(fimod(nran)));
            ncorto=length(cor);
            for indj=1:ncorto,
                ficorto1(indj)=fi(nran-ncorto+indj);
                rocorto1(indj)=ro(nran-ncorto+indj)+lambg/4;
            end
            for ind=1:2:ncorto-1,
                rocorto1(ind)=max(rocorto1(ind),rocorto1(ind+1));
                rocorto1(ind+1)=max(rocorto1(ind),rocorto1(ind+1));
            end
            % Corto de la cuña (1 para simular una ranura más)
            ficorto1(ncorto+1)=2*ficorto1(ncorto)-ficorto1(ncorto-1);
            rocorto1(ncorto+1)=rocorto1(ncorto);
            rocorto=rocorto1;
            ficorto=ficorto1;
            % Situamos el doble de cortos que ranuras, para rellenar 2 por cada ranura
            for indj=1:2:ncorto-3,
                ficorto(2*indj-1)=ficorto1(indj);
                rocorto(2*indj-1)=rocorto1(indj);
                ficorto(2*indj)=ficorto1(indj+1);
                ficorto(2*indj+1)=(2*ficorto1(indj+1)+ficorto1(indj+2))/3;
                rocorto(2*indj)=rocorto1(indj+1);
                rocorto(2*indj+1)=(2*rocorto1(indj+1)+rocorto1(indj+2))/3;
                ficorto(2*indj+2)=(ficorto1(indj+1)+2*ficorto1(indj+2))/3;
                rocorto(2*indj+2)=(rocorto1(indj+1)+2*rocorto1(indj+2))/3;
            end
            ncorto=length(rocorto);
            ncorto1=length(rocorto1);
            % Añado los cortos de las últimas ranuras y cuña
            ficorto(ncorto+1)=ficorto1(ncorto1-2);
            rocorto(ncorto+1)=rocorto1(ncorto1-2);
            ficorto(ncorto+2)=ficorto1(ncorto1-1);
            rocorto(ncorto+2)=rocorto1(ncorto1-1);
            ficorto(ncorto+3)=ficorto1(ncorto1);
            rocorto(ncorto+3)=rocorto1(ncorto1);
            ncorto=length(rocorto);
            % Sonda de la cuña (3 para la cuña)
            ficorto=unwrap(ficorto);
            ficorto(ncorto+1)=(ficorto(1)-2*pi+3*ficorto(ncorto))/4;
            rocorto(ncorto+1)=(rocorto(1)+3*rocorto(ncorto))/4;
            ficorto(ncorto+2)=(2*ficorto(1)-4*pi+2*ficorto(ncorto))/4;
            rocorto(ncorto+2)=(rocorto(1)+rocorto(ncorto))/2;
            ficorto(ncorto+3)=(3*ficorto(1)-6*pi+ficorto(ncorto))/4;
            rocorto(ncorto+3)=(3*rocorto(1)+rocorto(ncorto))/4;
            % Fin del ajuste para la polarización.
            ficorto=-ficorto*polariza;
            cortos=[rocorto.*cos(ficorto);rocorto.*sin(ficorto);0.1*ones(1,length(rocorto))].';
        end
    end
    
    npun=datos(2,4);
    if (npun==0),
        % Si no tenemos puntos nos creamos unos para poder calcularnos
        % potencia residual. Ojo, si no asumimos que los puntos son
        % externos.
        %	Datos de los puntos de cálculo del campo E:
        %
        npun=720;
        frec=datos(1,4);
        eps=datos(1,3);
        lambg=299.792/frec/sqrt(eps);
        if (datos(2,2)~=0),
            rofinal=max(sqrt(cortos(:,1).^2+cortos(:,2).^2))+10*lambg*ones(npun,1);
        else
            rofinal=max(sqrt(sondas(:,1).^2+sondas(:,2).^2))+10*lambg*ones(npun,1);
        end
        fifinal=[0:2*pi/npun:2*pi-2*pi/npun].';
        puntos=[rofinal.*sin(fifinal) rofinal.*cos(fifinal)];
        punt=1;
        datos(2,4)=npun;
    end
    
if ((Analisis(1)==1)&&(Flags(1,1)==0)),
	datos(3,4)=datos(1,4);   %Frecuencia
	[Vs,Is,Ic,Vr,Ir,E,Hx,Hy]=analiza(datos,ranuras,cortos,sondas,puntos);
	if (datos(2,2)~=0), set(Hndl_mnus([12:14]),'enable','on'); end
	if (datos(2,4)~=0), set(Hndl_mnus(29),'enable','on'); end
	set(Hndl_mnus(3),'enable','on');
	Flags(1,1)=1;
else
	if (Flags(1,1)==1), Analisis(1)=1; end
end

if ((Analisis(2)==1)&&(Flags(1,2)==0)&&(datos(2,2)~=0)),
	[Campo_cop,Campo_cros]=calc_cpo(datos,ranuras,Vr);
	set(Hndl_mnus([23:26]),'enable','on');
	Flags(1,2)=1;
else
	if (Flags(1,2)==1), Analisis(2)=1; end
end

if ((Analisis(3)==1)&&(Flags(1,3)==0)),
   [Parametros]=calc_param(datos,sondas,ranuras,cortos,puntos,Vr,Ir,Vs,Is,E,Hx,Hy);
   set(Hndl_mnus(15),'enable','on');	
   Flags(1,3)=1;
else
	if (Flags(1,3)==1), Analisis(3)=1; end
end

if (Analisis(4)==1 && Flags(1,4)==0),
   freq=datos(1,4);   % Variable auxiliar para no perder la frecuencia central
   for i=1:length(Frec_obj),
	  datos(1,4)=Frec_obj(i);
	  if (Flags(2,i)==0),
	 	[Vsf,Isf,Icf,Vrf,Irf,Ef,Hxf,Hyf]=analiza(datos,ranuras,cortos,sondas,puntos);
        [Parametros(i+1,:)]=calc_param(datos,sondas,ranuras,cortos,puntos,Vrf,Irf,Vsf,Isf,Ef,Hxf,Hyf); 
        set(Hndl_mnus([16:22]),'enable','on');	
		Flags(2,i)=1;
		Flags(1,4)=1;
     end
   end
   datos(1,4)=freq;
   clear freq
else
	if (Flags(1,4)==1), Analisis(4)=1; end
end
	


%===============================================================%
%	FUNCIONES DEL MENÚ "PLOT"
%===============================================================%

%	DIBUJO DE LA ANTENA Y CAMPO EN LAS RANURAS
%---------------------------------------------------------------%

%	Función que dibuja la antena: 'dib_ant'

elseif strcmp(accion,'dib_ant') 

proba('limpia');
elem=0;

if (datos(2,2)~=0),
	drx=max(abs(ranuras(:,3).*cos(ranuras(:,5))/2));
	dry=max(abs(ranuras(:,3).*sin(ranuras(:,5))/2));
else
	drx=0.5;
	dry=0.5;
end

todos=[];
if datos(2,1)~=0, todos=[todos;(sondas(:,1:2))]; end
if datos(2,2)~=0, todos=[todos;(ranuras(:,1:2))]; end
if datos(2,3)~=0, todos=[todos;(cortos(:,1:2))]; end
if datos(2,4)~=0, todos=[todos;(puntos(:,1:2))]; end

maxi_x=max(1,ceil(max(todos(:,1))+drx));
mini_x=min(-1,floor(min(todos(:,1))-drx));
maxi_y=max(ceil(max(todos(:,2))+dry));
mini_y=min(floor(min(todos(:,2))-dry));
clear todos drx dry

delta_x=maxi_x-mini_x;
delta_y=maxi_y-mini_y;
if (delta_x>delta_y),
	maxi=maxi_x;
	mini=mini_x;
else
	maxi=maxi_y;
	mini=mini_y;
end
%delta=(maxi-mini)/5;

set(Hndl_graf(1),'visible','on','PlotBoxAspectRatio',[1 1 1],'xlim',[mini_x*1.1 maxi_x*1.1],...
'ylim',[mini_y*1.1 maxi_y*1.1],'view',[0 90],'xtickmode','auto','ytickmode','auto');


% Sondas de alimentación

if (datos(2,1)~=0),
Hndl_graf=[Hndl_graf;-ones(datos(2,1),1)];
for i=1:datos(2,1),
	Hndl_graf(6+i)=plot(sondas(i,1),sondas(i,2),'ro');
end
elem=datos(2,1);
end

% Cortos

if (datos(2,3)~=0),
Hndl_graf=[Hndl_graf;-ones(datos(2,3),1)];
for i=1:datos(2,3),
	Hndl_graf(6+elem+i)=plot(cortos(i,1),cortos(i,2),'bo');
end
elem=elem+datos(2,3);
end

% Sondas de medida

if (datos(2,4)~=0),
Hndl_graf=[Hndl_graf;-ones(datos(2,4),1)];
for i=1:datos(2,4),
	Hndl_graf(6+elem+i)=plot(puntos(i,1),puntos(i,2),'r+');
end
elem=elem+datos(2,4);
end

% Ranuras de radiación

if (datos(2,2)~=0),
nran=datos(2,2);
if Status==22,
	col= ones(nran,1)*col_one;
elseif  Status==50,
	Pranura=20*log10(abs(Vr(:))) ;
	Pmed=sum(Pranura)/nran;
	Pdes=sqrt(sum((Pranura-Pmed).^2)/nran);
	Pdecada=floor(ceil(3*log10(Pdes/2))/3) ;
	Ptercio=round(10^(rem(ceil(3*log10(Pdes/2))+30,3) /3)) ;
	Pdelta=Ptercio*10^Pdecada;
	Pranura=round((Pranura-Pmed)/Pdelta)+5;
	Pmin=(round(Pmed/Pdelta)-5)*Pdelta ;
	for ind=1:nran,
		if Pranura(ind)<1, 
			Pranura(ind)=1 ; 
		elseif Pranura(ind)>10, 
			Pranura(ind)=10 ;
		end
		col(ind,:)=Escala3(Pranura(ind),:);
	end	
	clear Pranura Pdecada Ptercio Pmed Pdes

elseif  Status==51
	% Corregido para Polarización circular a izdas y dchas.
    % Comprobado
    if datos(5,3)==3, % lineal
        Pranura=angle(Vr(:));
    elseif datos(5,3)==1, % circ. izdas.
        Pranura= angle(Vr(:))-ranuras(:,5);
    elseif datos (5,3)==2, % circ. dchas.
        Pranura= angle(Vr(:))+ranuras(:,5);
    end
	Pranura=Pranura-Pranura(1);
	Pranura=180*rem(5*pi+rem(Pranura,2*pi),2*pi)/pi-180;
	Pmed=sum(Pranura)/nran;
	Pdes=sqrt(sum((Pranura-Pmed).^2)/nran); 
	Pdecada=floor(ceil(3*log10(Pdes/2))/3) ;
	Ptercio=round(10^(rem(ceil(3*log10(Pdes/2))+30,3) /3)) ;
	Pdelta=Ptercio*10^Pdecada;
	if Pdelta>40, Pdelta=40; end;
	Pmin=(round(Pmed/Pdelta)-5)*Pdelta ;
	if Pmin<-180, Pmin=-180; end;
	Pranura=round((Pranura-Pmin)/Pdelta);
	for ind=1:nran
		if Pranura(ind)<1, Pranura(ind)=1 ;
		elseif Pranura(ind)>10, Pranura(ind)=10 ;
		end
	col(ind,:)=Escala3(Pranura(ind),:) ;
	end
	clear Pranura

end	% de if

%	Coordenadas cartesianas de los centros de las ranuras:
rran=[ranuras(:,1),ranuras(:,2),zeros(nran,1)];
%	Vectores unitarios paralelos a las ranuras:
unpar=[cos(ranuras(:,5)),sin(ranuras(:,5)),zeros(nran,1)];
%	Vectores unitarios normales a las ranuras:
unnor=[-sin(ranuras(:,5)),cos(ranuras(:,5)),zeros(nran,1)];
%	Variables auxiliares:
slot1=rran-(.5*(ranuras(:,4)*ones(1,3)).*unpar.*(ranuras(:,3)*ones(1,3)))-unnor;
slot2=rran-(.5*(ranuras(:,4)*ones(1,3)).*unpar.*(ranuras(:,3)*ones(1,3)))+unnor;
slot3=rran+(.5*(ranuras(:,4)*ones(1,3)).*unpar.*(ranuras(:,3)*ones(1,3)))+unnor;
slot4=rran+(.5*(ranuras(:,4)*ones(1,3)).*unpar.*(ranuras(:,3)*ones(1,3)))-unnor;

x=ranuras(:,1);
y=ranuras(:,2);
l=ranuras(:,3);
for nr=1:nran,
w(nr)=max(ranuras(nr,4));
end
w=w.';
alfa=ranuras(:,5);
x4=x+l/2.*cos(alfa)-w/2.*sin(alfa);
y4=y+l/2.*sin(alfa)+w/2.*cos(alfa);
x1=x-l/2.*cos(alfa)-w/2.*sin(alfa);
y1=y-l/2.*sin(alfa)+w/2.*cos(alfa);
x2=x-l/2.*cos(alfa)+w/2.*sin(alfa);
y2=y-l/2.*sin(alfa)-w/2.*cos(alfa);
x3=x+l/2.*cos(alfa)+w/2.*sin(alfa);
y3=y+l/2.*sin(alfa)-w/2.*cos(alfa);
slot1=[x1,y1,zeros(nran,1)];
slot2=[x2,y2,zeros(nran,1)];
slot3=[x3,y3,zeros(nran,1)];
slot4=[x4,y4,zeros(nran,1)];
clear x y l w alfa x4 y4 x3 y3 x2 y2 x1 y1

Hndl_graf=[Hndl_graf;-ones(nran,1)];
for n=1:nran,
	Hndl_graf(6+elem+n)=fill([slot1(n,1),slot2(n,1),slot3(n,1),slot4(n,1)],...
	[slot1(n,2),slot2(n,2),slot3(n,2),slot4(n,2)],col(n,:));
end
elem=elem+nran;
clear slot1 slot2 slot3 slot4
end

% Pinta los ejes de amplitud y fase
maxi=max(maxi_x,maxi_y);
if ((Status==50)|(Status==51)),
	Hndl_graf=[Hndl_graf;-ones(20,1)];
	for n=1:10
		Hndl_graf(6+elem+n)=fill([maxi,maxi,maxi+.1*maxi_y,maxi+.1*maxi_y],...
		[maxi_y*(n-1)/10,maxi_y*n/10,maxi_y*n/10,maxi_y*(n-1)/10],Escala3(n,:)) ;
		Hndl_graf(16+elem+n)=text(maxi+.15*maxi_y, maxi_y*(n-.5)/10,...
		num2str(Pmin+(n-1)*Pdelta),'color',col_frg) ;
	end

end

xlabel('X (mm)');
ylabel('Y (mm)');
tit=['Antena  ',Nome_Ant,'.'];
set(Hndl_graf(4),'visible','on','string',tit);
set(mifig,'pointer','arrow');
set(Hndl_mnus([4:10]),'Enable','on');

clear tit nran elem rral rran unpar unnor 
clear maxi_x maxi_y mini_x mini_y maxi delta_x delta_y 
clear slot1 slot2 slot3 slot4 Pmin Pdelta Fmin Fdelta

%	Fin de 'dib_ant'.

% ==============================================================%
%       Bloque de salida del programa.
% ==============================================================%

%---------------------------------------------------------------%
%    	Función 'acaba': salva las variables de entorno y
%   	borra las variables locales.

elseif strcmp(accion,'acaba')

save entorno.mat datos col_wnd col_bkg col_frg col_eje col_one col_two


clear col_wnd col_bkg col_frg col_eje col_one col_two
Status=0;

clear all

%       Fin de 'acaba'

%       Fin del bloque de salida del programa.
%---------------------------------------------------------------%
else
	return
end
return
%===============================================================%
%       Fin del programa.
%===============================================================%
