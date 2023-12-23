/******************
Input: biserial.sav
Output: Biserial_HFEV_SAS.pdf
Written by:Tingwei Adeck
Date: Dec 12 2022
Description: Biserial correlation analysis
Dataset description: Dataset from Dr. Gaddis
Results: Biserial PPM = -0.401 with p<0.001 indicates a negative correlation between males and females on time spent watching tv
******************/

%let path=/home/u40967678/sasuser.v94;


libname regr
    "&path/sas_umkc/input";
    
filename biserial
    "&path/sas_umkc/input/biserial.sav";   
    
ods pdf file=
    "&path/sas_umkc/output/Biserial_HFEV_SAS.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= biserial
	out=regr.biserial
	dbms=sav
	replace;
run;


%inc "&path/sas_umkc/src/point_biserial.sas";
%BISERIAL(data=regr.biserial,binary=Sex,contin=time_tv,out=regr.biserial_out);

title 'point biserial correlation between sex and time spend on tv';
proc print data = regr.biserial_out;


title 'Barchart mean time spend on tv';
proc sgplot data=regr.biserial;
   vbar Sex / stat = mean  group=Sex response=time_tv;
   xaxis display=(nolabel noticks);
   keylegend / title='Sex';

title 'Box plot mean time spend on tv';
proc sgplot data=regr.biserial;
   vbox time_tv / category=Sex group=Sex;
   xaxis label="Sex";
   keylegend / title="Sex";
run; 



ods pdf close;