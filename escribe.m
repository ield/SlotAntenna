%%%%%%%%%%===============14-01-2001========%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%ESCRIBE.M%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FUNCI?N QUE introduce en un fichero los datos de la antena para poder ser 
% le?dos por el programa de an?lisis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out]=escribe(ranuras,sondas,puntos,Data_dis)
    texto = strcat('antenna','.asc');
	fid=fopen(texto,'w');

   fprintf(fid,'h= %8.3f \n',Data_dis(1));
   fprintf(fid,'t= %8.3f \n',Data_dis(2));
   fprintf(fid,'eps= %8.3f \n',Data_dis(3));
   fprintf(fid,'ns= %2i \n',length(sondas(:,1)));
   fprintf(fid,'x/y/l/d/V/f/Z \n');
   for i=1:length(sondas(:,length(sondas(:,1)))),
      fprintf(fid,'%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f \n',sondas(i,:)');
   end
   fprintf(fid,'nran= %2i \n',length(ranuras(:,1)));
   fprintf(fid,'x/y/l/w/ang \n');
   ranuras(:,5) = ranuras(:,5)*180/pi;
   for i=1:length(ranuras)
      fprintf(fid,'%8.3f %8.3f %8.3f %8.3f %8.3f \n',ranuras(i,:)');
   end
   fprintf(fid,'ncor= %2i \n',0);
   fprintf(fid,'x/y/d \n');
   fprintf(fid,'npun= %2i \n',length(puntos(:,1)));
   fprintf(fid,'x/y \n');
   for i=1:length(puntos(:,1)),
      fprintf(fid,'%8.3f %8.3f\n',puntos(i,:)');
   end

   fclose(fid);
   out=1;
   return
