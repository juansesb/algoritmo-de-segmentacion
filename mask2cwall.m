function cwall = mask2cwall(mask)%funcion para obtencion del contorno modelado

B = bwboundaries(mask);
if isempty(B)
    x = ones(100,1);
    y = linspace(1, size(mask, 1), 100);
    cwall = [x(:), y(:)];
    return
end

x = [];
y = [];
for n = 1:length(B)
    x = [x; B{n}(:,2)];
    y = [y; B{n}(:,1)];
end
remov = (x>=size(mask,2)-3)|(y<=3)|(x<=3);
x(remov) = [];
y(remov) = [];
% algoritmo optimizador de RANSAC
% calculo del polinomio de grado 3
P1 = fitPolynomialRANSAC([y, x], 3, 9);
yi1 = linspace(min(y), max(y), 50);
xi1= polyval(P1, yi1);
xi1(end) = 1;
yi1(1) = 1;
cw1 = [xi1(:), yi1(:)];  
%calculo del polinomio de grado 2
P2 = fitPolynomialRANSAC([y, x], 2, 9);
yi2 = linspace(min(y), max(y), 50);
xi2= polyval(P2, yi2);
xi2(end) = 1;
yi2(1) = 1;
cw2 = [xi2(:), yi2(:)];
%obtencion de las mascara respectivas de cada polinomio
m1 = poly2mask([1; cw1(:,1)], [1; cw1(:,2)], size(mask, 1), size(mask, 2));
m2 = poly2mask([1; cw2(:,1)], [1; cw2(:,2)], size(mask, 1), size(mask, 2));
OA = sum(m1(:)&~mask(:))*(0.3^2); %oversegmented area
UA = sum(~m1(:)&mask(:))*(0.3^2); %upper-segmented area
%calculo del error 1
AE1=OA+UA;
OA = sum(m2(:)&~mask(:))*(0.3^2); %oversegmented area
UA = sum(~m2(:)&mask(:))*(0.3^2); %upper-segmented area
%calculo del error 2
AE2=OA+UA;

RE=[AE1 AE2];
T=min(RE);
%obtencion del contorno optimo
 if T==AE1
     cwall=cw1;
 end
 if T==AE2
     cwall=cw2;
 end
%  
