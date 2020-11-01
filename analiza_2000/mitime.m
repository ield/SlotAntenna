%			mitime.m
%	Función que devuelve la fecha y la hora en
%   el formato: dia'/'mes'/'año'  'h':m:s
function [mifecha]=mitime

data=fix(clock);
dia=num2str(data(3));
mes=data(2);
ano=num2str(data(1));
h=num2str(data(4));
m=num2str(data(5));
s=num2str(data(6));
if (mes==1),
	mes='I';
elseif (mes==2)
	mes='II';
elseif (mes==3)
	mes='III';
elseif (mes==4)
	mes='IV';
elseif (mes==5)
	mes='V';
elseif (mes==6)
	mes='VI';
elseif (mes==7)
	mes='VII';
elseif (mes==8)
	mes='VIII';
elseif (mes==9)
	mes='IX';
elseif (mes==10)
	mes='X';
elseif (mes==11)
	mes='XI';
elseif (mes==12)
	mes='XII';
end
mifecha=[dia,'/',mes,'/',ano,'  ',h,':',m,':',s];
