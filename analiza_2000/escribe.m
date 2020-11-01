%%%%%%%%%%===============14-01-2001========%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%ESCRIBE.M%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FUNCIÓN QUE introduce en un fichero los datos de la antena para poder ser 
% leídos por el programa de análisis.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [out]=escribe(ranuras,sondas,Data_dis)

	fid=fopen('array.txt','w');

   fprintf(fid,'h=, %8.3f \n',Data_dis(2,1));
   fprintf(fid,'t=, %8.3f \n',Data_dis(2,2));
   fprintf(fid,'eps=, %8.3f \n',Data_dis(2,3));
   fprintf(fid,'ns=, %2i \n',4);
   fprintf(fid,'x/y/l/d/V/f/Z \n');
   for i=1:4,
      fprintf(fid,'%8.3f %8.3f %8.3f %8.3f %8.3f %8.3f %8.3f \n',sondas(i,:)');
   end
   fprintf(fid,'nran=, %2i \n',length(ranuras));
   fprintf(fid,'x/y/l/w/ang \n');
   ranuras(:,5)=ranuras(:,5)*180./pi;
	for i=1:length(ranuras),
      fprintf(fid,'%8.3f %8.3f %8.3f %8.3f %8.3f \n',ranuras(i,:)');
   end
   ranuras(:,5)=ranuras(:,5)*pi/180.;
	fprintf(fid,'ncor=, %2i \n',0);
   fprintf(fid,'x/y/d \n');
   fprintf(fid,'npun=, %2i \n',0);
   fprintf(fid,'x/y \n');

   fclose(fid);
   
   return
