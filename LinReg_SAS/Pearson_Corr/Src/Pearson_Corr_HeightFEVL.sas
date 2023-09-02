/******************
Input: lrdata.sav
Output: Linaer_Regression_HFEV_SAS.pdf
Written by:Tingwei Adeck
Date: Dec 12 2022
Description: Pearson product moment correlation and Predictive Linear Modeling of Height(x) vs Forced expiratory volume (FEV)
Dataset description: Dataset from Dr. Gaddis
Results: r = 0.86, r^2=0.74 (p <0.001) indicates stats significant deviation from 0 and is a strong correlation
Height accounts for 74% of the variance of FEV_L
******************/

%let path=/home/u40967678/sasuser.v94;


libname regr
    "&path/sas_umkc/input";
    
filename lrdata
    "&path/sas_umkc/input/lrdata.sav";   
    
ods pdf file=
    "&path/sas_umkc/output/Linaer_Regression_HFEV_SAS.pdf";
    
options papersize=(8in 4in) nonumber nodate;

proc import file= lrdata
	out=regr.lrdata
	dbms=sav
	replace;
run;

/*calculate correlation coefficient between Height and FEV_L*/
title 'Pearsons Correlation for Height vs FEV_L';
proc corr data=regr.lrdata OUTP=regr.pearson_data;
	var Height FEV_L;
run;

/*calculate correlation coefficient for all variables*/
title 'Pearsons Correlation with r';
proc corr data=regr.lrdata;
run;


ods pdf close;