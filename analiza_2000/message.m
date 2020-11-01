function message(n,valor)

if nargin<1,
	n=0;
end
pos_dlg=[.2 .3 .6 .5];
if n==0,
	msg1='   Departamento de Tecnologías de las Comunicaciones   ';
	msg2='                 Universidad de Vigo                   ';
	msg3='Departamento de Señales, Sistemas y Radiocomunicaciones';
	msg4='          Universidad Politécnica de Madrid            ';
	msg5='                    Diciembre 2000                     ';
	msg6='         							    ';
	msg=str2mat(msg6,msg5,msg4,msg3,msg2,msg1);
elseif (n==1), 
	msg1='EL ÁNGULO MÍNIMO DEBE SER MENOR DEL';
	msg2='  		   ÁNGULO MÁXIMO             ';
	msg=str2mat(msg2,msg1);
elseif (n==2), 
	msg1='EL VALOR MÍNIMO DE CAMPO EN EL DIAGRAMA';
	msg2='  DE RADIACIÓN DEBE SER MENOR DE 0 dB  ';
	msg=str2mat(msg2,msg1);
elseif (n==3), 
	msg1='EL NÚMERO DE VALORES ANGULARES';
	msg2='     DEBE SER MAYOR DE 0      ';
	msg=str2mat(msg2,msg1);
elseif (n==4),
	msg1='POR FAVOR, MARQUE ÚNICAMENTE ';
	msg2='     	1 POLARIZACIÓN         ';
	msg=str2mat(msg2,msg1);
elseif (n==5), 
	msg1='GENERAR INFORME EN FICHERO:';
	msg2='LA EXTENSION DEL FICHERO ES';
	msg3='  ERRONEA:  DEBE SER .TXT  ';
	msg=str2mat(msg3,msg2,msg1);
elseif (n==6), 
	msg1='GUARDAR TABLA EN FICHERO:  ';
	msg2='LA EXTENSION DEL FICHERO ES';
	msg3='  ERRONEA:  DEBE SER .ASC';
	msg=str2mat(msg3,msg2,msg1);
elseif (n==7), 
	msg1=' LA ALTURA DE LA GÚIA ES MAYOR QUE ';
	msg2='  UNA LONGITUD DE ONDA. POR FAVOR, ';
	msg3='MODIFIQUE LA ALTURA O LA FRECUENCIA';
	msg=str2mat(msg3,msg2,msg1);
elseif (n==8), 
	msg1='ALGUNAS FRECUENCIAS DE ANALISIS SON DEMASIADO ';
	msg2='ELEVADAS: NO SE GARANTIZA LA FIABILIDAD DE LOS';
	msg3=['   RESULTADOS PARA f>=',num2str(valor),' GHz.'];
	msg=str2mat(msg3,msg2,msg1);
elseif (n==9), 
	msg1='LOS RESULTADOS OBTENIDOS A PARTIR DE AHORA';
	msg2=' SERAN FIABLES PORQUE SE HAN ELIMINADO LAS';
	msg3='        FRECUENCIAS MAS ELEVADAS.         ';
        msg=str2mat(msg3,msg2,msg1);
elseif (n==10), 
	msg1='LOS RESULTADOS OBTENIDOS A PARTIR DE AHORA';
	msg2='  SERÁN FIABLES PORQUE SE HA REDUCIDO LA  ';
	msg3='      CONSTANTE DIELÉCTRICA RELATIVA      ';
        msg=str2mat(msg3,msg2,msg1);
elseif (n==11), 
	msg1=' CONSTANTE DIELÉCTRICA MUY GRANDE: ';
	msg2='LOS RESULTADOS NO SON FIABLES PARA';
	msg3=['   FRECUENCIAS f>= ',num2str(valor),' GHz.'];
        msg=str2mat(msg3,msg2,msg1);
elseif (n==12), 
	msg1=' EL RADIO DE LA SONDA DEBE ESTAR ENTRE';
	msg2='     LOS VALORES DE 0.01 mm y 1 mm    ';
	msg=str2mat(msg2,msg1);
elseif (n==13), 
	msg1=' LA PERMITIVIDAD DIELECTRICA DE LA GUIA DEBE'; 
	msg2='     ESTAR ENTRE LOS VALORES de 1 y 2.2     ';
	msg=str2mat(msg2,msg1);
elseif (n==14), 
	msg1=' LA ANCHURA DE LA GUIA DEBE ESTAR ENTRE ';
	msg2='       LOS VALORES DE 0.5 y 1.5 mm';
	msg=str2mat(msg2,msg1);
elseif (n==15), 
	msg1=' LA DISTANCIA MEDIA ENTRE PARES DE RANURAS';
	msg2=' DEBE SER MAYOR QUE 0.4 longitudes de onda'
	msg=str2mat(msg2,msg1);
elseif (n==16), 
	msg1='LA SEPARACIÓN ENTRE PLACAS DEBE ESTAR';
	msg2='    ENTRE LOS VALORES DE 7 y 8 mm';
	msg=str2mat(msg2,msg1);
elseif (n==17), 
	msg1=' EL ESPESOR DE LA PLACA SUPERIOR DEBE ESTAR';
	msg2='     ENTRE LOS VALORES DE 0.01 y 1,5 mm';
	msg=str2mat(msg2,msg1);
elseif (n==18), 
	msg1= ' LA DISTANCIA RADIAL DE LA 1ª RANURA DEBE';
	msg2='		     SER POSITIVA               ';
	msg=str2mat(msg2,msg1);
end
midlg=figure('units','normalized','name',...
'APLANAR v.2000','position',pos_dlg,'numbertitle',...
'off','menubar','none',...
'nextplot','new','backingstore','off',...
'resize','on','color','white');
[m,x]=size(msg);
if m==1,
	y=.48;
elseif (m==2);
	y=[.4 .6];
elseif (m==3),
	y=[.3 .5 .7];
elseif (m==6),
	y=[.3 .4 .5 .6 .7 .8];
end
for i=1:m,
h(i)=uicontrol(midlg,'style','text','units',...
'normal','position',[.03 y(i) .94 .08],...
'string',msg(i,:),'backg','white','foreg','black',...
'horizontalalignment','center');
end
uicontrol(midlg,'style','push','units','normalized','position',...
[.4 .02 .2 .1],'string','Aceptar',...
'horizontalalignment','center','call','close,');
return
