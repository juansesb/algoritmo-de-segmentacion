function md=mdistanceTUH(Cb,C0,im,mask,res)
%Descripton
%   This function compute the mean distance from the contour C to reference
%   contour C0.
%Inputs:
%   Cb contour of the chest wall as returned by SegBreast.m 
%   C0 manual contour perform by a radiologist.
C0.x=C0.x/(res);
C0.y=C0.y/(res);
C.x=Cb(:,1);
C.y=Cb(:,2);


if isempty(C0.y)
    md=nan;
    return
end

if isright(im)
    C0.x=size(im,2)-C0.x+1; 
end
if sum(mask(:))==0
    dref=max(C0.x)+max(C0.y);
    n1=round(100*max(C0.x)/dref);
    C.x=[ones(100-n1,1);linspace(1,max(C0.x),n1)'];
    C.y=[linspace(1,max(C0.y),100-n1)';ones(n1,1)]; 
end
close
imshow(im)
hold on
plot(C.x,C.y, 'linewidth', 2)
plot(C0.x,C0.y, 'linewidth', 2)
% 


% Xin=linspace(1,max(X0),100)';
% Yin= interp1(X0,Y0,Xin);
% plot(Xin,Yin,'+')

X0=C0.x;
Y0=C0.y;
X1=C.x;
Y1=C.y;
siz=length(X1);
Yin=linspace(1,max(Y0),100)';
Xin=interp1(Y0,X0,Yin);
% plot(Xin,Yin,'+')


distance=zeros(siz,1);
for i =1:siz
   D=sqrt((Xin-X1(i)).^2+(Yin-Y1(i)).^2); 
   distance(i)=min(D);
end
md=sum(distance)/siz;