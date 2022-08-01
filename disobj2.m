function f=disobj2(obj,lado)%funcion para calcular las distancias de los objetos binarios
c=0;
    if lado==1
       obj = flip(obj,2);
    end 
       sizemask=size(obj);
           for q=1:sizemask(1)
              for m=1:sizemask(2)
                if obj(q,m)==1
                  c=c+1;
                  g(c)=sqrt(q^2+m^2);
                end
                end 
              end
          
f=mean(g);
end
  