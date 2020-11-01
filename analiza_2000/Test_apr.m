function out=test_apr(pth,nom)

out=0;
if nom==0,
	return
end
ip=find(nom=='.');   
if isempty(ip),       
	return
end
if (ip>(length(nom)-3)),   
	return
else,
	ext=lower(nom(ip+1:length(nom))); 
end
if strcmp(ext,'apr'),      
	pth_nom=lower([pth,nom]); 
	eval(['load ' pth_nom ' -mat']);
	if (exist('Data_dis')==1),
		out=1;
		if (exist('Tensiones')==1),
			out=2;
		end
	end
else  
	return
end
return