/******************
Input: lrdata.sav
Output: Spearman_HFEV_SAS.pdf
Written by:Tingwei Adeck
Date: Dec 12 2022
Description: Spearman correlation and Predictive Linear Modeling of Height(x) vs Forced expiratory volume (FEV)
Dataset description: Data from Dr. Gaddis
Results: Rho = 0.88 (p <0.001) indicates stattistically significant difference from 0 and a strong positive correlation between Height and FEV_L
Height accounts for 74% of the variance of FEV_L
******************/

%let path=/home/u40967678/sasuser.v94;


libname regr
    "&path/sas_umkc/input";
    
filename lrdata
    "&path/sas_umkc/input/lrdata.sav";   
    
ods pdf file=
    "&path/sas_umkc/output/Spearman_HFEV_SAS.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= lrdata
	out=regr.lrdata
	dbms=sav
	replace;
run;

/*calculate correlation coefficient between Height and FEV_L*/
title 'Spearmans Correlation for Height vs FEV_L';
proc corr data=regr.lrdata spearman OUTS=regr.spearman_data;
	var Height FEV_L;
run;


ods pdf close;