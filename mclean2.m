function mask = mclean2(mask,res,area,lado,object)%post procesado

% %imshow(mask)

f=0;


%eliminacion por distancia
mask = bwareaopen(mask, area);
%operaciones morfologicas
SE2 = strel('diamond',8);
BW3 = imdilate(mask,SE2);
SE1 = strel('disk',2);
BW4 = imerode(BW3,SE1);
mask=BW4;
%eliminacion por distancia
labels = bwlabel(mask);
nlabels = max(labels(:));
for n = 1:max(nlabels)
    obj = labels==n;
    f(n)=disobj2(obj,lado);%funcion para calcular las distancias
end
 c=min(f);
 maskout = false(size(mask));

object=object/res;
for n = 1:max(nlabels)
   obj = labels==n;
   if f(n)~=c
       l=f(n)-c;
    if l<=object
        maskout=maskout|obj;
    end
   else
        maskout=maskout|obj;
   end 
end
mask=maskout;
end