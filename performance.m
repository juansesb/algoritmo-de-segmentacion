clc,clear,close all
load inbreast_results.mat
% DC_mag(109)=[];
% DC(109)=[];
pDC=ranksum(DC,DC_mag)
pAE=ranksum(AE,AE_mag)
pMD=ranksum(Distance,MD_mag)
pJC=ranksum(JC,JC_mag)
