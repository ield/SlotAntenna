function [] = writeDXF(datos, cortos, ranuras)
		Nome_fich=strcat('antenna','.dxf');
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
        if datos(2,3)~=0
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
        for ncor=1:datos(2,3)
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
		for i=1:datos(2,2)
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
	fclose(fid);

end

