%DESIGN OF PECTORAL MUSCLE SEGMENTATION ALGORITHM IN MAMMOGRAPHY BASED ON MORPHOLOGICAL OPERATIONS
resi=[0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1];%vector de la resolucion de los pixeles en mm
inten=[0.08 0.081 0.082 0.083 0.084 0.085 0.086 0.087 0.088 0.089 0.09];%vector de niveles de gris para umbralizar el mapa de atlas
area =[1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000];%vector de areas para la eliminacion por area en mm^2
CLEANOBJECT=[40 42 44 46 48 50 52 54  56  58 60];%vector de distancias para la eliminacion por distancia en mm
rng('default')
st = clock;
res     = resi(2);  %pixel resolution in mm
srcdir = 'D:\semillero\inbreast\inbreast\INbreast\AllDICOMs';
var=input('escojer base de datos digitar 1,2,3 : 1.INbreast-training 2.INbreast-test 3.INbreast-full ');
load('INdataset.mat')
if var==1
     no_images =121;
elseif var==2
     no_images =80;
     load('datos80.mat')
else
    no_images =201;
end
%ajuste base de datos
if var==1
k=1;
while k<=121
 n=1;
 while n<=410 & k<=121
    if INdataset60.id(k)==dataset.id(n)
    INdataset60.path{k}=dataset.path{n};
    INdataset60.cwall{k}=dataset.cwall{n};
    INdataset60.roi{k}=dataset.roi{n};
    k=k+1;
    end
    n=n+1;
 end
end
else
k=1;
while k<=201
 n=1;
 while n<=410 & k<=201
 
 if INdataset.id(k)==dataset.id(n)
    INdataset.path{k}=dataset.path{n};
    INdataset.cwall{k}=dataset.cwall{n};
    INdataset.roi{k}=dataset.roi{n};
    k=k+1;
    end
    n=n+1;
 end
end
end
%inicializacion de las medidas de rendimiento
DC = zeros(no_images, 1);
AE=zeros(no_images, 1);
Distance=zeros(no_images, 1);
if var==1
for f = 1:no_images
%  imagenes con segmentacion fallida base de datos de entrenamiento
    if f~=101 |  f~=66 
    %cargado del mapa de atlas
    load('ATLASS.mat')
    impath = INdataset60.path{f};%base de datos de entranamiento
    %read image
    info = getinfo(impath);
    info.psize = 0.1;
    im = ffdmRead(impath, info);
    imsize = size(im);
    im = imresize(im, info.psize/res);
    %breast detection
    mask = segBreast(im, false);
    [roi, cont] = segBreast(im, true);
    mask(cont.ycut:end,:) = false;    
    % MAG segmentatation
    mask = mag(im, mask);  
    lado=isright(im);
%     filtrado por atlas
    I=imresize(I,size(mask));
    if lado==1
        I=flip(I,2);
    end
    I(I<inten(4)) = 0;
    I(I>inten(4)) = 1;
    mask=I&mask;
%     
%   post procesado:eliminado de area, operaciones morfologicas y eliminado por distancia
    mask = mclean2(mask,res,area(8),lado,CLEANOBJECT(6));
    %base de datos de entranamiento
    cwall = readcwall(INdataset60.cwall{f}, size(im));
    cwallref=cwall;

    
   %estimacion del contorno 
    if isright(im)
        cwall.x = [imsize(2); cwall.x; imsize(2)];
        cwall.y = [1; cwall.y; 1];                
        mask = fliplr(mask);
        %modelaje del musculo pectoral
        cw = mask2cwall(mask);
        mask = poly2mask([1; cw(:,1)], [1; cw(:,2)], size(mask, 1), size(mask, 2));    
        mask = fliplr(mask);
         
    else
        cwall.x = [1; cwall.x; 1];
        cwall.y = [1; cwall.y; 1];  
         %modelaje del musculo pectoral
        cw = mask2cwall(mask);
        mask = poly2mask([1; cw(:,1)], [1; cw(:,2)], size(mask, 1), size(mask, 2));  
    end
    
    refmask = poly2mask(cwall.x, cwall.y, imsize(1), imsize(2));
    refmask = imresize(refmask, size(mask));   
    %compute DSC and segmentation performance
    DC(f) = 2*sum(refmask(:)&mask(:))/(sum(mask(:))+sum(refmask(:)));%dice similarity coefeccient
    OA = sum(mask(:)&~refmask(:))*(res^2); %oversegmented area
    UA = sum(~mask(:)&refmask(:))*(res^2); %upper-segmented area
    VE=info.psize/res;
    Distance(f)=mdistance(cw,cwallref,im,mask,VE)*res;%contour distance
    AE(f)=OA+UA; %Area-error  
    fprintf('\b\b\b\b\b[%02d%%]',floor(100*f/no_images))
    end
    
end
else
for f = 1:no_images
 % imagenes con segmentacion fallida base de datos de completa
% carga de datos tes
if var==3
f=datos80(f);
end
if f~=166 | f~=109     
    %cargado del mapa de atlas
    load('ATLASS.mat')
    impath = INdataset.path{f};%base de datos completa
    %read image
    info = getinfo(impath);
    info.psize = 0.1;
    im = ffdmRead(impath, info);
    imsize = size(im);
    im = imresize(im, info.psize/res);
    %breast detection
    mask = segBreast(im, false);
    [roi, cont] = segBreast(im, true);
    mask(cont.ycut:end,:) = false;    
    % MAG segmentatation
    mask = mag(im, mask);  
    lado=isright(im);
%     filtrado por atlas
    I=imresize(I,size(mask));
    if lado==1
        I=flip(I,2);
    end
    I(I<inten(4)) = 0;
    I(I>inten(4)) = 1;
    mask=I&mask;
%     
%   post procesado:eliminado de area, operaciones morfologicas y eliminado por distancia
    mask = mclean2(mask,res,area(8),lado,CLEANOBJECT(6));
    %base de datos completa
    cwall = readcwall(INdataset.cwall{f}, size(im));
    cwallref=cwall;
   %estimacion del contorno 
    if isright(im)
        cwall.x = [imsize(2); cwall.x; imsize(2)];
        cwall.y = [1; cwall.y; 1];                
        mask = fliplr(mask);
        %modelaje del musculo pectoral
        cw = mask2cwall(mask);
        mask = poly2mask([1; cw(:,1)], [1; cw(:,2)], size(mask, 1), size(mask, 2));    
        mask = fliplr(mask);
         
    else
        cwall.x = [1; cwall.x; 1];
        cwall.y = [1; cwall.y; 1];  
         %modelaje del musculo pectoral
        cw = mask2cwall(mask);
        mask = poly2mask([1; cw(:,1)], [1; cw(:,2)], size(mask, 1), size(mask, 2));  
    end
    
    refmask = poly2mask(cwall.x, cwall.y, imsize(1), imsize(2));
    refmask = imresize(refmask, size(mask));   
    %compute DSC and segmentation performance
    DC(f) = 2*sum(refmask(:)&mask(:))/(sum(mask(:))+sum(refmask(:)));%dice similarity coefeccient
    OA = sum(mask(:)&~refmask(:))*(res^2); %oversegmented area
    UA = sum(~mask(:)&refmask(:))*(res^2); %upper-segmented area
    VE=info.psize/res;
    Distance(f)=mdistance(cw,cwallref,im,mask,VE)*res;%contour distance
    AE(f)=OA+UA; %Area-error  
    fprintf('\b\b\b\b\b[%02d%%]',floor(100*f/no_images))
    end
end
end
sp = clock;
fprintf('\netime: %s \f', datestr(etime(sp,st)/(24*3600), 'HH:MM:SS'))
dsc1n=0;
dsc2n=0;
dsc3n=0;
%filtrado de imagenes con segementacion nula 
l=1;
for n=1:no_images
   if DC(n)~=0
    dsc1n(l)=Distance(n);
    dsc2n(l)=DC(n);
    dsc3n(l)=AE(n);
    l=l+1;
   end
end
%prueba de normalidad de los datos
h = chi2gof(dsc2n);
%obtencion de la mediana
if h==1
Distan=median(dsc1n)
DSC=median(dsc2n)
AREA=median(dsc3n)
end


