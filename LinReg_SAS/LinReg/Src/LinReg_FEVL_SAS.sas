* author: Tingwei Adeck
* date: 08-23-2023
* purpose: Linear Regression Modeling in SAS-A Machine Learning Primer
* license: public domain
* Input: LRDATA.csv or linear-regression.sav (A different import PROC)
* Output: Linear_Regression_FEVL_SAS.pdf
* Description: Y~X (FEVL~Height) linear model-How much of FEVL variation is explained by Height?
* Results: Height is a good predictor of FEVL-On a side note-titles are diagnostic in SAS
* The model is 74% predictive (NOT SO GOOD)-Poor from a machine learning perspective;

%let path=/home/u40967678/sasuser.v94;

libname linreg
    "&path/sas_umkc/input";
    
filename fevl
    "&path/sas_umkc/input/LRDATA.csv";   
    
ods pdf file=
    "&path/sas_umkc/output/Linear_Regression_FEVL_SAS.pdf";
    
options papersize=(8in 11in) nonumber nodate;

proc import file= fevl
	out=linreg.fevl
	dbms=csv
	replace;
	delimiter=",";
run;

title 'summary (first 5 obs) of respiratory data';
proc print data=linreg.fevl (obs=5);

*add transformed variables;


/*Determine the best predictor variable or variables*/
/*multivariate correlation check*/
title 'multi-variate correlation matrix';
proc corr data=linreg.fevl;
run;

title 'Visualization of multivariate correlation';
proc corr data=linreg.fevl nomiss plots=matrix(histogram); 
run;

title 'Visualization of correlation for the appropriate model';
proc corr data=linreg.fevl plots=scatter(nvar=all);;
	var Height FEV_L;
run;

*ASSUMPTION(S) CHECK;

title 'Linear Relationship Assumption';
proc sgplot data=linreg.fevl;
	reg y = FEV_L x = Height;
run;

title 'Linear Relationship Assumption with more control on the plot-Also model is obtained';
proc sgplot data=linreg.fevl noautolegend;
   xaxis label='Height';
   yaxis label='FEVL';
reg y = FEV_L x = Height / lineattrs=(color=blue thickness=2)
   markerattrs=(color=green size=5px symbol=circlefilled);
   
/*Outliers test by standardization (<3.29 = good)*/
title 'standardize variables';
proc stdize data=linreg.fevl out=linreg.standardized_data;
   var FEV_L Height;
run;

/*Durbin-Watson test for independence of errors (autocorrelation)-Also asseses residuals normality*/
title 'Check autocorrelation';
proc autoreg data=linreg.fevl; *can also use proc reg;
   model FEV_L = Height / dw=4 dwprob;
   ods output ParameterEstimates=linreg.PE;
run;

* ASSUMPTION(S) CHECK END;

*REGRESSION PROPER;

*General regression model with Anova results;
title 'Regression Model with Fit Diagnostics';
proc reg data=linreg.fevl;
    model FEV_L = Height;
run;

*No visible output with noprint;
title 'Regression with R-squared value';
proc reg data=linreg.fevl outest=linreg.effsize noprint;
    model FEV_L = Height / rsquare;
run;

data _null_;
   set linreg.PE;
   if _n_ = 1 then call symput('Int', put(Estimate, BEST6.));    
   else            call symput('Slope', put(Estimate, BEST6.));  
run;

data _null_;
   set linreg.effsize;
   if _n_ = 1 then call symput('rsquared', put(_RSQ_, BEST6.));    
run;

/*to push estimate parameters to graph*/
title 'Plot with insets for the slope and intercept';
proc sgplot data=linreg.fevl noautolegend;
   title "Regression Line with Slope and Intercept";
   reg y=FEV_L x=Height;
   inset "Intercept = &Int" "Slope (x-coefficient) = &Slope" "R-squared = &rsquared"/ 
         border title="Parameter Estimates" position=topleft;
run;

ods pdf close;